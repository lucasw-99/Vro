//
//  EventService.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/16/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import FirebaseDatabase

class EventPostService {

    // user: UserProfile that is making the post
    // eventPostID: The id of the EventPost
    // date: date of the event
    static func setEvent(_ eventPost: EventPost) {
        let eventIDPath = String(format: Constants.Database.eventInfo, eventPost.eventPostID)
        let eventRef = Database.database().reference().child(eventIDPath)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.dateFormat
        let eventTimeString = dateFormatter.string(from: eventPost.event.eventTime)

        let eventPostObject = [
            "postedByUser": [
                "uid": eventPost.postedByUser.uid,
                "username": eventPost.postedByUser.username,
                "photoURL": eventPost.postedByUser.photoURL.absoluteString
            ],
            "event": [
                "hostUID": eventPost.event.hostUID,
                // TODO: Change this to a valid description of event
                "description": eventPost.event.description,
                "address": eventPost.event.address,
                "eventImageURL": eventPost.event.eventImageURL,
                "eventTime": eventTimeString
            ],
            "likedBy": [],
            "caption": eventPost.caption,
            // TODO: Store timestamp as negative value to sort from most recent to least recent?
            "timestamp": [".sv": "timestamp"],
            "eventPostID": eventPost.eventPostID
            ] as [String: Any]

        eventRef.setValue(eventPostObject)
    }


    // uid: User id
    // eventPostID: Event post ID
    static func setEventPostID(_ uid: String, _ eventPostID: String) {
        let userEventPath = String(format: Constants.Database.userEventPostIDs, uid, eventPostID)
        let eventRef = Database.database().reference().child(userEventPath)

        eventRef.setValue(true)
    }

    static func updateEventPhotoURL(_ eventID: String, _ photoURL: String) {
        let eventPhotoPath = String(format: Constants.Database.userEventPhotoURL, eventID)
        let eventPhotoRef = Database.database().reference().child(eventPhotoPath)

        let photoDict = [photoURL: true]

        eventPhotoRef.setValue(photoDict)
    }

    static func getEvent(_ eventID: String, completion: @escaping ( (_ eventPost: EventPost) -> () )) {
        let eventPath = String(format: Constants.Database.eventInfo, eventID)
        let eventRef = Database.database().reference().child(eventPath)

        eventRef.observeSingleEvent(of: .value) { snapshot in
            if let eventPostDict = snapshot.value as? [String: Any],
                let postedByUserDict = eventPostDict["postedByUser"] as? [String: Any],
                let postedByUID = postedByUserDict["uid"] as? String,
                let postedByUsername = postedByUserDict["username"] as? String,
                let postedByPhotoURLString = postedByUserDict["photoURL"] as? String,
                let postedByPhotoURL = URL(string: postedByPhotoURLString),
                let eventDict = eventPostDict["event"] as? [String: Any],
                let hostUID = eventDict["hostUID"] as? String,
                let eventDescription = eventDict["description"] as? String,
                let eventAddress = eventDict["address"] as? String,
                let eventImageURL = eventDict["eventImageURL"] as? String,
                let eventTime = eventDict["eventTime"] as? String,
                let eventPostCaption = eventPostDict["caption"] as? String,
                let eventPostTimestamp = eventPostDict["timestamp"] as? TimeInterval,
                let eventPostID = eventPostDict["eventPostID"] as? String {
//                print("postedByPhotoURL: \(postedByPhotoURL), uid: \(uid)")

                let eventDate = Util.stringToDate(dateString: eventTime)
                let timestamp = Date(timeIntervalSince1970: eventPostTimestamp / 1000)

                let postedByUser = UserProfile(postedByUID, postedByUsername, postedByPhotoURL)

                let event = Event(hostUID, eventImageURL, eventDescription, eventAddress, eventDate)
                let eventPost = EventPost(postedByUser, event, eventPostCaption, timestamp, eventPostID)
                completion(eventPost)
            } else {
                fatalError("event ID was there but it was nil")
            }
        }
    }
}
