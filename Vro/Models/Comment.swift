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
    let commentID: String
    let commentText: String
    let commentAuthorID: String
    let eventPostID: String
    let timestamp: Date

    var dictValue: [String: Any] {
        let commentObject = [
            "commentID": commentID,
            "commentText": commentText,
            "commentAuthorID": commentAuthorID,
            "eventPostID": eventPostID,
            "timestamp": [".sv": "timestamp"]
            ] as [String: Any]

        return commentObject
    }

    // this constructor is used for reading comments
    init(forSnapshot snapshot: DataSnapshot) {
        guard let commentDict = snapshot.value as? [String: Any],
            let commentID = commentDict["commentID"] as? String,
            let commentText = commentDict["commentText"] as? String,
            let commentAuthorID = commentDict["commentAuthorID"] as? String,
            let eventPostID = commentDict["eventPostID"] as? String,
            let timestamp = commentDict["timestamp"] as? TimeInterval else { fatalError("comment snapshot was incorrectly formatted") }

        self.commentID = commentID
        self.commentText = commentText
        self.commentAuthorID = commentAuthorID
        self.eventPostID = eventPostID
        self.timestamp = Date(timeIntervalSince1970: timestamp / 1000)
    }

    // this constructor is used for posting comments
    init(_ commentID: String, _ commentText: String, _ commentAuthorID: String, _ eventPostID: String) {
        self.commentID = commentID
        self.commentText = commentText
        self.commentAuthorID = commentAuthorID
        self.eventPostID = eventPostID
        // TODO: Placeholder, because timestamp dynamically generated when posting
        self.timestamp = Date()
    }
}
