//
//  EventPost.swift
//  Vro
//
//  Created by Lucas Wotton on 5/4/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class EventPost {
    let event: Event
    let caption: String
    let timestamp: Date
    let eventPostID: String
    let likeCount: Int

    var isLiked: Bool = false
    var isAttending: Bool = false

    var dictValue: [String: Any] {
        let eventPostObject = [
            "event": event.dictValue,
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
            let eventDict = eventPostDict["event"] as? [String: Any],
            let eventPostCaption = eventPostDict["caption"] as? String,
            let eventPostTimestamp = eventPostDict["timestamp"] as? TimeInterval,
            let eventPostID = eventPostDict["eventPostID"] as? String,
            let likeCount = eventPostDict["likeCount"] as? Int else { fatalError("eventPost snapshot was incorrectly formatted") }

        let event = Event(eventJson: eventDict)
        let timestamp = Date(timeIntervalSince1970: eventPostTimestamp / 1000)
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
        self.event = event
        self.caption = caption
        self.timestamp = timestamp
        self.eventPostID = eventPostID
        self.likeCount = 0
    }
}
