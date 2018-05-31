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

    private let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D?

    private let searchBarWidget = SearchBarWidget()
    private let statsWidget = StatsLabelWidget()
    private let mapViewWidget = MapViewWidget()
    private let sliderWidget = SliderWidget()

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

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let currentLocation = locations.first else { return }
        currentCoordinate = currentLocation.coordinate
        mapViewWidget.userTrackingMode = .followWithHeading
        findEvents(userLocation: currentLocation.coordinate)
    }
}

extension MapViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        let query = searchBar.text
        print("query: \(query!)")
        findEvents(userLocation: currentCoordinate!)
    }
}

// MARK: Setup subviews
extension MapViewController {
    private func setupSubviews() {
        headerLabel.text = "Nearby Events"
        headerLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        headerLabel.numberOfLines = 1
        headerLabel.textAlignment = .center
        headerView.addSubview(headerLabel)

        statsWidget.textAlignment = .center
        statsWidget.font = UIFont.systemFont(ofSize: 14)
        headerView.addSubview(statsWidget)

        sliderWidget.attribute

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
            make.height.equalTo(90)
        }

        headerLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        statsWidget.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(10)
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
        InstantSearch.shared.searcher.params.aroundRadius = Query.AroundRadius.explicit(UInt(10000))
    }

    private func registerWidgets() {
        // register all widgets in this view controller
        InstantSearch.shared.registerAllWidgets(in: view)
    }
}
