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
    func on(results: SearchResults?, error: Error?, userInfo: [String : Any]) {
        print("in map view widget")
        let searchParams = userInfo["params"] as? SearchParameters
        if searchParams == nil || searchParams?.page == 0 {
            let annotations = self.annotations
            removeAnnotations(annotations)
        }

        guard let results = results else { return }

        // TODO: Change weak to unowned so we don't have to do that BS unwrapping
        results.hits.forEach { [weak self] hit in
            guard let latlong = hit["_geoloc"] as? [String: Any] else { fatalError("malformatted JSON") }
            let annotation = MapAnnotation(json: latlong)
            self?.addAnnotation(annotation)
        }

        showAnnotations(self.annotations, animated: true)
    }
}
