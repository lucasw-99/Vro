//
//  Event.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/2/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

class Event {
    let host: UserProfile
    let eventImage: UIImage
    let description: String
    let address: String?
    let eventTime: Date

    init(host: UserProfile, eventImage: UIImage, description: String, address: String?, eventTime: Date) {
        self.host = host
        self.eventImage = eventImage
        self.description = description
        self.address = address
        self.eventTime = eventTime
    }
}
