//
//  UserFollowers.swift
//  Vro
//
//  Created by Lucas Wotton on 5/15/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class UserFollowers {
    let uid: String
    var followers: Set<Follower>
    // set of uid's
    var following: Set<String>
    
    init(_ uid: String, _ followers: Set<Follower>, _ following: Set<String>) {
        self.uid = uid
        self.followers = followers
        self.following = following
    }
    
    init(forUser uid: String, forSnapshot snapshot: DataSnapshot) {
        guard let userFollowersDict = snapshot.value as? [String: Any] else { fatalError("userFollowers snapshot was incorrectly formatted") }
        
        var followers = [String: Follower]()
        if let strFollowers = userFollowersDict["followers"] as? [String: Any] {
            for strFollower in strFollowers.values {
                guard let followerDict = strFollower as? [String: Any] else { fatalError("Malformatted data for followers") }
                let follower = Follower(forDict: followerDict)
                followers[follower.followerId] = follower
            }
        }
        let following = userFollowersDict["following"] as? [String: Bool] ?? [String: Bool]()
        
        self.uid = uid
        self.followers = Set<Follower>(followers.values)
        self.following = Set<String>(following.keys)
    }
}

