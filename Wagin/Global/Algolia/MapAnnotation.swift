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
    var event: Event

    init(_ event: Event) {
        self.event = event
        self.coordinate = event.coordinate
        super.init()
    }

    convenience init(eventJson json: [String: Any]) {
        self.init(Event(eventJson: json))
    }
}
