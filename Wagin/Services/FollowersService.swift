//
//  FollowersService.swift
//  Wagin
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
            var followerInfo: UserFollowers = UserFollowers(uid, Set<String>(), Set<String>())
            if let dict = snapshot.value as? [String: Any] {
                let followersDict = dict["followers"] as? [String: Any] ?? Dictionary<String, Bool>()
                let followingDict = (dict["following"] as? [String: Any]) ?? Dictionary<String, Bool>()
                let followers = Set<String>(followersDict.keys.map { $0 })
                let following = Set<String>(followingDict.keys.map { $0 })
                followerInfo = UserFollowers(uid, followers, following)
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
            followersRef.updateChildValues([uid: true])
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
