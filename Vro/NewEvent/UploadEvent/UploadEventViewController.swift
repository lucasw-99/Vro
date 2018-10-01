//
//  EventMetadataViewController.swift
//  Vro
//
//  Created by Lucas Wotton on 5/7/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import MapKit

class UploadEventViewController: UIViewController {
    private let headerView = UIView()
    private let backButton = UIButton()
    private let postNewEventLabel = UILabel()
    private let dividerView = UIView()

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let addressLabel = UILabel()
    private let eventImageLabel = UILabel()
    private let uploadEventImageButton = UIButton()
    private let captionLabel = UILabel()
    private let captionText = UITextView()
    private let timeLabel = UILabel()
    private let eventDate = UIDatePicker()
    private let postEventButton = UIButton()

    private var imagePicker = UIImagePickerController()

    private var selectedPin: MKPointAnnotation
    private var eventImageUrl: URL?
    private var providedAddress: String!

    init(selectedPin: MKPointAnnotation) {
        self.selectedPin = selectedPin
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupLayout()
    }

    // address: An address passed from the previous view controller
    // This function is used to initialize the address field in this controller.
    // TODO: Get rid of this stupid function
    func setAddressLabelText() {
        let addressPrompt = "Event Address: \n"
        let providedAddress = selectedPin.title ?? "Not Provided"
        self.providedAddress = providedAddress
        let addressLabelString = "\(addressPrompt)\(providedAddress)"
        let nsrange = NSMakeRange(addressPrompt.count, providedAddress.count)
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: addressLabelString)
        attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 20, weight: .semibold), range: nsrange)
        addressLabel.attributedText = attributedString
    }
}

// MARK: Button functions
extension UploadEventViewController {
    @objc private func postNewEvent(_ sender: UIButton) {
        // TODO: Disable button until all fields are filled in
        print("Post new event pressed")
        postEventButton.isUserInteractionEnabled = false
        defer {
            postEventButton.isUserInteractionEnabled = true
        }
        guard let currentUser = UserService.currentUserProfile else { fatalError("Posting new event without valid userProfile") }
        // TODO: Allow no image?
        guard let eventImageUrl = eventImageUrl else { fatalError("event image url is nil") }
        let eventPostID = Util.generateId()
        let description = "Not implemented yet 🤡"
//        let event = Event(currentUser, eventImageUrl.absoluteString, description, providedAddress, eventDate.date, selectedPin.coordinate)
//        let eventPost = EventPost(event, captionText.text, Date(), eventPostID)
//        let updates = [String: Any?]()
//        EventPostService.setEvent(eventPost, withUpdates: updates) { finalUpdates in
//            let updateRef = Database.database().reference()
//            updateRef.updateChildValues(finalUpdates.mapValues { $0 as Any }) { error, _ in
//                print("Successfully posted new event with eventPostId \(eventPostID)")
//                self.dismissNewEventViewControllers()
//            }
//        }
    }

    @objc func cancelButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @objc private func dismissNewEventViewControllers() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}


// MARK: Image picker & upload image
extension UploadEventViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func uploadEventImage(_ sender: Any) {
        print("Upload button pressed")
        // open image picker
        self.present(imagePicker, animated: true, completion: nil)
    }

    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    // TODO: Upload image so early?
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            guard let uid = UserService.currentUserProfile?.uid else { fatalError() }
            let eventImagePath = String(format: Constants.Storage.eventImages, uid, Util.generateId())

            let spinner = Util.displaySpinner(onView: postEventButton)
            // TODO: Delete old images uploaded here, if user uploads twice
            ImageService.uploadImage(pickedImage, eventImagePath) { eventUrl in
                guard let eventUrl = eventUrl else { fatalError("eventImageURL was nil") }
                self.eventImageUrl = eventUrl
                self.uploadEventImageButton.setImage(pickedImage, for: .normal)
                Util.roundedCorners(ofColor: .black, element: self.uploadEventImageButton)
                Util.removeSpinner(spinner)
                print("Set event image!")
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: Setup subviews
extension UploadEventViewController {
    private func setupSubviews() {
        backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(UploadEventViewController.cancelButtonPressed(_:)), for: .touchUpInside)
        headerView.addSubview(backButton)

        postNewEventLabel.text = "Post New Event"
        postNewEventLabel.numberOfLines = 1
        postNewEventLabel.textAlignment = .center
        postNewEventLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        headerView.addSubview(postNewEventLabel)

        dividerView.backgroundColor = .lightGray
        headerView.addSubview(dividerView)

        view.addSubview(headerView)

        addressLabel.font = UIFont.systemFont(ofSize: 20)
        addressLabel.numberOfLines = 0
        addressLabel.textAlignment = .center
        setAddressLabelText()
        contentView.addSubview(addressLabel)

        eventImageLabel.text = "Event Image:"
        eventImageLabel.font = UIFont.systemFont(ofSize: 20)
        eventImageLabel.numberOfLines = 1
        eventImageLabel.textAlignment = .center
        contentView.addSubview(eventImageLabel)

        uploadEventImageButton.setImage(#imageLiteral(resourceName: "defaultEvent"), for: .normal)
        uploadEventImageButton.addTarget(self, action: #selector(UploadEventViewController.uploadEventImage(_:)), for: .touchUpInside)
        contentView.addSubview(uploadEventImageButton)

        captionLabel.text = "Caption of Event"
        captionLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        captionLabel.numberOfLines = 1
        captionLabel.textAlignment = .center
        contentView.addSubview(captionLabel)

        Util.roundedCorners(ofColor: .lightGray, element: captionText)
        captionText.doneAccessory = true
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

        postEventButton.setTitle("Post", for: .normal)
        postEventButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        postEventButton.addTarget(self, action: #selector(UploadEventViewController.postNewEvent(_:)), for: .touchUpInside)
        postEventButton.backgroundColor = .lightGray
        Util.roundedCorners(ofColor: .lightGray, element: postEventButton)
        contentView.addSubview(postEventButton)

        contentView.backgroundColor = .white
        scrollView.addSubview(contentView)

        view.backgroundColor = .white
        view.addSubview(scrollView)

        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
    }

    private func setupLayout() {
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.height.equalTo(32)
            make.width.equalTo(32)
        }

        postNewEventLabel.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(10)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        dividerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(backButton.snp.bottom).offset(10)
            make.height.equalTo(2)
        }

        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(dividerView.snp.bottom)
        }

        addressLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.leading.equalTo(contentView.snp.leadingMargin)
            make.trailing.equalTo(contentView.snp.trailingMargin)
        }

        eventImageLabel.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(25)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        uploadEventImageButton.snp.makeConstraints { make in
            make.top.equalTo(eventImageLabel.snp.bottom)
            make.width.equalTo(150)
            make.height.equalTo(150)
            make.centerX.equalToSuperview()
        }

        captionLabel.snp.makeConstraints { make in
            make.top.equalTo(uploadEventImageButton.snp.bottom).offset(40)
            make.leading.equalTo(contentView.snp.leadingMargin)
            make.trailing.equalTo(contentView.snp.trailingMargin)
        }

        captionText.snp.makeConstraints { make in
            make.top.equalTo(captionLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalTo(225)
            make.height.equalTo(85)
        }

        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(captionText.snp.bottom).offset(35)
            make.leading.equalTo(contentView.snp.leadingMargin)
            make.trailing.equalTo(contentView.snp.trailingMargin)
        }

        eventDate.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(200)
        }

        postEventButton.snp.makeConstraints { make in
            make.top.equalTo(eventDate.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(90)
            make.height.equalTo(40)
            make.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view.snp.width)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
    }
}
