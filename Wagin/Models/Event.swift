//
//  Event.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/2/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

class Event {
    let hostUID: String
    let eventImageURL: String
    let description: String
    let address: String
    let eventTime: Date
    // TODO: Make address optional, and add coordinate field

    init(_ hostUID: String,
         _ eventImageURL: String,
         _ description: String,
         _ address: String,
         _ eventTime: Date) {
        self.hostUID = hostUID
        self.eventImageURL = eventImageURL
        self.description = description
        self.address = address
        self.eventTime = eventTime
    }
}
