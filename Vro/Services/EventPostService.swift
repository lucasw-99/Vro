//
//  EventService.swift
//  Vro
//
//  Created by Lucas Wotton on 5/16/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import FirebaseDatabase

class EventPostService {
    static func setEvent(_ eventPost: EventPost, withUpdates updates: [String: Any?], completion: @escaping ( (_ updates: [String: Any?]) -> () )) {
        guard eventPost.likeCount == 0 else { fatalError("Like count not zero when posting new event") }

        let eventIdPath = String(format: Constants.Database.eventInfo, eventPost.event.host.uid, eventPost.eventPostID)
        var newUpdates = updates
        newUpdates[eventIdPath] = eventPost.dictValue
        
        let userFollowersPath = String(format: Constants.Database.userFollowerInfo, eventPost.event.host.uid)
        let userFollowersRef = Database.database().reference().child(userFollowersPath)
        FollowersService.getFollowerInfo(eventPost.event.host.uid, userFollowersRef) { followerInfo in
            // add this event to all followers timelines
            var followers = followerInfo.followers
            let currentUser = Follower(eventPost.event.host.uid)
            followers.insert(currentUser)
            TimelineService.addPostToTimelines(followers, eventPost.eventPostID, eventPost.event.host.uid, withUpdates: newUpdates) { finalUpdates in
                completion(finalUpdates)
            }
        }
    }

    static func updateEventPhotoURL(_ hostUid: String, _ eventPostId: String, _ photoURL: String) {
        let eventPhotoPath = String(format: Constants.Database.userEventPhotoURL, hostUid, eventPostId)
        let eventPhotoRef = Database.database().reference().child(eventPhotoPath)

        eventPhotoRef.setValue(photoURL)
    }

    static func getEventForTimeline(_ hostUid: String, _ eventPostId: String, completion: @escaping ( (_ eventPost: EventPost) -> () )) {
        // TODO: Just return all events with new database design
        let eventPath = String(format: Constants.Database.eventInfo, hostUid, eventPostId)
        let eventRef = Database.database().reference().child(eventPath)
        eventRef.observeSingleEvent(of: .value) { snapshot in
            let eventPost = EventPost(forSnapshot: snapshot)
            completion(eventPost)
        }
    }
    
    static func getUserEvents(_ uid: String, completion: @escaping ( (_ eventPosts: [EventPost]) -> () )) {
        let userEventsPath = String(format: Constants.Database.userEvents, uid)
        let userEventsRef = Database.database().reference().child(userEventsPath)
        
        var eventPosts = [EventPost]()
        userEventsRef.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children {
                guard let childSnapshot = child as? DataSnapshot else { fatalError("Malformatted snapshot") }
                let eventPost = EventPost(forSnapshot: childSnapshot)
                eventPosts.append(eventPost)
            }
            completion(eventPosts)
        }
    }
}
