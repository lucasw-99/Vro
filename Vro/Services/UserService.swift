//
//  UserService.swift
//  Vro
//
//  Created by Lucas Wotton on 5/3/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import FirebaseDatabase
import FirebaseAuth
import UIKit

class UserService {

    static var currentUserProfile: UserProfile?
    static var currentUserToken: String?

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
    
    static func loginUser(_ currentUser: UserProfile, _ token: String) {
        currentUserProfile = currentUser
        currentUserToken = token
    }

    // uid: uid of user
    static func getUserEvents(_ uid: String, completion: @escaping ( (_ eventIds: [String]) -> () )) {
        let userEventsPath = String(format: Constants.Database.userEvents, uid)
        let eventsRef = Database.database().reference().child(userEventsPath)
        var eventIds = [String]()
        eventsRef.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot {
                    let eventId = childSnapshot.key
                    eventIds.append(eventId)
                } else {
                    print("Malformatted eventId, investigate?????")
                }
            }
            completion(eventIds)
        }
    }

    static func getPartialUsernameMatches(_ searchUsername: String, completion: @escaping ( (_ userProfile: [UserProfile]) -> () )) {
        let partialUserMatchesPath = Constants.Database.users
        let partialUserMatchesRef = Database.database().reference().child(partialUserMatchesPath)
        let orderedQuery = partialUserMatchesRef.queryOrdered(byChild: "profile/username").queryStarting(atValue: searchUsername).queryLimited(toFirst: 5)
        var queryResults = [UserProfile]()
        orderedQuery.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot {
                    let matchingUser = UserProfile(forSnapshot: childSnapshot)
                    queryResults.append(matchingUser)
                }
            }
            completion(queryResults)
        }
    }
}
