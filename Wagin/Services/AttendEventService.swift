//
//  AttendEventService.swift
//  Wagin
//
//  Created by Lucas Wotton on 6/3/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import FirebaseDatabase

class AttendEventService {
    static func potentiallyAttendEvent(_ eventId: String, _ attendeeUid: String, completion: @escaping ( () -> () )) {
        let potentialEventAttendeePath = String(format: Constants.Database.eventPotentialAttending, eventId, attendeeUid)
        let potentialEventAttendeeRef = Database.database().reference().child(potentialEventAttendeePath)
        // TODO: Finish implementation
    }

    static func actuallyAttendedEvent() {

    }
}
