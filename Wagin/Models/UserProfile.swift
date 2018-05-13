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
    // array of uid's
    var followers: [String]
    // array of uid's
    var following: [String]

    init(_ uid: String, _ username: String, _ photoURL: URL, _ followers: [String], _ following: [String]) {
        self.uid = uid
        self.username = username
        self.photoURL = photoURL
        self.followers = followers
        self.following = following
    }
}
