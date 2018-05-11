//
//  UserService.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/3/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import FirebaseDatabase
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
                let url = URL(string: photoURL) ?? URL(string: Constants.newUserProfilePhotoURL)
                userProfile = UserProfile(uid: uid, username: username, photoURL: url!)
            }
            completion(userProfile)
        })
    }
}
