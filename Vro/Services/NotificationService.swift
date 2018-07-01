//
//  NotificationService.swift
//  Vro
//
//  Created by Lucas Wotton on 6/28/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import FirebaseDatabase

class NotificationService {
    static func postNotification(forNotification notification: Notification, notificationId: String) {
        print("got notification: \(notification.type.rawValue)")
        let offsetRef = Database.database().reference().child(".info/serverTimeOffset")
        offsetRef.observeSingleEvent(of: .value) { snapshot in
            guard let offset = snapshot.value as? Double else { fatalError("offset wrong") }
            let negativeTimestamp = (Date().millisecondsSince1970 + Int64(offset)) * -1
            print("negativeTimestamp: \(negativeTimestamp)")
            var notificationDict = notification.dictValue
            notificationDict["negativeTimestamp"] = negativeTimestamp
            let notificationPath = String(format: Constants.Database.specificNotification, notification.forUserUid, notificationId)
            let notificationRef = Database.database().reference().child(notificationPath)
            
            // TODO: Retry on failure? Or wrap in a transaction? Wrap in a transaction definitely
            notificationRef.setValue(notificationDict)
        }
    }
    
    static func removeNotification(forUser uid: String, notificationId: String) {
        let removeNotificationPath = String(format: Constants.Database.specificNotification, uid, notificationId)
        let removeNotificationRef = Database.database().reference().child(removeNotificationPath)
        
        removeNotificationRef.removeValue()
    }
}
