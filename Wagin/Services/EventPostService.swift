//
//  EventService.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/16/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import FirebaseDatabase

class EventPostService {
    static func setEvent(_ eventPost: EventPost, success: @escaping ( () -> () )) {
        guard eventPost.likeCount == 0 else { fatalError("Like count not zero when posting new event") }

        let eventIDPath = String(format: Constants.Database.eventInfo, eventPost.eventPostID)
        let eventRef = Database.database().reference().child(eventIDPath)

        eventRef.setValue(eventPost.dictValue)

        let userFollowersPath = String(format: Constants.Database.userFollowerInfo, eventPost.event.host.uid)
        let userFollowersRef = Database.database().reference().child(userFollowersPath)
        FollowersService.getFollowerInfo(eventPost.event.host.uid, userFollowersRef) { followerInfo in
            // add this event to all followers timelines
            var followers = followerInfo.followers
            followers.insert(eventPost.event.host.uid)
            TimelineService.addPostToTimelines(followers, eventPost.eventPostID) {
                print("Finished!")
                success()
            }
        }
    }

    // uid: User id
    // eventPostID: Event post ID
    static func setEventPostID(_ uid: String, _ eventPostID: String) {
        let userEventPath = String(format: Constants.Database.userEventPostIDs, uid, eventPostID)
        let eventRef = Database.database().reference().child(userEventPath)

        eventRef.setValue(true)
    }

    static func updateEventPhotoURL(_ eventID: String, _ photoURL: String) {
        let eventPhotoPath = String(format: Constants.Database.userEventPhotoURL, eventID)
        let eventPhotoRef = Database.database().reference().child(eventPhotoPath)

        eventPhotoRef.setValue(photoURL)
    }

    static func getEvent(_ eventID: String, completion: @escaping ( (_ eventPost: EventPost) -> () )) {
        let eventPath = String(format: Constants.Database.eventInfo, eventID)
        let eventRef = Database.database().reference().child(eventPath)

        eventRef.observeSingleEvent(of: .value) { snapshot in
            let eventPost = EventPost(forSnapshot: snapshot)
            completion(eventPost)
        }
    }
}
