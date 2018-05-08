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

    private let selectAddressLabel = UILabel()
    private let selectAddressButton = UIButton()
    private let selectAddressContainerView = UIView()

    private let locationManager = CLLocationManager()
    private var currentUserCoordinate: CLLocationCoordinate2D?
    private var currentPin: MKPointAnnotation?
    private let searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [(String, String, [NSValue])]()

    // if map view is hidden, then autocompleteResultTable is not hidden (& vice versa)
    private var mapViewHidden = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupLayout()
    }

    @objc private func selectAddress(_ sender: Any) {
        print("Select address button pressed")
        navigationController?.pushViewController(EventMetadataViewController(), animated: true)
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

        mapView.delegate = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ChooseAddressViewController.dropPinAtLocation(_:)))
        longPress.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(longPress)
        view.addSubview(mapView)

        selectAddressLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        selectAddressLabel.text = "Select Address"
        selectAddressLabel.textAlignment = .center
        selectAddressContainerView.addSubview(selectAddressLabel)

        selectAddressButton.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
        selectAddressButton.addTarget(self, action: #selector(ChooseAddressViewController.selectAddress(_:)), for: .touchUpInside)
        selectAddressContainerView.addSubview(selectAddressButton)

        selectAddressContainerView.backgroundColor = .white
        selectAddressContainerView.layer.cornerRadius = 10
        selectAddressContainerView.isHidden = true
        selectAddressContainerView.alpha = 0.95
        view.addSubview(selectAddressContainerView)

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

        selectAddressLabel.snp.makeConstraints { make in
            make.leading.equalTo(selectAddressContainerView.snp.leadingMargin)
            make.trailing.equalTo(selectAddressContainerView.snp.trailingMargin)
            make.top.equalToSuperview()
        }

        selectAddressButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.top.equalTo(selectAddressLabel.snp.bottom).offset(10)
            make.height.equalTo(50)
            make.width.equalTo(50)
            make.centerX.equalToSuperview()
        }

        selectAddressContainerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-80)
            make.centerX.equalToSuperview()
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
        guard let currentUserLocation = locations.first else { return }
        currentUserCoordinate = currentUserLocation.coordinate
        mapView.userTrackingMode = .followWithHeading
    }
}

extension ChooseAddressViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        var searchText = searchBar.text!
        // if autocomplete results are non-empty, user expects search to give
        // first autocomplete result
        if !searchResults.isEmpty {
            (searchText, _, _) = searchResults.first!
        }
        searchQuery(query: searchText)
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

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        // no autocomplete results should popup for empty search bar
        if !searchBar.text!.isEmpty {
            mapViewHidden = true
            showAndHideViews()
        }
        return true
    }

    /*
     query: A query to search
    */
    private func searchQuery(query: String) {
        mapViewHidden = false
        showAndHideViews()
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = query
        var region: MKCoordinateRegion?
        if let coordinate = currentUserCoordinate {
            region = MKCoordinateRegion(center: coordinate , span: MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4))
        }

        localSearchRequest.region = region ?? MKCoordinateRegion()
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (response, error) in
            if error != nil {
                print("Error: \(error!.localizedDescription)")
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
            self.selectAddressContainerView.isHidden = false
            self.mapView.selectAnnotation(pin, animated: true)
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
        getAddressFromPin(pin)
        mapView.addAnnotation(pin)
        selectAddressContainerView.isHidden = false
        mapView.selectAnnotation(pin, animated: true)
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
            // only show address button if a pin is on the map
            self.selectAddressContainerView.isHidden = true
        }
    }
}

extension ChooseAddressViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results.map { ($0.title, $0.subtitle, $0.titleHighlightRanges) }
        mapViewHidden = true
        showAndHideViews()
        DispatchQueue.main.async {
            self.autocompleteResultTable.reloadData()
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        fatalError(error.localizedDescription)
    }
}

extension ChooseAddressViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Don't want autocomplete results to have section headers
        return searchResults.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.autocompleteSearchResult, for: indexPath) as! AutocompleteResultTableViewCell
        let (title, subTitle, matchingRanges) = searchResults[indexPath.row]
        let highlightedText = boldHighlightedSearchResult(title, matchingRanges)
        cell.updateCell(titleText: highlightedText, descriptionText: subTitle)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let (searchTitle, _, _) = searchResults[indexPath.row]
        print("searchTitle: \(searchTitle)")
        searchBar.text = searchTitle
        searchQuery(query: searchTitle)
    }

    /*
     searchResult: The search result
     range: The ranges in to highlight in searchResult
     */
    func boldHighlightedSearchResult(_ searchResult: String, _ values: [NSValue]) -> NSMutableAttributedString {
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: searchResult)
        for value in values {
            let range = value.rangeValue
            attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 20, weight: .semibold), range: range)
            attributedString.addAttribute(NSAttributedStringKey.backgroundColor, value: UIColor.yellow, range: range)
        }
        return attributedString
    }

    private func showAndHideViews() {
        mapView.isHidden = mapViewHidden
        autocompleteResultTable.isHidden = !mapViewHidden
    }
}
