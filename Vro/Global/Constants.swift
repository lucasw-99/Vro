//
//  Constants.swift
//  Vro
//
//  Created by Lucas Wotton on 5/2/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

class Constants {
    class Database {
        // 1: hostUid
        static let userEvents = "events/%@"
        // 1: hostUid, 2: eventId
        static let eventInfo = "events/%@/%@"
        // 1: hostUid, eventPostUid
        static let eventLikeCount = "events/%@/%@/likeCount"
        // 1: hostUid, eventPostUid
        static let userEventPhotoURL = "events/%@/%@/postedByUser/photoURL"
        
        // 1: uid
        static let userProfile = "users/%@/profile"
        // 1: uid
        static let userProfilePhotoURL = "users/%@/profile/photoURL"
        // 1: uid
        static let userFollowerInfo = "users/%@/followerInfo"
        // 1: uid
        static let userFollowers = "users/%@/followerInfo/followers"
        // 1: uid
        static let userFollowing = "users/%@/followerInfo/following"

        static let users = "users"
        // 1: uid
        static let getUserProfile = "%@/profile/"
        // 1: uid, 2: EventPostId
        static let addToTimeline = "timeline/%@/%@"
        // 1: uid
        static let getTimelinePosts = "timeline/%@"

        // 1: uid, 2: EventPost ID, 3: uid of user liking post
        static let userPostLikes = "likes/%@/%@/%@"

        // 1: uid, 2: EventPost ID
        static let postLikes = "likes/%@/%@"

        // 1: comment ID
        static let postComment = "comments/%@"

        // 1: EventPost ID, 2: Comment ID
        static let eventPostComment = "events/%@/comments/%@"

        // 1: EventPost ID
        static let eventPostComments = "events/%@/comments"

        // 1: EventPostId
        static let eventAttendeeCount = "events/%@/event/attendeeCount"
        
        // 1: EventPostId
        static let eventPotentialGuests = "attending/%@/potential"

        // 1: EventPostId, 2: uid
        static let eventPotentialAttending = "attending/%@/potential/%@"

        // 1: EventPostId, 2: uid
        static let eventActualAttending = "attending/%@/actual/%@"

        // 1: uid, 2: EventPostId
        static let userEventsAttending = "users/%@/attendingEvents/%@"
        
        // 1: uid
        static let notifications = "notifications/%@"
        
        // 1: uid, 2: notificationId
        static let specificNotification = "notifications/%@/%@"
        
        // 1: notificationId
        static let notificationIdsToTimestamps = "idsToTimestamps/%@"
    }
    
    class Storage {
        // 1: uid, 2: Randomly generated ID
        static let eventImages = "users/%@/events/%@"
        // 1: uid
        static let userEvents = "users/%@/events"
        // 1: uid
        static let userProfileImage = "users/%@/profile"
    }

    class Cells {
        static let autocompleteSearchResultCell = "AutocompleteSearchResultCell"
        static let searchUsersCell = "SearchUsersCell"
        static let commentsCell = "CommentsCell"
    }
    
    class Keychain {
        static let loginToken = "loginToken"
        static let username = "username"
        static let password = "password"
    }
    
    class Requests {
        static let baseUrl = "http://178.128.183.75"
        // 1: baseUrl
        static let timelineRequest = "%@/timeline"
        // 1: baseUrl
        static let followRequest = "%@/followers"
        // 1: baseUrl
        static let postLikeRequest = "%@/likes"
        // 1: baseUrl
        static let userUsernameMatches = "%@/users/search"
    }

    static let dateFormat = "MM/dd/yyyy hh:mm a"
    static let newUserProfilePhotoURL = "https://firebasestorage.googleapis.com/v0/b/wagin-5bc40.appspot.com/o/newUser.png?alt=media&token=22eed082-71ff-41d2-b30d-f7529186a60d"
    static let noImageProvidedPhotoURL = "https://firebasestorage.googleapis.com/v0/b/wagin-5bc40.appspot.com/o/imageNotAvailable.png?alt=media&token=c4364e2b-e430-49ce-801e-86acbec3d53b"
}
