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

        let followersRef = Database.database().reference().child(followersPath)
        let followingRef = Database.database().reference().child(followingPath)

        if addFollower {
            let follower = Follower(uid)
            followersRef.child(uid).updateChildValues(follower.dictValue)
            followingRef.updateChildValues([followedUid: true])
            // add followedUid posts to uid's timeline
            TimelineService.updateUserTimeline(followedUid, uid, addToTimeline: true) {
                completion()
            }
        } else {
            followersRef.child(uid).removeValue()
            followingRef.child(followedUid).removeValue()
            // remove followedUid posts from uid's timeline
            TimelineService.updateUserTimeline(followedUid, uid, addToTimeline: false) {
                completion()
            }
        }
    }
}
