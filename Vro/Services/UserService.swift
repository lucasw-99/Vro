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
import SwiftKeychainWrapper
import Alamofire

public enum VroAuthenticationError: Error {
    case unsuccessfulResponse
}

extension VroAuthenticationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unsuccessfulResponse:
            return NSLocalizedString("Authentication Error", comment: "Username or password was incorrect")
        }
    }
}

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
    
    static func updateLoginStatus(_ currentUser: UserProfile?, _ token: String?, _ username: String?, _ password: String?) {
        if let token = token, let username = username, let password = password {
            guard KeychainWrapper.standard.set(token, forKey: Constants.Keychain.loginToken) else { fatalError("Keychain could not save token") }
            guard KeychainWrapper.standard.set(password, forKey: Constants.Keychain.password) else { fatalError("Keychain could not save password") }
            guard KeychainWrapper.standard.set(username, forKey: Constants.Keychain.username) else { fatalError("Keychain could not save username") }
        } else {
            guard token == nil, username == nil, password == nil else { fatalError("mistake somewhere") }
            KeychainWrapper.standard.removeObject(forKey: Constants.Keychain.loginToken)
            KeychainWrapper.standard.removeObject(forKey: Constants.Keychain.password)
            KeychainWrapper.standard.removeObject(forKey: Constants.Keychain.username)
        }
        currentUserProfile = currentUser
        currentUserToken = token
    }
    
    static func authenticateUser(_ username: String, _ password: String, completion: @escaping ( (_ error: Error?) -> () )) {
        let parameters: [String: Any] = [
            "username" : username,
            "password": password
        ]
        
        Alamofire.request("http://178.128.183.75/users/authenticate", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                guard response.result.error == nil else {
                    completion(response.result.error)
                    return
                }
                
                guard let data = response.result.value as? [String: Any],
                    let success = data["success"] as? Bool else {
                        fatalError("Malformed data in response")
                }
                
                if !success {
                    completion(VroAuthenticationError.unsuccessfulResponse)
                    return
                }
                
                print("received data: \(data)")
                guard let newUserPhotoUrl = URL(string: Constants.newUserProfilePhotoURL) else {
                    fatalError("new user photo URL doesn't work!")
                }
                
                guard let token = data["token"] as? String,
                    let userDict = data["user"] as? [String: Any],
                    let uid = userDict["id"] as? String,
                    let username = userDict["username"] as? String else {
                        fatalError("Malformatted data from server!")
                }
                let currentUser = UserProfile(uid, username, newUserPhotoUrl)
                UserService.updateLoginStatus(currentUser, token, username, password)
                completion(nil)
        }
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
