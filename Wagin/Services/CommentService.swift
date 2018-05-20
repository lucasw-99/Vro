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
        let newCommentPath = String(format: Constants.Database.eventPostComment, comment.eventPostID, comment.commentID)
        let newCommentRef = Database.database().reference().child(newCommentPath)

        newCommentRef.setValue(true) { error, _ in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success(false)
            } else {
                success(true)
            }
        }
    }

    private static func getComment(_ eventPostID: String, _ commentID: String, completion: @escaping ( (_ comment: Comment?) -> Void )) {
        print("Called getComment")
        let getCommentPath = String(format: Constants.Database.eventPostComment, eventPostID, commentID)
        let getCommentRef = Database.database().reference().child(getCommentPath)
        getCommentRef.observeSingleEvent(of: .value) { snapshot in
            var comment: Comment?
            if snapshot.exists() {
                comment = Comment(forSnapshot: snapshot)
            }
            completion(comment)
        }
    }

    /*
     eventPostID: event ID
     completion: Function that receives all comments associated with eventPostID as a parameter
    */
    static func commentsForEvent(_ eventPostID: String, completion: @escaping ( (_ comments: [Comment]) -> Void )) {
        let eventCommentsPath = String(format: Constants.Database.eventComments, eventPostID)
        let eventCommentsRef = Database.database().reference().child(eventCommentsPath)
        eventCommentsRef.observeSingleEvent(of: .value) { snapshot in
            var comments = [Comment]()
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot {
                    let commentID = childSnapshot.key
                    getComment(eventPostID, commentID) { comment in
                        guard let comment = comment else { fatalError("comment was nil") }
                        comments.append(comment)
                    }
                }
            }
            completion(comments)
        }
    }
}
