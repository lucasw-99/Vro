//
//  TestViewController.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/5/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import MapKit

class ChooseAddressViewController: UIViewController {
    private let headerView = UIView()
    private let headerLabel = UILabel()
    private let searchBar = UISearchBar()
    private let mapView = MKMapView()

    private let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D!
    private var currentPin: MKPointAnnotation?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupLayout()
    }

    private func setupSubviews() {
        headerLabel.text = "Enter Event Address"
        headerLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        headerLabel.numberOfLines = 1
        headerLabel.textAlignment = .center
        headerView.addSubview(headerLabel)
        view.addSubview(headerView)

        view.addSubview(searchBar)

        view.addSubview(mapView)

        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()

        searchBar.delegate = self

        mapView.delegate = self

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ChooseAddressViewController.dropPinAtLocation(_:)))
        longPress.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(longPress)

        view.backgroundColor = .white
    }

    private func setupLayout() {
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.layoutMarginsGuide.snp.topMargin)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(50)
        }

        headerLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
            make.height.equalTo(56)
        }

        mapView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    private func getDirections(to destinationMapItem: MKMapItem) {
        let sourcePlacemark = MKPlacemark(coordinate: currentCoordinate)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)

        let directionsRequest = MKDirectionsRequest()
        directionsRequest.source = sourceMapItem
        directionsRequest.destination = destinationMapItem
        directionsRequest.transportType = .automobile

        let directions = MKDirections(request: directionsRequest)
        directions.calculate { (response, error) in
            if error != nil {
                print("Error: \(error?.localizedDescription)")
            }
            guard let response = response else { return }
            guard let firstRoute = response.routes.first else { return }
            let (hours, minutes, seconds) = Util.secondsToHoursMinutesSeconds(seconds: Int(firstRoute.expectedTravelTime))
            self.headerLabel.text = "\(hours) h \(minutes) min \(seconds)s"
            self.mapView.add(firstRoute.polyline)

            let annotation = MKPointAnnotation()
            annotation.coordinate = destinationMapItem.placemark.coordinate
            annotation.title = destinationMapItem.name

            let destSpan = MKCoordinateSpanMake(0.15, 0.15)
            let destRegion = MKCoordinateRegion(center: annotation.coordinate, span: destSpan)

            self.mapView.setRegion(destRegion, animated: true)
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
}

extension ChooseAddressViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let currentLocation = locations.first else { return }
        currentCoordinate = currentLocation.coordinate
        mapView.userTrackingMode = .followWithHeading
    }
}

extension ChooseAddressViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        let region = MKCoordinateRegion(center: currentCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4))
        localSearchRequest.region = region
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (response, error) in
            if error != nil {
                print("Error: \(error?.localizedDescription)")
            }
            guard let response = response else { return }
            guard let firstMapItem = response.mapItems.first else {
                print("No results")
                return
            }
            self.getDirections(to: firstMapItem)
        }
    }
}

extension ChooseAddressViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 10
            return renderer
        }

        return MKOverlayRenderer()
    }
}

// Extension for dropping a pin based on long touch press
extension ChooseAddressViewController {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // get the particular pin that was tapped
        let pinToZoomOn = view.annotation
        let span = MKCoordinateSpanMake(0.75, 0.75)

        // move the map
        let region = MKCoordinateRegion(center: pinToZoomOn!.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }

    @objc private func dropPinAtLocation(_ recognizer: UIGestureRecognizer) {
        if recognizer.state != .began {
            print("Not the proper touch state?")
            return
        }

        let touchPoint = recognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)

        let pin = MKPointAnnotation()
        pin.coordinate = touchMapCoordinate
        if let currPin = currentPin {
            mapView.removeAnnotation(currPin)
        }
        currentPin = pin
        mapView.addAnnotation(pin)
        mapView.selectAnnotation(pin, animated: true)
        getAddressFromPin(pin)
    }

    private func getAddressFromPin(_ pin: MKPointAnnotation) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude)

        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let firstPlacemark = placemarks?.first {
                self.searchBar.text = self.extractAddress(firstPlacemark)
                print("Set searchBar text to \(self.searchBar.text)")
            } else {
                print("Error: \(error!.localizedDescription)")
            }
        }
    }

    private func extractAddress(_ placemark: CLPlacemark) -> String {
        let address = "\(placemark.subThoroughfare ?? "") \(placemark.thoroughfare ?? ""), \(placemark.locality ?? ""), \(placemark.administrativeArea ?? "") \(placemark.postalCode ?? "")"
        return address
    }
}
