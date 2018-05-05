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
    private let addressLabel = UILabel()
    private let eventAddress = UITextField()
    private let captionLabel = UILabel()
    private let captionText = UITextView()
    private let timeLabel = UILabel()
    private let eventDate = UIDatePicker()
    private let postEventButton = UIButton()
    private let cancelButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupLayout()
    }

    @IBAction func postNewEvent(_ sender: Any) {
        let address = eventAddress.text
        let eventTime = eventDate.date
        let caption = captionText.text

        // TODO: Verify address & date are not nil

        let eventRef = Database.database().reference().child(Constants.eventPosts).childByAutoId()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.dateFormat
        let eventTimeString = dateFormatter.string(from: eventTime)
        guard let userProfile = UserService.currentUserProfile else { return }

        let eventPostObject = [
            "postedBy": [
                "uid": userProfile.uid,
                "username": userProfile.username,
                "photoURL": userProfile.photoURL.absoluteString
            ],
            "event": [
                "host": [
                    "uid": userProfile.uid,
                    "username": userProfile.username,
                    "photoURL": userProfile.photoURL.absoluteString
                ],
                // TODO: Change this to a valid description of event
                "description": "",
                "address": address!,
                "eventTime": eventTimeString
            ],
            "likedBy": [],
            "caption": caption!,
            "timestamp": [".sv": "timestamp"]
        ] as [String: Any]

        eventRef.setValue(eventPostObject) { error, ref in
            if error == nil {
                print("Success!")
                self.dismiss(animated: true, completion: nil)
            } else {
                print("Error: \(error!.localizedDescription)")
            }
        }
    }

    @IBAction func dismissModalView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    private func setupSubviews() {
        addressLabel.text = "Address of Event"
        addressLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        addressLabel.numberOfLines = 1
        addressLabel.textAlignment = .center
        view.addSubview(addressLabel)

        eventAddress.autocorrectionType = .no
        Util.roundedCorners(ofColor: .lightGray, element: eventAddress)
        view.addSubview(eventAddress)

        captionLabel.text = "Caption of Event"
        captionLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        captionLabel.numberOfLines = 1
        captionLabel.textAlignment = .center
        view.addSubview(captionLabel)

        Util.roundedCorners(ofColor: .lightGray, element: captionText)
        view.addSubview(captionText)

        timeLabel.text = "Time of Event"
        timeLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        timeLabel.numberOfLines = 1
        timeLabel.textAlignment = .center
        view.addSubview(timeLabel)

        eventDate.datePickerMode = .dateAndTime
        eventDate.minuteInterval = 15
        eventDate.date = Date()
        eventDate.minimumDate = Date()
        view.addSubview(eventDate)

        postEventButton.setTitle("Post", for: .normal)
        postEventButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        postEventButton.addTarget(self, action: #selector(NewEventViewController.postNewEvent(_:)), for: .touchUpInside)
        postEventButton.backgroundColor = .lightGray
        Util.roundedCorners(ofColor: .lightGray, element: postEventButton)
        view.addSubview(postEventButton)

        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        cancelButton.addTarget(self, action: #selector(NewEventViewController.dismissModalView(_:)), for: .touchUpInside)
        cancelButton.backgroundColor = .lightGray
        Util.roundedCorners(ofColor: .lightGray, element: cancelButton)
        view.addSubview(cancelButton)

        view.backgroundColor = .white
    }

    private func setupLayout() {
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(view.layoutMarginsGuide.snp.topMargin).offset(40)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        eventAddress.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalTo(225)
            make.height.equalTo(30)
        }

        captionLabel.snp.makeConstraints { make in
            make.top.equalTo(eventAddress.snp.bottom).offset(35)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        captionText.snp.makeConstraints { make in
            make.top.equalTo(captionLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalTo(225)
            make.height.equalTo(85)
        }

        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(captionText.snp.bottom).offset(35)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        eventDate.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(200)
        }

        postEventButton.snp.makeConstraints { make in
            make.top.equalTo(eventDate.snp.bottom).offset(45)
            make.centerX.equalToSuperview()
            make.width.equalTo(90)
            make.height.equalTo(40)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(postEventButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(90)
            make.height.equalTo(40)
        }
    }
}
