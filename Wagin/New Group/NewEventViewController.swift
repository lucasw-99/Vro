//
//  NewEventViewController.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/2/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class NewEventViewController: UIViewController {

    @IBOutlet weak var eventAddress: UITextField!
    @IBOutlet weak var eventDate: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func postNewEvent(_ sender: Any) {
        let address = eventAddress.text
        let date = eventDate.date

        // TODO: Verify address & date are not nil

        let eventRef = Database.database().reference().child(Constants.events).childByAutoId()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.dateFormat
        let dateString = dateFormatter.string(from: date)
        print("dateString: \(dateString)")

        print("currentProfile: \(UserService.currentUserProfile)")
        guard let userProfile = UserService.currentUserProfile else { return }



        let eventObject = [
            "address": address!,
            "date": dateString,
            "host": [
                "uid": userProfile.uid,
                "username": userProfile.username,
                "photoURL": userProfile.photoURL.absoluteString
            ]
        ] as [String: Any]
        print("EventObject: \(eventObject)")
        eventRef.setValue(eventObject) { error, ref in
            if error == nil {
                print("Success!")
            } else {
                print("Error: \(error!.localizedDescription)")
            }
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
