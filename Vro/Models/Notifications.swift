//
//  Notification.swift
//  Vro
//
//  Created by Lucas Wotton on 6/29/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import Foundation

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
    var notificationDictValue: [String: Any] { get }
}

extension Notification {
    var dictValue: [String: Any] {
        let notificationObject = [
            // TODO: Store timestamp as negative value to sort from most recent to least recent?
            "timestamp": timestamp?.millisecondsSince1970 ?? [".sv": "timestamp"],
            "seen": seen,
            "type": type.rawValue,
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
    private let likedPost: EventPost
    private let user: UserProfile
    
    var notificationDictValue: [String : Any] {
        let likeObject = [
            "likedPostId": likedPost.eventPostID,
            "userUid": user.uid
            ] as [String: Any]
        
        return likeObject
    }
    
    init(likedPost: EventPost, user: UserProfile, seen: Bool, timestamp: Date? = nil) {
        self.likedPost = likedPost
        self.user = user
        self.seen = seen
        self.timestamp = timestamp
        self.forUserUid = likedPost.event.host.uid
    }
}

class CommentNotification: Notification {
    var seen: Bool
    var timestamp: Date?
    var type: NotificationType = .Comment
    var forUserUid: String
    private let commentedPost: EventPost
    private let user: UserProfile
    
    var notificationDictValue: [String : Any] {
        let commentObject = [
            "commentedPostId": commentedPost.eventPostID,
            "userUid": user.uid
            ] as [String: Any]
        
        return commentObject
    }
    
    init(commentedPost: EventPost, user: UserProfile, seen: Bool, timestamp: Date? = nil) {
        self.commentedPost = commentedPost
        self.user = user
        self.seen = seen
        self.timestamp = timestamp
        self.forUserUid = commentedPost.event.host.uid
    }
}

class AttendeeNotification: Notification {
    var seen: Bool
    var timestamp: Date?
    var type: NotificationType = .Attendee
    var forUserUid: String
    private let event: Event
    private let attendee: UserProfile
    
    var notificationDictValue: [String : Any] {
        let attendeeObject = [
            "eventAddress": event.address,
            "eventTime": event.eventTime.millisecondsSince1970,
            "userUid": attendee.uid
            ] as [String: Any]
        
        return attendeeObject
    }

    init(event: Event, attendee: UserProfile, seen: Bool, timestamp: Date? = nil) {
        self.event = event
        self.attendee = attendee
        self.seen = seen
        self.timestamp = timestamp
        self.forUserUid = event.host.uid
    }
}

class FollowerNotification: Notification {
    var seen: Bool
    var timestamp: Date?
    var type: NotificationType = .Follower
    var forUserUid: String
    private let followedUserUid: String
    private let followerUid: String
    
    var notificationDictValue: [String : Any] {
        let attendeeObject = [
            "followedUid": followedUserUid,
            "followerUid": followerUid
            ] as [String: Any]
        
        return attendeeObject
    }

    init(followedUserUid: String, followerUid: String, seen: Bool, timestamp: Date? = nil) {
        self.followedUserUid = followedUserUid
        self.followerUid = followerUid
        self.seen = seen
        self.timestamp = timestamp
        self.forUserUid = followedUserUid
    }
}
