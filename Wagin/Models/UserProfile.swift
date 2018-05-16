//
//  UserProfile.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/3/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//
import Foundation

class UserProfile {
    let uid: String
    let username: String
    let photoURL: URL

    init(_ uid: String, _ username: String, _ photoURL: URL) {
        self.uid = uid
        self.username = username
        self.photoURL = photoURL
    }
}
