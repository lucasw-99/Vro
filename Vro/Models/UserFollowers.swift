//
//  UserFollowers.swift
//  Vro
//
//  Created by Lucas Wotton on 5/15/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import Foundation
import UIKit

class UserFollowers {
    let uid: String
    // set of uid's
    var followers: Set<String>
    // set of uid's
    var following: Set<String>

    init(_ uid: String, _ followers: Set<String>, _ following: Set<String>) {
        self.uid = uid
        self.followers = followers
        self.following = following
    }
}

