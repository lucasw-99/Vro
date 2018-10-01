//
//  UserProfile.swift
//  Vro
//
//  Created by Lucas Wotton on 5/3/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//
import Foundation

class UserProfile {
    let uid: Int
    let username: String
    let photoURL: URL

    var dictValue: [String: Any] {
        let userProfileObject = [
                "uid": uid,
                "username": username,
                "photoURL": photoURL.absoluteString
        ] as [String: Any]

        return userProfileObject
    }


    init(userJson json: [String: Any]) {
        guard let uid = json["id"] as? String,
            let username = json["username"] as? String,
            let photoUrlString = json["photoURL"] as? String,
            let photoUrl = URL(string: photoUrlString) else { fatalError("Malformatted json for UserProfile") }
        // TODO (Lucas Wotton): Temporary patch
        self.uid = 1
        self.username = username
        self.photoURL = photoUrl
    }
    
    init(userJson json: [String: Any], photoUrlString: String) {
        guard let id = json["id"] as? Int,
            let username = json["username"] as? String,
            let photoUrl = URL(string: photoUrlString) else { fatalError("Malformatted json for UserProfile") }
        // TODO (Lucas Wotton): Temporary patch
        self.uid = id
        self.username = username
        self.photoURL = photoUrl
    }

    init(_ uid: Int, _ username: String, _ photoUrl: URL) {
        self.uid = uid
        self.username = username
        self.photoURL = photoUrl
    }
}
