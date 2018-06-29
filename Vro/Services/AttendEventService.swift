//
//  AttendEventService.swift
//  Vro
//
//  Created by Lucas Wotton on 6/3/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import FirebaseDatabase

class AttendEventService {
    private static func potentiallyAttendEvent(_ eventPostId: String, _ attendeeUid: String, success: @escaping ( (_ success: Bool) -> () )) {
        let potentialEventAttendeePath = String(format: Constants.Database.eventPotentialAttending, eventPostId, attendeeUid)
        let potentialEventAttendeeRef = Database.database().reference().child(potentialEventAttendeePath)
        let attendee = Attendee(attendeeUid, eventPostId, true, false)
        potentialEventAttendeeRef.setValue(attendee.dictValue) { error, _ in
            if let error = error {
                assertionFailure(error.localizedDescription)
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
                    return success(false)
                } else {
                    let userEventsAttendingPath = String(format: Constants.Database.userEventsAttending, attendeeUid, eventPostId)
                    let userEventsAttendingRef = Database.database().reference().child(userEventsAttendingPath)

                    userEventsAttendingRef.runTransactionBlock({ mutableData -> TransactionResult in
                        mutableData.value = true
                        return TransactionResult.success(withValue: mutableData)
                    }, andCompletionBlock: { error, _, _ in
                        if let error = error {
                            assertionFailure(error.localizedDescription)
                            return success(false)
                        } else {
                            return success(true)
                        }
                    })
                }
            })
        }
    }

    private static func potentiallyUnattendingEvent(_ eventPostId: String, _ attendeeUid: String, success: @escaping ( (_ success: Bool) -> () )) {
        let potentialEventAttendeePath = String(format: Constants.Database.eventPotentialAttending, eventPostId, attendeeUid)
        let potentialEventAttendeeRef = Database.database().reference().child(potentialEventAttendeePath)

        potentialEventAttendeeRef.removeValue() { error, _ in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return success(false)
            }

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
                    let userEventsAttendingPath = String(format: Constants.Database.userEventsAttending, attendeeUid, eventPostId)
                    let userEventsAttendingRef = Database.database().reference().child(userEventsAttendingPath)

                    userEventsAttendingRef.runTransactionBlock({ mutableData -> TransactionResult in
                        mutableData.value = nil
                        return TransactionResult.success(withValue: mutableData)
                    }, andCompletionBlock: { error, _, _ in
                        if let error = error {
                            assertionFailure(error.localizedDescription)
                            return success(false)
                        } else {
                            return success(true)
                        }
                    })
                }
            })
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

    static func setPotentiallyAttending(nowAttendingEvent: Bool, for eventPostId: String, success: @escaping ( (_ success: Bool) -> Void )) {
        guard let currentUid = UserService.currentUserProfile?.uid else { fatalError("Current user nil") }
        if nowAttendingEvent {
            potentiallyAttendEvent(eventPostId, currentUid, success: success)
        } else {
            potentiallyUnattendingEvent(eventPostId, currentUid, success: success)
        }
    }
}
