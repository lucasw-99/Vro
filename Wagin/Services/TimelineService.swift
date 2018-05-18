//
//  TimelineServic.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/16/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import Foundation
import FirebaseDatabase

class TimelineService {

    // users: List of uid's, where each uid is a user following the user
    // who was the author of the post with eventPostID
    // eventPostID: Id of the post
    static func addPostToTimelines(_ users: Set<String>, _ eventPostID: String, completion: @escaping ( () -> () )) {
        for uid in users {
            let addToTimelinePath = String(format: Constants.Database.addToTimeline, uid, eventPostID)
            let timelineRef = Database.database().reference().child(addToTimelinePath)
            // set to true, so bottom level of firebase database is dictionary of [String: Bool]
            timelineRef.setValue(true)
        }
        completion()
    }

    static func updateUserTimeline(_ uidToAdd: String, _ uid: String, addToTimeline: Bool, completion: @escaping ( () -> () )) {
        let userTimelinePath = String(format: Constants.Database.getTimelinePosts, uid)
        let userTimelineRef = Database.database().reference().child(userTimelinePath)
        UserService.getUserEvents(uidToAdd) { eventID in
            guard let eventID = eventID else { fatalError("eventID nil") }
            if addToTimeline {
                userTimelineRef.updateChildValues([eventID: true])
            } else {
                userTimelineRef.child(eventID).removeValue()
            }
        }
        completion()
    }

    // uid: uid of user
    // Populates a users timeline with an observable
    static func populateUserTimeline(_ uid: String, _ timelineObservable: DatabaseReference, completion: @escaping ( (_ posts: [EventPost]) -> () )) {
        timelineObservable.observe(.value) { snapshot in
            var posts = [EventPost]()
            let dispatchGroup = DispatchGroup()
            for child in snapshot.children {
                print("Calling enter on dispatch queue")
                dispatchGroup.enter()
                if let childSnapshot = child as? DataSnapshot {
                    let eventID = childSnapshot.key
                    EventPostService.getEvent(eventID) { event in
                        posts.append(event)
                        print("Calling leave on dispatch queue")
                        dispatchGroup.leave()
                    }
                } else {
                    fatalError("eventID existed in TL but it was nil?")
                }
            }
            dispatchGroup.notify(queue: DispatchQueue.global()) {
                posts.sort { e1, e2 -> Bool in
                    e1.timestamp.compare(e2.timestamp) == .orderedDescending
                }
                completion(posts)
            }
        }
    }
}
