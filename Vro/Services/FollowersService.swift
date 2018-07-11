//
//  FollowersService.swift
//  Vro
//
//  Created by Lucas Wotton on 5/16/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import FirebaseDatabase

class FollowersService {
    // uid: Get follower info for user specified by uid
    // userFollowersRef: DatabaseReference for observable, need to hold onto it to remove it
    static func getFollowerInfo(_ uid: String, _ userFollowersRef: DatabaseReference, completion: @escaping ( (_ followerInfo: UserFollowers) -> () )) {
        userFollowersRef.observe(.value) { snapshot in
            var followerInfo: UserFollowers = UserFollowers(uid, Set<Follower>(), Set<String>())
            if snapshot.exists() {
                followerInfo = UserFollowers(forUser: uid, forSnapshot: snapshot)
            }
            completion(followerInfo)
        }
    }

    static func updateFollowers(uid: String, followedUid: String, addFollower: Bool, completion: @escaping ( () -> () )) {
        // edit the selectedUser's followers list, and the currentUser's following list
        let followersPath = String(format: Constants.Database.userFollowers, followedUid)
        let followingPath = String(format: Constants.Database.userFollowing, uid)
        let updateRef = Database.database().reference()

        var updates = [String: Any?]()
        if addFollower {
            let follower = Follower(uid)
            updates[followersPath] = [uid: follower.dictValue]
            updates[followingPath] = [followedUid: true]
            // add followedUid posts to uid's timeline
            print("updates: \(updates)")
            TimelineService.updateUserTimeline(followedUid, uid, addToTimeline: true, withUpdates: updates) { newUpdates in
                NotificationService.postNotification(forNotification: FollowerNotification(followedUserUid: followedUid, followerUid: uid, seen: false, notificationId: uid), withUpdates: newUpdates) { finalUpdates in
                    // map values removes implicit coercion from Any? to Any warning
                    updateRef.updateChildValues(finalUpdates.mapValues { $0 as Any })
                    completion()
                }
            }
        } else {
            updates[followersPath] = [uid: nil]
            updates[followingPath] = [followedUid: nil]
            // remove followedUid posts from uid's timeline
            TimelineService.updateUserTimeline(followedUid, uid, addToTimeline: false, withUpdates: updates) { newUpdates in
                let finalUpdates = NotificationService.removeNotification(forUser: followedUid, notificationId: uid, withUpdates: newUpdates).mapValues { $0 as Any }
                updateRef.updateChildValues(finalUpdates)
                completion()
            }
        }
    }
}
