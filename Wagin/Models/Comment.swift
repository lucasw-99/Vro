//
//  Comment.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/20/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import Foundation

class Comment {
    let commentID: String
    let eventPostID: String
    let eventPostAuthorID: String
    let authorUsername: String
    let comment: String

    init(_ commentID: String, _ eventPostID: String, _ eventPostAuthorID: String, _ authorUsername: String, _ comment: String) {
        self.commentID = commentID
        self.eventPostID = eventPostID
        self.eventPostAuthorID = eventPostAuthorID
        self.authorUsername = authorUsername
        self.comment = comment
    }
}
