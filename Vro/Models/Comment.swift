//
//  Comment.swift
//  Vro
//
//  Created by Lucas Wotton on 5/20/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Comment {
    let commentId: String
    let commentText: String
    let commentAuthorId: String
    let eventPostId: String
    let timestamp: Date?

    var dictValue: [String: Any] {
        let commentObject = [
            "commentID": commentId,
            "commentText": commentText,
            "commentAuthorID": commentAuthorId,
            "eventPostID": eventPostId,
            "timestamp": [".sv": "timestamp"]
            ] as [String: Any]

        return commentObject
    }

    // this constructor is used for reading comments
    init(forSnapshot snapshot: DataSnapshot) {
        guard let commentDict = snapshot.value as? [String: Any],
            let commentId = commentDict["commentID"] as? String,
            let commentText = commentDict["commentText"] as? String,
            let commentAuthorId = commentDict["commentAuthorID"] as? String,
            let eventPostId = commentDict["eventPostID"] as? String,
            let timestamp = commentDict["timestamp"] as? TimeInterval else { fatalError("comment snapshot was incorrectly formatted") }

        self.commentId = commentId
        self.commentText = commentText
        self.commentAuthorId = commentAuthorId
        self.eventPostId = eventPostId
        self.timestamp = Date(milliseconds: timestamp)
    }

    // this constructor is used for posting comments
    init(_ commentId: String, _ commentText: String, _ commentAuthorId: String, _ eventPostId: String) {
        self.commentId = commentId
        self.commentText = commentText
        self.commentAuthorId = commentAuthorId
        self.eventPostId = eventPostId
        self.timestamp = nil
    }
}
