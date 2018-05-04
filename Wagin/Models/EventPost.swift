//
//  EventPost.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/4/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import Foundation
import UIKit

class EventPost {
    let host: UserProfile
    let eventImage: UIImage
    var likedBy: [UserProfile]
    let caption: String

    init(host: UserProfile, eventImage: UIImage, likedBy: [UserProfile], caption: String) {
        self.host = host
        self.eventImage = eventImage
        self.likedBy = likedBy
        self.caption = caption
    }
}
