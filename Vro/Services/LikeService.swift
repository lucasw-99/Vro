//
//  LikeService.swift
//  Vro
//
//  Created by Lucas Wotton on 5/16/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import FirebaseDatabase

class LikeService {
    static func getLikesForPost(_ postedByUID: String, _ eventPostID: String, completion: @escaping ( (_ userLikes: [String: Like], _ databaseRef: DatabaseReference) -> () )) {
        let postLikesPath = String(format: Constants.Database.postLikes, postedByUID, eventPostID)
        let postLikesRef = Database.database().reference().child(postLikesPath)

        postLikesRef.observe(.value) { snapshot in
            // TODO: DOES THIS WORK
            let userLikes = (snapshot.value as? [String: Like]) ?? [String: Like]()
            print("userLikes: \(userLikes), snapshot: \(snapshot)\n")
            completion(userLikes, postLikesRef)
        }
    }

    static func likePost(for post: EventPost, currentUser uid: String, success: @escaping ( (_ success: Bool) -> Void )) {
        let eventPostID = post.eventPostID
        let likesPath = String(format: Constants.Database.userPostLikes, post.event.host.uid, eventPostID, uid)
        let likesRef = Database.database().reference().child(likesPath)
        let likeDict = Like(uid, eventPostID).dictValue

        likesRef.setValue(likeDict) { error, _ in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return success(false)
            }
            let likeCountPath = String(format: Constants.Database.eventLikeCount, eventPostID)
            let likeCountRef = Database.database().reference().child(likeCountPath)
            likeCountRef.runTransactionBlock({ mutableData -> TransactionResult in
                let currentLikeCount = mutableData.value as? Int ?? 0
                mutableData.value = currentLikeCount + 1
                print("setting num likes to \(currentLikeCount + 1)")
                return TransactionResult.success(withValue: mutableData)
            }, andCompletionBlock: { error, _, _ in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    success(false)
                } else {    
                    success(true)
                }
            })
        }
    }

    private static func unlikePost(for eventPost: EventPost, currentUser uid: String, success: @escaping ( (_ success: Bool) -> Void )) {
        let eventPostID = eventPost.eventPostID
        let likesPath = String(format: Constants.Database.userPostLikes, eventPost.event.host.uid, eventPostID, uid)
        let likesRef = Database.database().reference().child(likesPath)

        likesRef.removeValue() { error, _ in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return success(false)
            }
            let likeCountPath = String(format: Constants.Database.eventLikeCount, eventPostID)
            let likeCountRef = Database.database().reference().child(likeCountPath)
            likeCountRef.runTransactionBlock({ mutableData -> TransactionResult in
                let currentLikeCount = mutableData.value as? Int ?? 0
                mutableData.value = currentLikeCount - 1
                print("setting num likes to \(currentLikeCount - 1)")
                return TransactionResult.success(withValue: mutableData)
            }, andCompletionBlock: { error, _, _ in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    success(false)
                } else {
                    success(true)
                }
            })
        }
    }

    /*
     postedByUID: uid of the user who posted the event
     eventPostID: Id of the event post
     uid: uid of the user who we want to determine if they liked the event
     Determines whether user associated with `uid` liked post with `eventPostID`
    */
    static func isPostLiked(_ postedByUID: String, eventPostID: String, uid: String, completion: @escaping ( (_ isLiked: Bool) -> Void )) {
        let isPostLikedPath = String(format: Constants.Database.userPostLikes, postedByUID, eventPostID, uid)
        let isPostLikedRef = Database.database().reference().child(isPostLikedPath)
        isPostLikedRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                print("eventPostID \(eventPostID) like exists\n")
                completion(true)
            } else {
                print("eventPostID \(eventPostID) like does not exist\n")
                completion(false)
            }
        }
    }

    static func setLiked(didLikePost: Bool, for post: EventPost, success: @escaping ( (_ success: Bool) -> Void )) {
        guard let currentUid = UserService.currentUserProfile?.uid else { fatalError("Current user nil") }
        if didLikePost {
            print("Liking post: \(post.eventPostID)\n")
            likePost(for: post, currentUser: currentUid, success: success)
        } else {
            print("unliking post: \(post.eventPostID)\n")
            unlikePost(for: post, currentUser: currentUid, success: success)
        }
    }
}
