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

        userRef.observe(.value, with: { snapshot in
            var userProfile: UserProfile?
            if let dict = snapshot.value as? [String: Any],
                let username = dict["username"] as? String,
                let photoURL = dict["photoURL"] as? String {

                let (followers, following) = Util.getFollowers(dict)
                let url = URL(string: photoURL) ?? URL(string: Constants.newUserProfilePhotoURL)
                userProfile = UserProfile(uid, username, url!, followers, following)
            }
            completion(userProfile)
        })
    }

    static func fetchUser(_ searchUsername: String, completion: @escaping ( (_ userProfile: UserProfile?) -> () )) {
        let userPath = String(format: Constants.Database.users)
        let userRef = Database.database().reference().child(userPath)

        userRef.observeSingleEvent(of: .value) { snapshot in
            var foundUser: UserProfile?
            for child in snapshot.children {
                let childSnapshot = child as! DataSnapshot
                if let nextChildSnapshot = snapshot.childSnapshot(forPath: String(format: Constants.Database.getUserProfile, childSnapshot.key)) as? DataSnapshot,
                    let dict = nextChildSnapshot.value as? [String: Any],
                    let uid = dict["uid"] as? String,
                    let username = dict["username"] as? String,
                    searchUsername == username,
                    let stringPhotoURL = dict["photoURL"] as? String,
                    let photoURL = URL(string: stringPhotoURL) {
                    let (followers, following) = Util.getFollowers(dict)
                    foundUser = UserProfile(uid, username, photoURL, followers, following)
                    break
                }
            }
            completion(foundUser)
        }
    }

    // uid: The uid of the user who is logged in
    static func updateCurrentUser(_ uid: String) {
        UserService.observeUserProfile(uid, completion: { userProfile in
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
        })
    }
}
