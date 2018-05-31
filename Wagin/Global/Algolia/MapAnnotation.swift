//
//  MapAnnotation.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/30/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import MapKit
import InstantSearchCore
import AlgoliaSearch

class MapAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?

    init(_ coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }

    init(json: [String: Any]) {
        guard let lat = json["lat"] as? Double, let lng = json["lng"] as? Double else { fatalError("Malformatted JSON for MapAnnotation") }

        print("json: \(json)")
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        self.title = json["eventPostID"] as? String
        super.init()
    }
}
