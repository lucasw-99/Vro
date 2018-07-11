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
    static func addPostToTimelines(_ users: Set<Follower>, _ eventPostId: String, _ hostUid: String, withUpdates updates: [String: Any?], completion: @escaping ( (_ updates: [String: Any?]) -> () )) {
        var newUpdates = updates
        for user in users {
            let uid = user.followerId
            let addToTimelinePath = String(format: Constants.Database.addToTimeline, uid, eventPostId)
            newUpdates[addToTimelinePath] = hostUid
        }
        completion(newUpdates)
    }

    static func updateUserTimeline(_ followedUid: String, _ uid: String, addToTimeline: Bool, withUpdates updates: [String: Any?], completion: @escaping ( (_ newUpdates: [String: Any?]) -> () )) {
        var newUpdates = updates
        UserService.getUserEvents(followedUid) { eventIds in
            for eventId in eventIds {
                let userTimelinePath = String(format: Constants.Database.addToTimeline, uid, eventId)
                let val: Any? = nil
                newUpdates[userTimelinePath] = addToTimeline ? followedUid : val
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
                guard let childSnapshot = child as? DataSnapshot,
                    let eventHostUid = childSnapshot.value as? String else { fatalError("Malformatted event post") }
                let eventId = childSnapshot.key
                EventPostService.getEventForTimeline(eventHostUid, eventId) { eventPost in
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
            }
            // TODO: Use negative timestamps to sort
            dispatchGroup.notify(queue: DispatchQueue.global()) {
                posts.sort { e1, e2 -> Bool in
                    e1.timestamp.compare(e2.timestamp) == .orderedDescending
                }
                completion(posts)
            }
        }
    }
}
