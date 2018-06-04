//
//  MapViewController.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/2/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import MapKit
import AlgoliaSearch
import InstantSearch
import InstantSearchCore

class MapViewController: UIViewController {
    private let headerView = UIView()
    private let headerLabel = UILabel()
    private let radiusSlider = UISlider()
    private let currentRadiusLabel = UILabel()

    private let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D?

    private let searchBarWidget = SearchBarWidget()
    private let statsWidget = StatsLabelWidget()
    private let mapViewWidget = MapViewWidget()

    private var searchRadius: Int = 10000  // in meters

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupLayout()
        setupInstantSearch()
        registerWidgets()
    }

    private func findEvents(userLocation location: CLLocationCoordinate2D) {
        print("searching for stuff")
        InstantSearch.shared.searcher.params.aroundLatLng = LatLng(lat: location.latitude, lng: location.longitude)
        InstantSearch.shared.searcher.search()
    }

    private func startSearch(_ coordinate: CLLocationCoordinate2D, _ radius: Int) {
        mapViewWidget.setOriginAndRadius(coordinate, radius)
        findEvents(userLocation: coordinate)
    }
}

// MARK: User location
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let currentLocation = locations.first else { return }
        currentCoordinate = currentLocation.coordinate
        mapViewWidget.userTrackingMode = .followWithHeading
        startSearch(currentLocation.coordinate, searchRadius)
    }
}

// MARK: Search bar
extension MapViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        let query = searchBar.text
        print("query: \(query!)")
        // TODO: Change user location

        startSearch(currentCoordinate!, searchRadius)
    }
}

// MARK: Slider
extension MapViewController {
    @objc private func sliderValueDidChange(_ slider: UISlider) {
        print("Slider value changed: \(slider.value)")
        let currentValue = Int(round(slider.value))
        currentRadiusLabel.text = "\(currentValue)m"
    }

    @objc private func sliderDidTouchUp(_ slider: UISlider) {
        let currentValue = Int(round(slider.value))
        if currentValue != searchRadius {
            print("searching events")
            searchRadius = currentValue
            InstantSearch.shared.searcher.params.aroundRadius = Query.AroundRadius.explicit(UInt(searchRadius))

            startSearch(currentCoordinate!, searchRadius)
        }
    }
}

// MARK: EventAnnotation button function
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let eventAnnotation = view.annotation as? EventAnnotation else { fatalError("Expected event annotation") }
        let eventViewController = EventViewController(forEvent: eventAnnotation.event)
        navigationController?.pushViewController(eventViewController, animated: true)
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let mapRadius = overlay as? MapRadius {
            let circleView = MKCircleRenderer(overlay: mapRadius)
            circleView.strokeColor = mapRadius.color
            return circleView
        }
        return MKOverlayRenderer()
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        let identifier = "eventPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            // TODO: Change to a cooler button
            let btn = UIButton(type: .infoDark)
            annotationView?.rightCalloutAccessoryView = btn
            annotationView?.image = #imageLiteral(resourceName: "balloons")
        } else {
            annotationView?.annotation = annotation
        }

        return annotationView
    }
}

// MARK: Smooth circle animations
extension MapViewController {
//    private func rectForCircle(_ circle: MKCircle) -> CGRect {
//        let center = MKMapPointForCoordinate(circle.coordinate)
//        let radius = circle.radius
//        let mapRadius = radius * MKMapPointsPerMeterAtLatitude(circle.coordinate.latitude)
//
//        let mapRect = MKMapRectMake(center.x - mapRadius, center.y - mapRadius, mapRadius * 2, mapRadius * 2)
//        circle.boundingMapRect
//        return MKOverlayRenderer.rectFor
//    }
//    -(CGRect)rectForCircle{
//
//    //the circle center
//    MKMapPoint mpoint = MKMapPointForCoordinate([[self overlay] coordinate]);
//
//    //geting the radius in map point
//    double radius = [(MKCircle*)[self overlay] radius];
//    double mapRadius = radius * MKMapPointsPerMeterAtLatitude([[self overlay] coordinate].latitude);
//
//    //calculate the rect in map coordinate
//    MKMapRect mrect = MKMapRectMake(mpoint.x - mapRadius, mpoint.y - mapRadius, mapRadius * 2, mapRadius * 2);
//
//    //return the pixel coordinate circle
//    return [self rectForMapRect:mrect];
}

// MARK: Setup subviews
extension MapViewController {
    private func setupSubviews() {
        headerLabel.text = "Nearby Events"
        headerLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        headerLabel.numberOfLines = 1
        headerLabel.textAlignment = .center
        headerView.addSubview(headerLabel)

        statsWidget.textAlignment = .center
        statsWidget.font = UIFont.systemFont(ofSize: 14)
        headerView.addSubview(statsWidget)

        radiusSlider.minimumValue = 100
        radiusSlider.maximumValue = 1000000
        radiusSlider.value = Float(searchRadius)
        radiusSlider.isContinuous = true
        radiusSlider.tintColor = .blue
        radiusSlider.addTarget(self, action: #selector(MapViewController.sliderValueDidChange(_:)), for: .valueChanged)
        radiusSlider.addTarget(self, action: #selector(MapViewController.sliderDidTouchUp(_:)), for: .touchUpInside)
        headerView.addSubview(radiusSlider)

        currentRadiusLabel.text = "\(searchRadius)m"
        currentRadiusLabel.textAlignment = .center
        currentRadiusLabel.font = UIFont.systemFont(ofSize: 12)
        headerView.addSubview(currentRadiusLabel)

        searchBarWidget.delegate = self
        searchBarWidget.barTintColor = .white
        // TODO: Is this a clean way to set the border color?
        for view in searchBarWidget.subviews[0].subviews {
            if view is UITextField {
                view.layer.borderWidth = 1
                view.layer.borderColor = UIColor.lightGray.cgColor
                view.layer.cornerRadius = 5
            }
        }
        headerView.addSubview(searchBarWidget)

        view.addSubview(headerView)

        mapViewWidget.delegate = self
        view.addSubview(mapViewWidget)

        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()

        view.backgroundColor = .white
    }

    private func setupLayout() {
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.layoutMarginsGuide.snp.topMargin)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(175)
        }

        headerLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(20)
        }

        statsWidget.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        radiusSlider.snp.makeConstraints { make in
            make.top.equalTo(statsWidget.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
        }

        currentRadiusLabel.snp.makeConstraints { make in
            make.top.equalTo(radiusSlider.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        searchBarWidget.snp.makeConstraints { make in
            make.top.equalTo(currentRadiusLabel.snp.bottom)
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
            make.height.equalTo(55)
        }

        mapViewWidget.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    private func setupInstantSearch() {
        // TODO: Make this cleaner please, this is dirty dirty
        InstantSearch.shared.configure(appID: "1W1CGWYI4N", apiKey: "99390aeab22b4e94b41e432939f3d424", index: "events")
        InstantSearch.shared.searcher.params.aroundRadius = Query.AroundRadius.explicit(UInt(searchRadius))
    }

    private func registerWidgets() {
        // register all widgets in this view controller
        InstantSearch.shared.registerAllWidgets(in: view)
    }
}
