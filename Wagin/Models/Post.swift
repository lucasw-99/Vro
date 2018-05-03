//
//  Post.swift
//  Wagin
//
//  Created by Lucas Wotton on 4/30/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

struct Post {
    let postImage: UIImage
    let caption: String
    let createdBy: User
    let timeAgo: String
    let likedBy: [User]

    static func fetchPosts() -> [Post] {
        return [Post(postImage: #imageLiteral(resourceName: "waginStartScreen"), caption: "yueah", createdBy: User(username: "Lucas", profileImage: #imageLiteral(resourceName: "user_male"), joinDate: nil), timeAgo: "2 days ago", likedBy: [User]()), Post(postImage: #imageLiteral(resourceName: "waginStartScreen"), caption: "yueah", createdBy: User(username: "Lucas", profileImage: #imageLiteral(resourceName: "user_male"), joinDate: nil), timeAgo: "2 days ago", likedBy: [User]()), Post(postImage: #imageLiteral(resourceName: "waginStartScreen"), caption: "yueah", createdBy: User(username: "Lucas", profileImage: #imageLiteral(resourceName: "user_male"), joinDate: nil), timeAgo: "2 days ago", likedBy: [User]()), Post(postImage: #imageLiteral(resourceName: "waginStartScreen"), caption: "yueah", createdBy: User(username: "Lucas", profileImage: #imageLiteral(resourceName: "user_male"), joinDate: nil), timeAgo: "2 days ago", likedBy: [User]()), Post(postImage: #imageLiteral(resourceName: "waginStartScreen"), caption: "yueah", createdBy: User(username: "Lucas", profileImage: #imageLiteral(resourceName: "user_male"), joinDate: nil), timeAgo: "2 days ago", likedBy: [User]()), Post(postImage: #imageLiteral(resourceName: "waginStartScreen"), caption: "yueah", createdBy: User(username: "Lucas", profileImage: #imageLiteral(resourceName: "user_male"), joinDate: nil), timeAgo: "2 days ago", likedBy: [User]())]
    }
}
