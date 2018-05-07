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
    private let autocompleteResultTable = UITableView()

    private let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D?
    private var currentPin: MKPointAnnotation?
    private let searchCompleter = MKLocalSearchCompleter()
    private var autocompleteResults: [String]?

    // if map view is hidden, then autocompleteResultTable is not hidden (& vice versa)
    private var mapViewHidden = false

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
        searchBar.delegate = self

        view.addSubview(mapView)
        mapView.delegate = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ChooseAddressViewController.dropPinAtLocation(_:)))
        longPress.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(longPress)

        // add table view after mapView so it can lay over it
        view.addSubview(autocompleteResultTable)
        autocompleteResultTable.register(AutocompleteResultTableViewCell.self, forCellReuseIdentifier: Constants.autocompleteSearchResult)
        autocompleteResultTable.isHidden = !mapViewHidden
        autocompleteResultTable.delegate = self
        autocompleteResultTable.dataSource = self

        // show map view, hide table view
        showAndHideViews()

        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()

        searchCompleter.delegate = self
        // limit search results to mapviews current region
        searchCompleter.region = mapView.region

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

        autocompleteResultTable.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
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
        mapViewHidden = false
        showAndHideViews()

        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        var region: MKCoordinateRegion?
        if let coordinate = currentCoordinate {
            region = MKCoordinateRegion(center: coordinate , span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4))
        }

        localSearchRequest.region = region ?? MKCoordinateRegion()
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
            let pin = MKPointAnnotation()
            pin.coordinate = firstMapItem.placemark.coordinate
            pin.title = firstMapItem.name

            let span = MKCoordinateSpanMake(0.75, 0.75)
            let region = MKCoordinateRegion(center: pin.coordinate, span: span)

            self.removeCurrentPin()
            self.currentPin = pin
            self.mapView.setRegion(region, animated: true)
            self.mapView.addAnnotation(pin)
            self.mapView.selectAnnotation(pin, animated: true)
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            removeCurrentPin()
            mapViewHidden = false
            showAndHideViews()
        } else {
            print("Assigning queryFragment to: \(searchText)")
            searchCompleter.queryFragment = searchText
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
        removeCurrentPin()
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
                let name = self.extractAddress(firstPlacemark)
                self.searchBar.text = name
                pin.title = name
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

    private func removeCurrentPin() {
        if let currPin = currentPin {
            mapView.removeAnnotation(currPin)
        }
    }
}

extension ChooseAddressViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        autocompleteResults = completer.results.map { $0.title }
        print("autocompleteResults: \(autocompleteResults)")
        mapViewHidden = true
        showAndHideViews()
        self.autocompleteResultTable.reloadData()
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        fatalError(error.localizedDescription)
    }
}

extension ChooseAddressViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Don't want autocomplete results to have section headers
        return autocompleteResults?.count ?? 0

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.autocompleteSearchResult, for: indexPath) as! AutocompleteResultTableViewCell
        let cellTitle = autocompleteResults![indexPath.row]
        print("cellTitle: \(cellTitle)")
        cell.title = cellTitle
        return cell
    }

    private func showAndHideViews() {
        mapView.isHidden = mapViewHidden
        autocompleteResultTable.isHidden = !mapViewHidden
    }
}
