//
//  UserService.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/3/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import FirebaseDatabase
import FirebaseAuth
import UIKit

class UserService {

    static var currentUserProfile: UserProfile?

    @available(*, introduced: 0.0)
    static func observeUserProfile(_ uid: String, completion: @escaping ( (_ userProfile: UserProfile?) -> () )) {
        let userPath = String(format: Constants.Database.userProfile, uid)
        print("userPath: \(userPath), uid: \(uid)")
        let userRef = Database.database().reference().child(userPath)

        userRef.observeSingleEvent(of: .value) { snapshot in
            var userProfile: UserProfile?
            if let dict = snapshot.value as? [String: Any],
                let username = dict["username"] as? String,
                let photoURL = dict["photoURL"] as? String {

                guard let url = (URL(string: photoURL) ?? URL(string: Constants.newUserProfilePhotoURL)) else { fatalError("newUserProfilePhotoURL doesn't exist?") }
                userProfile = UserProfile(uid, username, url)
            }
            completion(userProfile)
        }
    }

    static func fetchUser(_ searchUsername: String, completion: @escaping ( (_ userProfile: UserProfile?) -> () )) {
        let userPath = String(format: Constants.Database.users)
        let userRef = Database.database().reference().child(userPath)

        userRef.observeSingleEvent(of: .value) { snapshot in
            var foundUser: UserProfile?
            for child in snapshot.children {
                let childSnapshot = child as! DataSnapshot
                let nextChildSnapshot = snapshot.childSnapshot(forPath: String(format: Constants.Database.getUserProfile, childSnapshot.key))
                if let dict = nextChildSnapshot.value as? [String: Any],
                    let uid = dict["uid"] as? String,
                    let username = dict["username"] as? String,
                    searchUsername == username,
                    let stringPhotoURL = dict["photoURL"] as? String,
                    let photoURL = URL(string: stringPhotoURL) {
                    foundUser = UserProfile(uid, username, photoURL)
                    break
                }
            }
            completion(foundUser)
        }
    }

    // uid: The uid of the user who is logged in
    static func updateCurrentUser(_ uid: String, completion: @escaping ( () -> () )) {
        UserService.observeUserProfile(uid) { userProfile in
            guard let userProfile = userProfile else {
                print("No user with uid \(uid) exists, signing out to delete their auth token.")
                try! Auth.auth().signOut()
                return
            }
            print("userProfile: \(userProfile)")
            if let oldUserProfile = UserService.currentUserProfile,
                oldUserProfile.photoURL != userProfile.photoURL {
                print("Resetting current image")
                // TODO: How to reset user image when other imageviews already have set it???
                ImageService.updateUserImage(userProfile.photoURL)
            } else if UserService.currentUserProfile == nil {
                print("Setting current image")
                ImageService.updateUserImage(userProfile.photoURL)
            }
            UserService.currentUserProfile = userProfile
            print("userProfile has been set")
            completion()
        }
    }

    // uid: Get follower info for user specified by uid
    // userFollowersRef: DatabaseReference for observable, need to hold onto it to remove it
    static func getFollowerInfo(_ uid: String, _ userFollowersRef: DatabaseReference, completion: @escaping ( (_ followerInfo: UserFollowers) -> () )) {
        userFollowersRef.observe(.value) { snapshot in
            var followerInfo: UserFollowers = UserFollowers(uid, Set<String>(), Set<String>())
            if let dict = snapshot.value as? [String: Any] {
                let followersDict = dict["followers"] as? [String: Any] ?? Dictionary<String, Bool>()
                let followingDict = (dict["following"] as? [String: Any]) ?? Dictionary<String, Bool>()
                let followers = Set<String>(followersDict.keys.map { $0 })
                let following = Set<String>(followingDict.keys.map { $0 })
                followerInfo = UserFollowers(uid, followers, following)
            }
            completion(followerInfo)
        }
    }
}
