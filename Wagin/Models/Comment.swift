//
//  Comment.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/20/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Comment {
    let commentID: String
    let eventPostID: String
    let eventPostAuthorID: String
    let authorUsername: String
    let comment: String

    init(forSnapshot snapshot: DataSnapshot) {
        guard let commentDict = snapshot.value as? [String: Any],
            let commentID = commentDict["commentID"] as? String,
            let eventPostID = commentDict["eventPostID"] as? String,
            let eventPostAuthorID = commentDict["eventPostAuthorID"] as? String,
            let authorUsername = commentDict["authorUsername"] as? String,
            let comment = commentDict["comment"] as? String else { fatalError("comment snapshot was incorrectly formatted") }

        self.commentID = commentID
        self.eventPostID = eventPostID
        self.eventPostAuthorID = eventPostAuthorID
        self.authorUsername = authorUsername
        self.comment = comment
    }

    init(_ commentID: String, _ eventPostID: String, _ eventPostAuthorID: String, _ authorUsername: String, _ comment: String) {
        self.commentID = commentID
        self.eventPostID = eventPostID
        self.eventPostAuthorID = eventPostAuthorID
        self.authorUsername = authorUsername
        self.comment = comment
    }
}
