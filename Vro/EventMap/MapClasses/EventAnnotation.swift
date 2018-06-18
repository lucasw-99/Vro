//
//  MapAnnotation.swift
//  Vro
//
//  Created by Lucas Wotton on 5/30/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import MapKit
import InstantSearchCore
import AlgoliaSearch

class EventAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var event: Event
    var title: String?
    var subtitle: String?

    init(_ event: Event) {
        self.event = event
        self.coordinate = event.coordinate
        self.title = "Event on \(Util.dateToString(date: event.eventTime))"
        super.init()
        UserService.observeUserProfile(event.host.uid) { host in
            guard let host = host else { fatalError("host was nil") }
            self.subtitle = "Hosted by \(host.username)"
        }
    }

    convenience init(eventJson json: [String: Any]) {
        self.init(Event(eventJson: json))
    }
}
