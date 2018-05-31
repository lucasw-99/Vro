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
}

// MARK: User location
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let currentLocation = locations.first else { return }
        currentCoordinate = currentLocation.coordinate
        mapViewWidget.userTrackingMode = .followWithHeading
        findEvents(userLocation: currentLocation.coordinate)
    }
}

// MARK: Search bar
extension MapViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        let query = searchBar.text
        print("query: \(query!)")
        // TODO: Change user location
        findEvents(userLocation: currentCoordinate!)
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
            findEvents(userLocation: currentCoordinate!)
        }
    }
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

        view.addSubview(headerView)

        searchBarWidget.delegate = self
        view.addSubview(searchBarWidget)

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
            make.height.equalTo(125)
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
            make.width.equalTo(250)
        }

        currentRadiusLabel.snp.makeConstraints { make in
            make.top.equalTo(radiusSlider.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        searchBarWidget.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
            make.height.equalTo(56)
        }

        mapViewWidget.snp.makeConstraints { make in
            make.top.equalTo(searchBarWidget.snp.bottom)
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
