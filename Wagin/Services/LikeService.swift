//
//  LikeService.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/16/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import FirebaseDatabase

class LikeService {

    // likedPostUID: uid of the user who liked the post
    // posterUID: uid of the user who posted the post
    // eventID: ID of the event post
    static func updateLikesForPost(_ likedPostUID: String, _ postedByUID: String, eventPostID: String, likedPost: Bool) {
        let postLikesPath = String(format: Constants.Database.userPostLikes, postedByUID, eventPostID)
        let postLikesRef = Database.database().reference().child(postLikesPath)

        if likedPost {
            postLikesRef.setValue([likedPostUID: true])
        } else {
            postLikesRef.child(likedPostUID).removeValue()
        }
    }

    static func getLikesForPost(_ postedByUID: String, _ eventPostID: String, completion: @escaping ( (_ userLikes: [String: Any], _ databaseRef: DatabaseReference) -> () )) {
        let postLikesPath = String(format: Constants.Database.userPostLikes, postedByUID, eventPostID)
        let postLikesRef = Database.database().reference().child(postLikesPath)

        postLikesRef.observe(.value) { snapshot in
            // TODO: DOES THIS WORK
            let userLikes = (snapshot.value as? [String: Any]) ?? [String: Any]()
            completion(userLikes, postLikesRef)
        }
    }
}
