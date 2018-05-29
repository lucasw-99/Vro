//
//  Event.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/2/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import MapKit

class Event {
    let hostUID: String
    // TODO: Make it a URL???
    let eventImageURL: String
    let description: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let eventTime: Date
    // TODO: Make address optional, and add coordinate field

    init(_ hostUID: String,
         _ eventImageURL: String,
         _ description: String,
         _ address: String,
         _ eventTime: Date,
         _ coordinate: CLLocationCoordinate2D) {
        self.hostUID = hostUID
        self.eventImageURL = eventImageURL
        self.description = description
        self.address = address
        self.eventTime = eventTime
        self.coordinate = coordinate
    }
}
