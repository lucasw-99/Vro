//
//  UserProfile.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/3/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//
import Foundation
import FirebaseDatabase

class UserProfile {
    let uid: String
    let username: String
    let photoURL: URL

    // init method meant for filtering users in search (so far)
    init(forSnapshot snapshot: DataSnapshot) {
        guard let dict = snapshot.value as? [String: Any],
            let profileDict = dict["profile"] as? [String: Any],
            let username = profileDict["username"] as? String,
            let photoURLString = profileDict["photoURL"] as? String,
            let photoURL = URL(string: photoURLString) else { fatalError("malformed UserProfile data in firebase") }

        self.uid = snapshot.key
        self.username = username
        self.photoURL = photoURL
    }

    init(_ uid: String, _ username: String, _ photoURL: URL) {
        self.uid = uid
        self.username = username
        self.photoURL = photoURL
    }
}
