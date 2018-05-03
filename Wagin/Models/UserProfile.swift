//
//  UserProfile.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/3/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//
import Foundation
import UIKit

class UserProfile {
    let uid: String
    let username: String
    let photoURL: URL

    init(uid: String, username: String, photoURL: URL) {
        self.uid = uid
        self.username = username
        self.photoURL = photoURL
    }
}
