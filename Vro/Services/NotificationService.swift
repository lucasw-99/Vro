//
//  NotificationService.swift
//  Vro
//
//  Created by Lucas Wotton on 6/28/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import FirebaseDatabase

class NotificationService {
    static func postNotification(forNotification notification: Notification, notificationId: String, withUpdates updateDict: [String: Any?], completion: @escaping ( (_ newUpdates: [String: Any?]) -> () )) {
        print("got notification: \(notification.type.rawValue)")
        let offsetRef = Database.database().reference().child(".info/serverTimeOffset")
        var newUpdates = updateDict
        offsetRef.observeSingleEvent(of: .value) { snapshot in
            guard let offset = snapshot.value as? Double else { fatalError("offset wrong") }
            let negativeTimestamp = (Date().millisecondsSince1970 + Int64(offset)) * -1
            print("negativeTimestamp: \(negativeTimestamp)")
            var notificationDict = notification.dictValue
            notificationDict["negativeTimestamp"] = negativeTimestamp
            let notificationPath = String(format: Constants.Database.specificNotification, notification.forUserUid, notificationId)
            newUpdates[notificationPath] = notificationDict
            completion(newUpdates)
        }
    }
    
    static func removeNotification(forUser uid: String, notificationId: String, withUpdates updateDict: [String: Any?]) -> [String: Any?] {
        let removeNotificationPath = String(format: Constants.Database.specificNotification, uid, notificationId)
        var newUpdate = updateDict
        let val: Any? = nil
        newUpdate[removeNotificationPath] = val
        return newUpdate
    }
}
