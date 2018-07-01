//
//  CommentService.swift
//  Vro
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
    static func postComment(text commentText: String, eventPost: EventPost, success: @escaping ( (_ success: Bool) -> Void )) {
        print("called postComment")
        let eventPostId = eventPost.eventPostID
        let commentID = Util.generateId()
        guard let commentAuthor = UserService.currentUserProfile else { fatalError("Current user nil") }
        let commentAuthorUid = commentAuthor.uid
        
        let newCommentPath = String(format: Constants.Database.postComment, commentID)
        let newCommentRef = Database.database().reference().child(newCommentPath)
        let comment = Comment(commentID, commentText, commentAuthorUid, eventPostId)

        // TODO: Nest this and run a transaction block
        newCommentRef.setValue(comment.dictValue) { error, _ in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success(false)
                return
            }
        }

        let newPostCommentPath = String(format: Constants.Database.eventPostComment, comment.eventPostId, comment.commentId)
        let newPostCommentRef = Database.database().reference().child(newPostCommentPath)

        newPostCommentRef.setValue(true) { error, _ in
            if let error = error {
                assertionFailure(error.localizedDescription)
                success(false)
            } else {
                NotificationService.postNotification(forNotification: CommentNotification(commentedPost: eventPost, user: commentAuthor, seen: false), notificationId: comment.commentId)
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
    static func commentsForEvent(_ eventPost: EventPost, completion: @escaping ( (_ comments: [Comment]) -> Void )) {
        let eventPostId = eventPost.eventPostID
        
        let eventCommentsPath = String(format: Constants.Database.eventPostComments, eventPostId)
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
                    guard let d1 = c1.timestamp, let d2 = c2.timestamp else { fatalError("Dates nil when they shouldn't be") }
                    return d1.compare(d2) == .orderedAscending
                }
                completion(comments)
            }
        }
    }
}
