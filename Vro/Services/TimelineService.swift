//
//  TimelineServic.swift
//  Vro
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
    static func addPostToTimelines(_ users: Set<Follower>, _ eventPostID: String, completion: @escaping ( () -> () )) {
        for user in users {
            let uid = user.followerId
            let addToTimelinePath = String(format: Constants.Database.addToTimeline, uid, eventPostID)
            let timelineRef = Database.database().reference().child(addToTimelinePath)
            // set to true, so bottom level of firebase database is dictionary of [String: Bool]
            timelineRef.setValue(true)
        }
        completion()
    }

    static func updateUserTimeline(_ uidToAdd: String, _ uid: String, addToTimeline: Bool, updates: [String: Any?], completion: @escaping ( (_ newUpdates: [String: Any?]) -> () )) {
        var newUpdates = updates
        UserService.getUserEvents(uidToAdd) { eventIds in
            for eventId in eventIds {
                // TODO: Make this more efficient
                let userTimelinePath = String(format: Constants.Database.addToTimeline, uid, eventId)
                let val: Any? = nil
                newUpdates[userTimelinePath] = addToTimeline ? true : val
            }
            completion(newUpdates)
        }
    }

    // currentUid: uid of user
    // timelineObservable: The observable used to observe the timeline
    // Populates a users timeline with an observable
    static func populateUserTimeline(_ currentUid: String, _ timelineObservable: DatabaseReference, completion: @escaping ( (_ posts: [EventPost]) -> () )) {
        timelineObservable.observe(.value) { snapshot in
            var posts = [EventPost]()
            let dispatchGroup = DispatchGroup()
            for child in snapshot.children {
                // enter twice, once for likes other for attending
                dispatchGroup.enter()
                dispatchGroup.enter()
                if let childSnapshot = child as? DataSnapshot {
                    let eventID = childSnapshot.key
                    EventPostService.getEventForTimeline(eventID) { eventPost in
                        posts.append(eventPost)
                        LikeService.isPostLiked(eventPost.event.host.uid, eventPostID: eventPost.eventPostID, uid: currentUid) { isLiked in
                            print("isLiked: \(isLiked), caption: \(eventPost.caption), id: \(eventPost.eventPostID)\n")
                            eventPost.isLiked = isLiked
                            dispatchGroup.leave()
                        }

                        AttendEventService.isAttendingEvent(currentUid, eventPostID: eventPost.eventPostID) { isAttending in
                            eventPost.isAttending = isAttending
                            dispatchGroup.leave()
                        }
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
