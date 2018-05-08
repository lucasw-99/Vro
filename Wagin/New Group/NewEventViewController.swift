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

class NewEventViewController: UIViewController, UIScrollViewDelegate {
    private let contentView = UIView()

    private let addressLabel = UILabel()

    private let captionLabel = UILabel()
    private let captionText = UITextView()

    private let timeLabel = UILabel()
    private let eventDate = UIDatePicker()

    private let eventLabel = UILabel()
    private let uploadEventImageButton = UIButton()

    private let postEventButton = UIButton()
    private let cancelButton = UIButton()

    private var address: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupLayout()
    }

    // address: An address passed from the previous view controller
    // This function is used to initialize the address field in this controller.
    func setAddress(address: String) {
        self.address = address
        print("Set address to: \(address)")
    }

    @IBAction func uploadEventImage(_ sender: Any) {
        print("Called upload image")
    }

    @IBAction func dismissModalView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func postNewEvent(_ sender: Any) {
        // More error checking on date?
        let eventTime = eventDate.date

        // Warning if posting empty caption?
        let caption = captionText.text

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
                "address": address,
                "eventTime": eventTimeString
            ],
            "likedBy": [],
            "caption": caption!,
            "timestamp": [".sv": "timestamp"]
        ] as [String: Any]

        eventRef.setValue(eventPostObject) { error, ref in
            if error == nil {
                self.dismiss(animated: true, completion: nil)
            } else {
                print("Error: \(error!.localizedDescription)")
            }
        }
    }

    private func setupSubviews() {
        let addressPrompt = "Address of Event: "
        let providedAddress = address ?? "Not Provided"
        let addressLabelString = "\(addressPrompt)\(providedAddress)"
        let nsrange = NSMakeRange(addressPrompt.count, providedAddress.count)
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: providedAddress)
        attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 20, weight: .semibold), range: nsrange)
        addressLabel.attributedText = attributedString
        addressLabel.font = UIFont.systemFont(ofSize: 20)
        addressLabel.numberOfLines = 0
        addressLabel.textAlignment = .center
        contentView.addSubview(addressLabel)

        captionLabel.text = "Caption of Event"
        captionLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        captionLabel.numberOfLines = 1
        captionLabel.textAlignment = .center
        contentView.addSubview(captionLabel)

        Util.roundedCorners(ofColor: .lightGray, element: captionText)
        contentView.addSubview(captionText)

        timeLabel.text = "Time of Event"
        timeLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        timeLabel.numberOfLines = 1
        timeLabel.textAlignment = .center
        contentView.addSubview(timeLabel)

        eventDate.datePickerMode = .dateAndTime
        eventDate.minuteInterval = 15
        eventDate.date = Date()
        eventDate.minimumDate = Date()
        contentView.addSubview(eventDate)

        eventLabel.text = "Upload Event Image"
        eventLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        eventLabel.numberOfLines = 1
        eventLabel.textAlignment = .center
        eventLabel.textColor = .lightGray
        contentView.addSubview(eventLabel)

        uploadEventImageButton.setImage(#imageLiteral(resourceName: "upload"), for: .normal)
        uploadEventImageButton.addTarget(self, action: #selector(NewEventViewController.uploadEventImage(_:)), for: .touchUpInside)
        Util.roundedCorners(ofColor: .lightGray, element: uploadEventImageButton)
        contentView.addSubview(uploadEventImageButton)

        postEventButton.setTitle("Post", for: .normal)
        postEventButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        postEventButton.addTarget(self, action: #selector(NewEventViewController.postNewEvent(_:)), for: .touchUpInside)
        postEventButton.backgroundColor = .lightGray
        Util.roundedCorners(ofColor: .lightGray, element: postEventButton)
        contentView.addSubview(postEventButton)

        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        cancelButton.addTarget(self, action: #selector(NewEventViewController.dismissModalView(_:)), for: .touchUpInside)
        cancelButton.backgroundColor = .lightGray
        Util.roundedCorners(ofColor: .lightGray, element: cancelButton)
        contentView.addSubview(cancelButton)

        contentView.backgroundColor = .white
        view.addSubview(contentView)
    }

    private func setupLayout() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(view.layoutMarginsGuide.snp.topMargin).offset(40)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        captionLabel.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(35)
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

        eventLabel.snp.makeConstraints { make in
            make.top.equalTo(eventDate.snp.bottom).offset(15)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        uploadEventImageButton.snp.makeConstraints { make in
            make.top.equalTo(eventLabel.snp.bottom).offset(15)
            make.width.equalTo(90)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }

        postEventButton.snp.makeConstraints { make in
            make.top.equalTo(uploadEventImageButton.snp.bottom).offset(45)
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
