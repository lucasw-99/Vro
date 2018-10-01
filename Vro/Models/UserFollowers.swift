//
//  UserFollowers.swift
//  Vro
//
//  Created by Lucas Wotton on 5/15/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import Foundation
import UIKit

class UserFollowers {
    let uid: Int
    var followers: [Int]
    var following: [Int]
    
    convenience init(_ uid: Int) {
        self.init(uid, [], [])
    }
    
    init(_ uid: Int, _ followers: [Int], _ following: [Int]) {
        self.uid = uid
        self.followers = followers
        self.following = following
    }
//    
//    init(forUser uid: String, forSnapshot snapshot: DataSnapshot) {
//        guard let userFollowersDict = snapshot.value as? [String: Any] else { fatalError("userFollowers snapshot was incorrectly formatted") }
//        
//        var followers = [String: Follower]()
//        if let strFollowers = userFollowersDict["followers"] as? [String: Any] {
//            for strFollower in strFollowers.values {
//                guard let followerDict = strFollower as? [String: Any] else { fatalError("Malformatted data for followers") }
//                let follower = Follower(forDict: followerDict)
//                followers[follower.followerId] = follower
//            }
//        }
//        let following = userFollowersDict["following"] as? [String: Bool] ?? [String: Bool]()
//        
//        self.uid = 1
//        self.followers = []
//        self.following = []
//    }
}

