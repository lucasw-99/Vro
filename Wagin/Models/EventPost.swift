//
//  EventPost.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/4/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class EventPost {
    let postedByUser: UserProfile
    let event: Event
    let caption: String
    let timestamp: Date
    let eventPostID: String
    let likeCount: Int
    var isLiked: Bool = false

    var dictValue: [String: Any] {
        let eventTimeString = Util.dateToString(date: event.eventTime)

        let eventPostObject = [
            "postedByUser": [
                "uid": postedByUser.uid,
                "username": postedByUser.username,
                "photoURL": postedByUser.photoURL.absoluteString
            ],
            "event": [
                "hostUID": event.hostUID,
                // TODO: Change this to a valid description of event
                "description": event.description,
                "address": event.address,
                "_geoloc": [
                    "lat": event.coordinate.latitude,
                    "lng": event.coordinate.longitude
                ],
                "eventImageURL": event.eventImageURL,
                "eventTime": eventTimeString
            ],
            "likeCount": likeCount,
            "caption": caption,
            // TODO: Store timestamp as negative value to sort from most recent to least recent?
            "timestamp": [".sv": "timestamp"],
            "eventPostID": eventPostID
            ] as [String: Any]

        return eventPostObject
    }

    init(forSnapshot snapshot: DataSnapshot) {
        guard let eventPostDict = snapshot.value as? [String: Any],
            let postedByUserDict = eventPostDict["postedByUser"] as? [String: Any],
            let postedByUID = postedByUserDict["uid"] as? String,
            let postedByUsername = postedByUserDict["username"] as? String,
            let postedByPhotoURLString = postedByUserDict["photoURL"] as? String,
            let postedByPhotoURL = URL(string: postedByPhotoURLString),
            let eventDict = eventPostDict["event"] as? [String: Any],
            let hostUID = eventDict["hostUID"] as? String,
            let eventDescription = eventDict["description"] as? String,
            let eventAddress = eventDict["address"] as? String,
            let eventImageURL = eventDict["eventImageURL"] as? String,
            let eventTime = eventDict["eventTime"] as? String,
            let coordinateDict = eventDict["_geoloc"] as? [String: Any],
            let latitude = coordinateDict["lat"] as? CLLocationDegrees,
            let longitude = coordinateDict["lng"] as? CLLocationDegrees,
            let eventPostCaption = eventPostDict["caption"] as? String,
            let eventPostTimestamp = eventPostDict["timestamp"] as? TimeInterval,
            let eventPostID = eventPostDict["eventPostID"] as? String,
            let likeCount = eventPostDict["likeCount"] as? Int else { fatalError("eventPost snapshot was incorrectly formatted") }

            let eventDate = Util.stringToDate(dateString: eventTime)
            let timestamp = Date(timeIntervalSince1970: eventPostTimestamp / 1000)
            let postedByUser = UserProfile(postedByUID, postedByUsername, postedByPhotoURL)
            let eventCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let event = Event(hostUID, eventImageURL, eventDescription, eventAddress, eventDate, eventCoordinate)

            self.postedByUser = postedByUser
            self.event = event
            self.caption = eventPostCaption
            self.timestamp = timestamp
            self.eventPostID = eventPostID
            self.likeCount = likeCount
    }

    // init method for just posted events
    init(_ event: Event,
         _ caption: String,
         _ timestamp: Date,
         _ eventPostID: String) {
        guard let currentUser = UserService.currentUserProfile else { fatalError("user nil") }
        self.postedByUser = currentUser
        self.event = event
        self.caption = caption
        self.timestamp = timestamp
        self.eventPostID = eventPostID
        self.likeCount = 0
    }
}
