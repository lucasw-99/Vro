//
//  CommentService.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/16/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import FirebaseDatabase

class CommentService {

    /*
     commentText: A comment to be posted
     eventPostID: The Event Post ID the comment was posted to
     success: A function called with param of true if both writes succeed
    */
    static func postComment(text commentText: String, eventPostID: String, success: @escaping ( (_ success: Bool) -> Void )) {
        print("called postComment")
        let commentID = Util.generateID()
        guard let commentAuthorUID = UserService.currentUserProfile?.uid else { fatalError("Current user nil") }

        let newCommentPath = String(format: Constants.Database.postComment, commentID)
        let newCommentRef = Database.database().reference().child(newCommentPath)
        let comment = Comment(commentID, commentText, commentAuthorUID, eventPostID)

        newCommentRef.setValue(comment.dictValue) { error, _ in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success(false)
                return
            }
        }

        let newPostCommentPath = String(format: Constants.Database.eventPostComment, comment.eventPostID, comment.commentID)
        let newPostCommentRef = Database.database().reference().child(newPostCommentPath)

        newPostCommentRef.setValue(true) { error, _ in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success(false)
            } else {
                success(true)
            }
        }
    }

    private static func getComment(_ commentID: String, completion: @escaping ( (_ comment: Comment?) -> Void )) {
        print("Called getComment")
        let getCommentPath = String(format: Constants.Database.postComment, commentID)
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
        let eventCommentsPath = String(format: Constants.Database.eventPostComments, eventPostID)
        let eventCommentsRef = Database.database().reference().child(eventCommentsPath)
        let dispatchGroup = DispatchGroup()
        eventCommentsRef.observeSingleEvent(of: .value) { snapshot in
            var comments = [Comment]()
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot {
                    dispatchGroup.enter()
                    let commentID = childSnapshot.key
                    getComment(commentID) { comment in
                        guard let comment = comment else { fatalError("comment was nil") }
                        comments.append(comment)
                        dispatchGroup.leave()
                    }
                }
            }
            dispatchGroup.notify(queue: DispatchQueue.global()) {
                comments.sort { c1, c2 -> Bool in
                    c1.timestamp.compare(c2.timestamp) == .orderedAscending
                }
                completion(comments)
            }
        }
    }
}
