//
//  MapViewWidget.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/30/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import MapKit
import InstantSearch
import InstantSearchCore

class MapViewWidget: MKMapView, AlgoliaWidget, ResultingDelegate {
    private var origin: CLLocationCoordinate2D!
    private var radius: Int!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setOriginAndRadius(_ origin: CLLocationCoordinate2D, _ radius: Int) {
        self.origin = origin
        self.radius = radius
    }

    func on(results: SearchResults?, error: Error?, userInfo: [String : Any]) {
        let searchParams = userInfo["params"] as? SearchParameters

        removeOverlays(overlays)
        if searchParams == nil || searchParams?.page == 0 {
            removeAnnotations(annotations)
        }

        guard let results = results else { return }

        // TODO: Change weak to unowned so we don't have to do that BS unwrapping
        results.hits.forEach { [weak self] hit in
            guard let latlong = hit["_geoloc"] as? [String: Any] else { fatalError("malformatted JSON") }
            let annotation = MapAnnotation(json: latlong)
            self?.addAnnotation(annotation)
        }

        addRadiusCircle(origin: origin, radius: radius)
    }
}


// MARK: Map view
extension MapViewWidget: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let mapRadius = overlay as? MapRadius {
            let circleView = MKCircleRenderer(overlay: mapRadius)
            circleView.strokeColor = mapRadius.color
            return circleView
        }
        return MKOverlayRenderer()
    }

    private func addRadiusCircle(origin: CLLocationCoordinate2D, radius: Int) {
        let mapRadiusCircle = MapRadius(origin: origin, radius: radius, color: .red)
        add(mapRadiusCircle)

        visibleMapRect = mapRectThatFits(mapRadiusCircle.boundingMapRect, edgePadding: UIEdgeInsetsMake(60, 60, 60, 60))
    }
}
