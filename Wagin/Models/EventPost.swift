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
    // array of UID's
    var likedBy: [String]
    let caption: String
    let timestamp: Date

    init(postedByUser: UserProfile, event: Event, likedBy: [String], caption: String, timestamp: Date) {
        self.postedByUser = postedByUser
        self.event = event
        self.likedBy = likedBy
        self.caption = caption
        self.timestamp = timestamp
    }
}
