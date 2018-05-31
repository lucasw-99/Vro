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
        let searchParams = userInfo["params"] as? SearchParameters
        if searchParams == nil || searchParams?.page == 0 {
            let annotations = self.annotations
            removeAnnotations(annotations)
        }

        guard let results = results else { return }

        results.hits.forEach { [weak self] hit in
            let annotation = MapAnnotation(json:)
        }
    }
}
