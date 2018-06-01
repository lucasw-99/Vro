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
    let eventId: String
    // TODO: Make address optional

    init(eventJson json: [String: Any]) {
        guard let geoloc = json["_geoloc"] as? [String: Any],
            let lat = geoloc["lat"] as? Double,
            let lng = geoloc["lng"] as? Double,
            let address = json["address"] as? String,
            let description = json["description"] as? String,
            let eventImageUrl = json["eventImageURL"] as? String,
            let eventTime = json["eventTime"] as? String,
            let hostUid = json["hostUID"] as? String,
            let eventId = json["eventId"] as? String else { fatalError("Malformatted json for event") }
        self.hostUID = hostUid
        self.eventImageURL = eventImageUrl
        self.description = description
        self.address = address
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        self.eventTime = Util.stringToDate(dateString: eventTime)
        self.eventId = eventId
    }

    init(_ hostUID: String,
         _ eventImageURL: String,
         _ description: String,
         _ address: String,
         _ eventTime: Date,
         _ eventId: String,
         _ coordinate: CLLocationCoordinate2D) {
        self.hostUID = hostUID
        self.eventImageURL = eventImageURL
        self.description = description
        self.address = address
        self.eventTime = eventTime
        self.coordinate = coordinate
        self.eventId = eventId
    }
}
