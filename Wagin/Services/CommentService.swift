//
//  CommentService.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/16/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import FirebaseDatabase

class CommentService {
    static func postComment(comment: Comment, success: @escaping ( (_ success: Bool) -> Void )) {
        print("called postComment")
    }

    static func getComment(commentID: String, completion: @escaping ( (_ comment: Comment?) -> Void )) {
        print("Called getComment")
    }
}
