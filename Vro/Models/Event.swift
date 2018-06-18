//
//  Event.swift
//  Vro
//
//  Created by Lucas Wotton on 5/2/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import MapKit

class Event {
    var dictValue: [String: Any] {
        let eventTimeString = Util.dateToString(date: eventTime)

        let eventObject = [
            "host": host.dictValue,
            // TODO: Change this to a valid description of event
            "description": description,
            "address": address,
            "_geoloc": [
                "lat": coordinate.latitude,
                "lng": coordinate.longitude
            ],
            "eventImageURL": eventImageURL,
            "eventTime": eventTimeString,
            "attendeeCount": attendeeCount
        ] as [String: Any]

        return eventObject
    }

    let host: UserProfile
    // TODO: Make it a URL???
    let eventImageURL: String
    let description: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let eventTime: Date
    var attendeeCount: Int
    // TODO: Make address optional

    init(eventJson json: [String: Any]) {
        guard let geoloc = json["_geoloc"] as? [String: Any],
            let lat = geoloc["lat"] as? Double,
            let lng = geoloc["lng"] as? Double,
            let address = json["address"] as? String,
            let description = json["description"] as? String,
            let eventImageUrl = json["eventImageURL"] as? String,
            let eventTime = json["eventTime"] as? String,
            let hostDict = json["host"] as? [String: Any],
            let attendeeCount = json["attendeeCount"] as? Int else { fatalError("Malformatted json for event") }
        self.host = UserProfile(userJson: hostDict)
        self.eventImageURL = eventImageUrl
        self.description = description
        self.address = address
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        self.eventTime = Util.stringToDate(dateString: eventTime)
        self.attendeeCount = attendeeCount
    }

    init(_ host: UserProfile,
         _ eventImageURL: String,
         _ description: String,
         _ address: String,
         _ eventTime: Date,
         _ coordinate: CLLocationCoordinate2D) {
        self.host = host
        self.eventImageURL = eventImageURL
        self.description = description
        self.address = address
        self.eventTime = eventTime
        self.coordinate = coordinate
        self.attendeeCount = 0
    }
}
