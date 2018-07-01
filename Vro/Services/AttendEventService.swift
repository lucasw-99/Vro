//
//  AttendEventService.swift
//  Vro
//
//  Created by Lucas Wotton on 6/3/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import FirebaseDatabase

class AttendEventService {
    private static func potentiallyAttendEvent(_ eventPost: EventPost, _ attendee: UserProfile, success: @escaping ( (_ success: Bool) -> () )) {
        let eventPostId = eventPost.eventPostID
        let attendeeUid = attendee.uid
        
        let newAttendee = Attendee(attendeeUid, eventPostId, true, false)
        let potentialEventAttendeePath = String(format: Constants.Database.eventPotentialAttending, eventPostId, attendeeUid)
        let userEventsAttendingPath = String(format: Constants.Database.userEventsAttending, attendeeUid, eventPostId)

        var updates = [String: Any?]()
        updates[potentialEventAttendeePath] = newAttendee.dictValue
        updates[userEventsAttendingPath] = true
        NotificationService.postNotification(forNotification: AttendeeNotification(event: eventPost.event, attendee: attendee, seen: false), notificationId: newAttendee.identifier, withUpdates: updates) { finalUpdates in
            let updateRef = Database.database().reference()
            updateRef.updateChildValues(finalUpdates) { error, _ in
                if error != nil {
                    print("Error with potentially attending event: \(error!.localizedDescription)")
                    return success(false)
                }
                let attendeeCountPath = String(format: Constants.Database.eventAttendeeCount, eventPostId)
                let attendeeCountRef = Database.database().reference().child(attendeeCountPath)
                attendeeCountRef.runTransactionBlock({ mutableData -> TransactionResult in
                    print("attendee mutableData: \(mutableData)")
                    let currentAttendeeCount = mutableData.value as? Int ?? 0
                    mutableData.value = currentAttendeeCount + 1
                    return TransactionResult.success(withValue: mutableData)
                }, andCompletionBlock: { error, _, _ in
                    if let error = error {
                        assertionFailure(error.localizedDescription)
                        success(false)
                    } else {
                        success(true)
                    }
                })
            }
        }
    }

    private static func potentiallyUnattendingEvent(_ eventPost: EventPost, _ attendee: UserProfile, success: @escaping ( (_ success: Bool) -> () )) {
        let eventPostId = eventPost.eventPostID
        let attendeeUid = attendee.uid
        
        let potentialEventAttendeePath = String(format: Constants.Database.eventPotentialAttending, eventPostId, attendeeUid)
        let potentialEventAttendeeRef = Database.database().reference().child(potentialEventAttendeePath)
        let updateRef = Database.database().reference()
        
        potentialEventAttendeeRef.observeSingleEvent(of: .value) { snapshot in
            guard let previousAttendeeDict = snapshot.value as? [String: Any],
                let identifier = previousAttendeeDict["identifier"] as? String else { fatalError("Malformatted JSON for attendee") }
            var updateDict = [String: Any?]()
            let userEventsAttendingPath = String(format: Constants.Database.userEventsAttending, attendeeUid, eventPostId)
            let val: Any? = nil
            updateDict[potentialEventAttendeePath] = val
            updateDict[userEventsAttendingPath] = val
            let finalUpdates = NotificationService.removeNotification(forUser: eventPost.event.host.uid, notificationId: identifier, withUpdates: updateDict)
            
            updateRef.updateChildValues(finalUpdates) { error, _ in
                if error != nil {
                    print("error with unattending event: \(error.debugDescription)")
                    return success(false)
                } else {
                    let attendeeCountPath = String(format: Constants.Database.eventAttendeeCount, eventPostId)
                    let attendeeCountRef = Database.database().reference().child(attendeeCountPath)
                    attendeeCountRef.runTransactionBlock({ mutableData -> TransactionResult in
                        print("attendee mutableData: \(mutableData)")
                        let currentAttendeeCount = mutableData.value as? Int ?? 0
                        mutableData.value = currentAttendeeCount - 1
                        return TransactionResult.success(withValue: mutableData)
                    }, andCompletionBlock: { error, _, _ in
                        if let error = error {
                            assertionFailure(error.localizedDescription)
                            success(false)
                        } else {
                            success(true)
                        }
                    })
                }
            }
        }
    }

    static func isAttendingEvent(_ attendeeUid: String, eventPostID: String, completion: @escaping ( (_ isAttending: Bool) -> Void )) {
        let isAttendingEventPath = String(format: Constants.Database.eventPotentialAttending, eventPostID, attendeeUid)
        let isAttendingEventRef = Database.database().reference().child(isAttendingEventPath)
        isAttendingEventRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    static func setPotentiallyAttending(nowAttendingEvent: Bool, for eventPost: EventPost, success: @escaping ( (_ success: Bool) -> Void )) {
        guard let currentUser = UserService.currentUserProfile else { fatalError("Current user nil") }
        if nowAttendingEvent {
            potentiallyAttendEvent(eventPost, currentUser, success: success)
        } else {
            potentiallyUnattendingEvent(eventPost, currentUser, success: success)
        }
    }
}
