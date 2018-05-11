//
//  Constants.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/2/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

class Constants {
    class Database {
        // 1: uid, 2: Randomly generated ID
        static let newEventPost = "users/%@/events/%@"
        // 1: uid
        static let userProfile = "users/%@/profile"
        // 1: uid
        static let userProfilePhotoURL = "users/%@/profile/photoURL"
    }
    class Storage {
        // 1: uid, 2: Randomly generated ID
        static let eventImages = "users/%@/events/%@"
        // 1: uid
        static let userProfileImage = "users/%@/profile"
    }
    static let autocompleteSearchResult = "AutocompleteSearchResultCell"
    static let dateFormat = "MM/dd/yyyy hh:mm a"
    static let newUserProfilePhotoURL = "https://firebasestorage.googleapis.com/v0/b/wagin-5bc40.appspot.com/o/newUser.png?alt=media&token=22eed082-71ff-41d2-b30d-f7529186a60d"
}
