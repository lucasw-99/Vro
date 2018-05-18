//
//  EventPost.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/4/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

class EventPost {
    let postedByUser: UserProfile
    let event: Event
    let caption: String
    let timestamp: Date
    let eventPostID: String

    init(_ postedByUser: UserProfile,
         _ event: Event,
         _ caption: String,
         _ timestamp: Date,
         _ eventPostID: String) {
        self.postedByUser = postedByUser
        self.event = event
        self.caption = caption
        self.timestamp = timestamp
        self.eventPostID = eventPostID
    }
}
