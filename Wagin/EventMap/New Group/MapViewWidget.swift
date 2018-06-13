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
    private var origin: CLLocationCoordinate2D?
    private var radius: Int?

    override init(frame: CGRect) {
        super.init(frame: frame)
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

        results.hits.forEach { [unowned self] hit in
            let annotation = EventAnnotation(eventJson: hit)
            self.addAnnotation(annotation)
        }
        
        guard let origin = origin, let radius = radius else { fatalError("Origin and/or radius was nil") }
        addRadiusCircle(origin: origin, radius: radius)
    }

    private func addRadiusCircle(origin: CLLocationCoordinate2D, radius: Int) {
        let mapRadiusCircle = MapRadius(origin: origin, radius: radius, color: .red)
        add(mapRadiusCircle)

        visibleMapRect = mapRectThatFits(mapRadiusCircle.boundingMapRect, edgePadding: UIEdgeInsetsMake(60, 60, 60, 60))
    }
}
