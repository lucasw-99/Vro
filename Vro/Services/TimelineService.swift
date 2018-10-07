//
//  TimelineServic.swift
//  Vro
//
//  Created by Lucas Wotton on 5/16/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public enum VroTimelineError: Error {
    case unsuccessfulResponse
}

extension VroTimelineError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unsuccessfulResponse:
            return NSLocalizedString("Timeline Error", comment: "Could not retrieve timeline")
        }
    }
}

class TimelineService {

    // users: List of uid's, where each uid is a user following the user
    // who was the author of the post with eventPostID
    // eventPostID: Id of the post
    static func addPostToTimelines(_ users: Set<Follower>, _ eventPostId: String, _ hostUid: String, withUpdates updates: [String: Any?], completion: @escaping ( (_ updates: [String: Any?]) -> () )) {
        var newUpdates = updates
        for user in users {
            let uid = user.followerId
            let addToTimelinePath = String(format: Constants.Database.addToTimeline, uid, eventPostId)
            newUpdates[addToTimelinePath] = hostUid
        }
        completion(newUpdates)
    }

    static func updateUserTimeline(_ followedUid: String, _ uid: String, addToTimeline: Bool, withUpdates updates: [String: Any?], completion: @escaping ( (_ newUpdates: [String: Any?]) -> () )) {
        var newUpdates = updates
        UserService.getUserEvents(followedUid) { eventIds in
            for eventId in eventIds {
                let userTimelinePath = String(format: Constants.Database.addToTimeline, uid, eventId)
                let val: Any? = nil
                newUpdates[userTimelinePath] = addToTimeline ? followedUid : val
            }
            completion(newUpdates)
        }
    }

    
    static func getUserTimeline(completion: @escaping ( (_ error: Error?, _ posts: [EventPost]) -> () )) {
        guard let token = UserService.currentUserToken else { fatalError("User JWT token nil") }
        let headers = [
            "Authorization": token,
        ]
        let url = String(format: Constants.Requests.timelineRequest, Constants.Requests.baseUrl)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            guard response.result.error == nil else {
                return completion(response.result.error, [])
            }
            print("Made alamofire request")
            
            let json = JSON(response.result.value!)
            if let success = json["success"].bool, !success {
                return completion(VroFollowError.unsuccessfulGetResponse, [])
            } else if let timeline = json["timeline"].array {
                var eventPosts = [EventPost]()
                for postDict in timeline {
                    guard let postDict = postDict.dictionaryObject else { fatalError("Malformatted JSON") }
                    let eventPost = EventPost(eventJson: postDict)
                    eventPosts.append(eventPost)
                }
                return completion(nil, eventPosts)
            } else {
                fatalError("Malformed JSON")
            }
        }
    }
}
