//
//  Constants.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/2/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

class Constants {
    class Database {
        // 1: uid, 2: event ID
        static let userEventPostIDs = "users/%@/events/%@"
        // 1: uid
        static let userEvents = "users/%@/events"
        // 1: event ID
        static let eventInfo = "events/%@"
        // 1: event ID
        static let userEventPhotoURL = "events/%@/postedByUser/photoURL"
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
        // 1: uid, 2: EventPost ID
        static let addToTimeline = "timeline/%@/%@"
        // 1: uid
        static let getTimelinePosts = "timeline/%@"

        // 1: uid, 2: EventPost ID
        static let userPostLikes = "likes/%@/%@"
    }
    class Storage {
        // 1: uid, 2: Randomly generated ID
        static let eventImages = "users/%@/events/%@"
        // 1: uid
        static let userEvents = "users/%@/events"
        // 1: uid
        static let userProfileImage = "users/%@/profile"
    }
    static let autocompleteSearchResultCell = "AutocompleteSearchResultCell"
    static let searchUsersCell = "SearchUsersCell"
    static let dateFormat = "MM/dd/yyyy hh:mm a"
    static let newUserProfilePhotoURL = "https://firebasestorage.googleapis.com/v0/b/wagin-5bc40.appspot.com/o/newUser.png?alt=media&token=22eed082-71ff-41d2-b30d-f7529186a60d"
    static let noImageProvidedPhotoURL = "https://firebasestorage.googleapis.com/v0/b/wagin-5bc40.appspot.com/o/imageNotAvailable.png?alt=media&token=c4364e2b-e430-49ce-801e-86acbec3d53b"
}
