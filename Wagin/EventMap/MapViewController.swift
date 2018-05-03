//
//  MapViewController.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/2/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var selectedLocationLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!

    private let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D!

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
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
            self.selectedLocationLabel.text = "\(hours) h \(minutes) min \(seconds)s"
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

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let currentLocation = locations.first else { return }
        currentCoordinate = currentLocation.coordinate
        mapView.userTrackingMode = .followWithHeading
    }
}

extension MapViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Search button clicked")
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
            print("Response: \(response.mapItems)")
            guard let firstMapItem = response.mapItems.first else {
                print("No results")
                return
            }
            self.getDirections(to: firstMapItem)
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("Rendering mapView")
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 10
            return renderer
        }

        return MKOverlayRenderer()
    }
}
