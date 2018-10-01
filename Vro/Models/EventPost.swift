//
//  EventPost.swift
//  Vro
//
//  Created by Lucas Wotton on 5/4/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import MapKit

class EventPost {
    let eventPostId: Int
    let host: UserProfile
    let eventImageUrl: URL
    let description: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    // TODO (Lucas Wotton): Fix this on server
//    let eventTime: Date
    let timestamp: Date
    var likeCount: Int
    var attendeeCount: Int

    var isLiked: Bool = false
    var isAttending: Bool = false

    
    init(eventJson: [String: Any]) {
        print("eventJson: \(eventJson)")
        guard let hostDict = eventJson["host"] as? [String: Any],
            let hostId = hostDict["id"] as? Int,
            let username = hostDict["username"] as? String,
            let photoUrlString = hostDict["photoUrl"] as? String,
            let photoUrl = URL(string: photoUrlString),
            let eventPostId = eventJson["eventId"] as? Int,
            let address = eventJson["address"] as? String,
            let description = eventJson["description"] as? String,
            let timestampString = eventJson["time"] as? String,
            let eventUrlString = eventJson["eventImageUrl"] as? String,
            let eventUrl = URL(string: eventUrlString),
            let likeCount = eventJson["likeCount"] as? Int,
            let attendingCount = eventJson["attendingCount"] as? Int,
            let geoloc = eventJson["geoloc"] as? [String: Any],
            let lat = geoloc["lat"] as? Double,
            let lng = geoloc["lng"] as? Double else {
                fatalError("Malformatted event json")
        }
        self.host = UserProfile(hostId, username, photoUrl)
        self.eventPostId = eventPostId
        self.address = address
        self.description = description
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        // TODO (Lucas Wotton): Force unwrap??
        self.timestamp = formatter.date(from: timestampString)!
        self.eventImageUrl = eventUrl
        self.likeCount = likeCount
        self.attendeeCount = attendingCount
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
}
