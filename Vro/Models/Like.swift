//
//  Like.swift
//  Vro
//
//  Created by Lucas Wotton on 6/19/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Like {
    let identifier: String
    let likeAuthorId: String
    let eventPostId: String
    let timestamp: Date?
    
    var dictValue: [String: Any] {
        let likeObject = [
            "identifier": identifier,
            "likeAuthorId": likeAuthorId,
            "eventPostId": eventPostId,
            "timestamp": [".sv": "timestamp"]
            ] as [String: Any]
        
        return likeObject
    }
    
    init(forSnapshot snapshot: DataSnapshot) {
        guard let likeDict = snapshot.value as? [String: Any],
            let identifier = likeDict["identifier"] as? String,
            let likeAuthorId = likeDict["likeAuthorId"] as? String,
            let eventPostId = likeDict["eventPostId"] as? String,
            let timestamp = likeDict["timestamp"] as? TimeInterval else { fatalError("like snapshot was incorrectly formatted") }
        
        self.identifier = identifier
        self.likeAuthorId = likeAuthorId
        self.eventPostId = eventPostId
        self.timestamp = Date(milliseconds: timestamp)
    }
    
    init(_ likeAuthorId: String, _ eventPostId: String) {
        self.identifier = Util.generateId()
        self.likeAuthorId = likeAuthorId
        self.eventPostId = eventPostId
        self.timestamp = nil
    }
}
