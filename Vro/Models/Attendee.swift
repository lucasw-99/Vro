//
//  Attendee.swift
//  Vro
//
//  Created by Lucas Wotton on 6/19/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Attendee {
    let attendeeId: String
    let eventPostId: String
    let potentialAttending: Bool
    let actualAttending: Bool
    let timestamp: Date?
    
    var dictValue: [String: Any] {
        let attendeeObject = [
            "attendeeId": attendeeId,
            "eventPostId": eventPostId,
            "potentialAttending": potentialAttending,
            "actualAttending": actualAttending,
            "timestamp": [".sv": "timestamp"]
            ] as [String: Any]
        
        return attendeeObject
    }
    
    init(forSnapshot snapshot: DataSnapshot) {
        guard let attendeeDict = snapshot.value as? [String: Any],
            let attendeeId = attendeeDict["attendeeId"] as? String,
            let eventPostId = attendeeDict["eventPostId"] as? String,
            let potentialAttending = attendeeDict["potentialAttending"] as? Bool,
            let actualAttending = attendeeDict["actualAttending"] as? Bool,
            let timestamp = attendeeDict["timestamp"] as? TimeInterval else { fatalError("like snapshot was incorrectly formatted") }
        
        self.attendeeId = attendeeId
        self.eventPostId = eventPostId
        self.potentialAttending = potentialAttending
        self.actualAttending = actualAttending
        self.timestamp = Date(timeIntervalSince1970: timestamp / 1000)
    }
    
    init(_ attendeeId: String,
         _ eventPostId: String,
         _ potentialAttending: Bool,
         _ actualAttending: Bool) {
        self.attendeeId = attendeeId
        self.eventPostId = eventPostId
        self.potentialAttending = potentialAttending
        self.actualAttending = actualAttending
        self.timestamp = nil
    }
}
