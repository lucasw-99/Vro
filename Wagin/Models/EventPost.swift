//
//  EventPost.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/4/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

class EventPost {
    let postedBy: UserProfile
    let event: Event
    var likedBy: [UserProfile]
    let caption: String
    let dayPosted: Date

    init(postedBy: UserProfile, event: Event, likedBy: [UserProfile], caption: String, dayPosted: Date) {
        self.postedBy = postedBy
        self.event = event
        self.likedBy = likedBy
        self.caption = caption
        self.dayPosted = dayPosted
    }
}
