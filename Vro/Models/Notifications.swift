//
//  Notification.swift
//  Vro
//
//  Created by Lucas Wotton on 6/29/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import Foundation
import FirebaseDatabase

enum NotificationType: String {
    case Like = "Like"
    case Comment = "Comment"
    case Attendee = "Attendee"
    case Follower = "Follower"
}

protocol Notification {
    var seen: Bool { get }
    var timestamp: Date? { get }
    var type: NotificationType { get }
    var forUserUid: String { get }
    var userUid: String { get }
    var notificationId: String { get }
    var notificationDictValue: [String: Any] { get }
    
    init(forSnapshot snapshot: DataSnapshot)
}

extension Notification {
    var dictValue: [String: Any] {
        let notificationObject = [
            // TODO: Store timestamp as negative value to sort from most recent to least recent?
            "notificationId": notificationId,
            "timestamp": timestamp?.millisecondsSince1970 ?? [".sv": "timestamp"],
            "seen": seen,
            "type": type.rawValue,
            "forUserUid": forUserUid,
            "userUid": userUid,
            "notification": notificationDictValue
            ] as [String: Any]
        
        return notificationObject
    }
}

class LikeNotification: Notification {
    var seen: Bool
    var timestamp: Date?
    var type: NotificationType = .Like
    var forUserUid: String
    var userUid: String
    var notificationId: String
    let likedPostId: String
    
    var notificationDictValue: [String : Any] {
        let likeObject = [
            "likedPostId": likedPostId,
            "userUid": userUid
            ] as [String: Any]
        
        return likeObject
    }
    
    // TODO: Read out userUid? Change the name of it to fromUserUid?
    required init(forSnapshot snapshot: DataSnapshot) {
        guard let notificationDict = snapshot.value as? [String: Any],
            let seen = notificationDict["seen"] as? Bool,
            let timestamp = notificationDict["timestamp"] as? TimeInterval,
            let forUserUid = notificationDict["forUserUid"] as? String,
            let notificationId = notificationDict["notificationId"] as? String,
            let likeDict = notificationDict["notification"] as? [String: Any],
            let likedPostId = likeDict["likedPostId"] as? String,
            let userUid = likeDict["userUid"] as? String
            else { fatalError("malformed UserProfile data in firebase") }
        self.seen = seen
        self.timestamp = Date(milliseconds: timestamp)
        self.forUserUid = forUserUid
        self.notificationId = notificationId
        self.likedPostId = likedPostId
        self.userUid = userUid
    }

    
    init(likedPostId: String, userUid: String, seen: Bool, forUserUid: String, notificationId: String, timestamp: Date? = nil) {
        self.likedPostId = likedPostId
        self.userUid = userUid
        self.seen = seen
        self.forUserUid = forUserUid
        self.notificationId = notificationId
        self.timestamp = timestamp
    }
}

class CommentNotification: Notification {
    var seen: Bool
    var timestamp: Date?
    var type: NotificationType = .Comment
    var forUserUid: String
    var userUid: String
    var notificationId: String
    let commentedPostId: String
    
    var notificationDictValue: [String : Any] {
        let commentObject = [
            "commentedPostId": commentedPostId,
            "userUid": userUid
            ] as [String: Any]
        
        return commentObject
    }
    
    required init(forSnapshot snapshot: DataSnapshot) {
        guard let notificationDict = snapshot.value as? [String: Any],
            let seen = notificationDict["seen"] as? Bool,
            let timestamp = notificationDict["timestamp"] as? TimeInterval,
            let forUserUid = notificationDict["forUserUid"] as? String,
            let notificationId = notificationDict["notificationId"] as? String,
            let commentDict = notificationDict["notification"] as? [String: Any],
            let commentedPostId = commentDict["commentedPostId"] as? String,
            let userUid = commentDict["userUid"] as? String
            else { fatalError("malformed UserProfile data in firebase") }
        self.seen = seen
        self.timestamp = Date(milliseconds: timestamp)
        self.forUserUid = forUserUid
        self.notificationId = notificationId
        self.commentedPostId = commentedPostId
        self.userUid = userUid
    }
    
    init(commentedPostId: String, userUid: String, seen: Bool, forUserUid: String, notificationId: String, timestamp: Date? = nil) {
        self.commentedPostId = commentedPostId
        self.userUid = userUid
        self.seen = seen
        self.forUserUid = forUserUid
        self.notificationId = notificationId
        self.timestamp = timestamp
    }
}

class AttendeeNotification: Notification {
    var seen: Bool
    var timestamp: Date?
    var type: NotificationType = .Attendee
    var forUserUid: String
    var userUid: String
    var notificationId: String
    let eventAddress: String
    let eventTime: Date
    
    var notificationDictValue: [String : Any] {
        let attendeeObject = [
            "eventAddress": eventAddress,
            "eventTime": eventTime.millisecondsSince1970,
            "userUid": userUid
            ] as [String: Any]
        
        return attendeeObject
    }
    
    required init(forSnapshot snapshot: DataSnapshot) {
        guard let notificationDict = snapshot.value as? [String: Any],
            let seen = notificationDict["seen"] as? Bool,
            let timestamp = notificationDict["timestamp"] as? TimeInterval,
            let forUserUid = notificationDict["forUserUid"] as? String,
            let notificationId = notificationDict["notificationId"] as? String,
            let attendeeDict = notificationDict["notification"] as? [String: Any],
            let eventAddress = attendeeDict["eventAddress"] as? String,
            let eventTime = attendeeDict["eventTime"] as? TimeInterval,
            let userUid = attendeeDict["userUid"] as? String
            else { fatalError("malformed UserProfile data in firebase") }
        self.seen = seen
        self.timestamp = Date(milliseconds: timestamp)
        self.forUserUid = forUserUid
        self.notificationId = notificationId
        self.eventAddress = eventAddress
        self.eventTime = Date(milliseconds: eventTime)
        self.userUid = userUid
    }

    init(eventAddress: String, eventTime: Date, attendeeUid: String, seen: Bool, forUserUid: String, notificationId: String, timestamp: Date? = nil) {
        self.eventAddress = eventAddress
        self.eventTime = eventTime
        self.userUid = attendeeUid
        self.seen = seen
        self.forUserUid = forUserUid
        self.notificationId = notificationId
        self.timestamp = timestamp
    }
}

class FollowerNotification: Notification {
    var seen: Bool
    var timestamp: Date?
    var type: NotificationType = .Follower
    var forUserUid: String
    var userUid: String
    var notificationId: String
    let followedUserUid: String
    let followerUid: String
    
    var notificationDictValue: [String : Any] {
        let attendeeObject = [
            "followedUid": followedUserUid,
            "followerUid": followerUid
            ] as [String: Any]
        
        return attendeeObject
    }
    
    required init(forSnapshot snapshot: DataSnapshot) {
        guard let notificationDict = snapshot.value as? [String: Any],
            let seen = notificationDict["seen"] as? Bool,
            let timestamp = notificationDict["timestamp"] as? TimeInterval,
            let forUserUid = notificationDict["forUserUid"] as? String,
            let notificationId = notificationDict["notificationId"] as? String,
            let followerDict = notificationDict["notification"] as? [String: Any],
            let followedUserUid = followerDict["followedUid"] as? String,
            let followerUid = followerDict["followerUid"] as? String
            else { fatalError("malformed UserProfile data in firebase") }
        self.seen = seen
        self.timestamp = Date(milliseconds: timestamp)
        self.forUserUid = forUserUid
        self.userUid = followerUid
        self.notificationId = notificationId
        self.followedUserUid = followedUserUid
        self.followerUid = followerUid
    }

    init(followedUserUid: String, followerUid: String, seen: Bool, notificationId: String, timestamp: Date? = nil) {
        self.followedUserUid = followedUserUid
        self.followerUid = followerUid
        self.seen = seen
        self.forUserUid = followedUserUid
        self.userUid = followerUid
        self.notificationId = notificationId
        self.timestamp = timestamp
    }
}
