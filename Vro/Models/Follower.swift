//
//  Follower.swift
//  Vro
//
//  Created by Lucas Wotton on 6/19/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Follower: Hashable {
    let followerId: String
    var timestamp: Date?
    
    var hashValue: Int {
        return followerId.hashValue
    }
    
    static func == (lhs: Follower, rhs: Follower) -> Bool {
        return lhs.followerId == rhs.followerId
    }
    
    var dictValue: [String: Any] {
        let followerObject = [
            "followerId": followerId,
            "timestamp": [".sv": "timestamp"]
            ] as [String: Any]
        
        return followerObject
    }
    
    // this constructor is used for reading comments
    init(forDict followerDict: [String: Any]) {
        guard let followerId = followerDict["followerId"] as? String,
            let timestamp = followerDict["timestamp"] as? TimeInterval else { fatalError("follower dict was incorrectly formatted") }
        
        self.followerId = followerId
        self.timestamp = Date(timeIntervalSince1970: timestamp / 1000)
    }
    
    // this constructor is used for posting comments
    init(_ followerId: String) {
        self.followerId = followerId
    }
}
