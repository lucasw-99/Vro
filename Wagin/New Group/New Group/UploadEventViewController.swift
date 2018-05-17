//
//  UploadEventViewController.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/8/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import FirebaseAuth
import FirebaseDatabase

class UploadEventViewController: UIViewController {
    private let pin: MKPointAnnotation
    private let date: Date
    private let caption: String
    private var event: Event?

    private let eventLabel = UILabel()
    private let eventImageView = UIImageView()
    private let uploadEventImageButton = UIButton()

    private let postEventButton = UIButton()
    private var backButton = UIButton()

    private var imagePicker = UIImagePickerController()

    private let contentView = UIView()

    init(pin: MKPointAnnotation, date: Date, caption: String) {
        self.pin = pin
        self.date = date
        self.caption = caption
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

    @IBAction func backButtonPressed(_ sender: Any) {
        print("Back button pressed")
        navigationController?.popViewController(animated: true)
    }
}

// MARK: Setup subviews
extension UploadEventViewController {
    private func setupSubviews() {
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

        eventImageView.image = #imageLiteral(resourceName: "cloud")
        Util.makeImageCircular(image: eventImageView)
        contentView.addSubview(eventImageView)

        uploadEventImageButton.setImage(#imageLiteral(resourceName: "upload"), for: .normal)
        uploadEventImageButton.addTarget(self, action: #selector(UploadEventViewController.uploadEventImage(_:)), for: .touchUpInside)
        Util.roundedCorners(ofColor: .lightGray, element: uploadEventImageButton)
        contentView.addSubview(uploadEventImageButton)

        backButton.setTitle("Back", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        backButton.addTarget(self, action: #selector(UploadEventViewController.backButtonPressed(_:)), for: .touchUpInside)
        backButton.backgroundColor = .lightGray
        Util.roundedCorners(ofColor: .lightGray, element: backButton)
        contentView.addSubview(backButton)

        postEventButton.setTitle("Post", for: .normal)
        postEventButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        postEventButton.addTarget(self, action: #selector(UploadEventViewController.postNewEvent(_:)), for: .touchUpInside)
        postEventButton.backgroundColor = .lightGray
        Util.roundedCorners(ofColor: .lightGray, element: postEventButton)
        contentView.addSubview(postEventButton)

        contentView.backgroundColor = .white
        view.addSubview(contentView)

        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
    }

    private func setupLayout() {
        eventLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(45)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        eventImageView.snp.makeConstraints { make in
            make.top.equalTo(eventLabel.snp.bottom).offset(55)
            make.width.equalTo(100)
            make.height.equalTo(100)
            make.centerX.equalToSuperview()
        }

        uploadEventImageButton.snp.makeConstraints { make in
            make.top.equalTo(eventImageView.snp.bottom).offset(55)
            make.width.equalTo(90)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }

        postEventButton.snp.makeConstraints { make in
            make.top.equalTo(uploadEventImageButton.snp.bottom).offset(200)
            make.centerX.equalToSuperview()
            make.width.equalTo(90)
            make.height.equalTo(40)
        }

        backButton.snp.makeConstraints { make in
            make.top.equalTo(postEventButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(90)
            make.height.equalTo(40)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: Pick & upload event image
extension UploadEventViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBAction func uploadEventImage(_ sender: Any) {
        print("Upload button pressed")
        // open image picker
        self.present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    // TODO: Upload image so early?
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            guard let uid = UserService.currentUserProfile?.uid else { fatalError() }
            let eventImagePath = String(format: Constants.Storage.eventImages, uid, Util.generateID())
            
            let spinner = Util.displaySpinner(onView: postEventButton)
            ImageService.uploadImage(pickedImage, eventImagePath) { eventImageURL in
                if let url = eventImageURL {
                    self.event = Event(UserService.currentUserProfile!.uid, url.absoluteString, "Not implemented yet 😒", self.pin.title!, self.date)
                    self.eventImageView.image = pickedImage
                    Util.roundedCorners(ofColor: .black, element: self.eventImageView)
                    Util.removeSpinner(spinner)
                    print("set event!")
                } else {
                    print("Error with uploading event image")
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension UploadEventViewController {
    @IBAction func postNewEvent(_ sender: Any) {
        // TODO: Disable button until all fields are filled in
        print("Post new event pressed")
        guard let currentUser = UserService.currentUserProfile else { fatalError("Posting new event without valid userProfile") }
        let eventPostID = Util.generateID()
        // TODO: How is this going to evolve?
        let postedBy = currentUser

        // TODO: Make sure event is non-nil
        let eventPost = EventPost(postedBy, event!, Set<String>(), caption, Date(), eventPostID)
        EventPostService.setEvent(eventPost)
        EventPostService.setEventPostID(currentUser.uid, eventPostID)
        // TODO: Do things more serially
        let userFollowersPath = String(format: Constants.Database.userFollowers, currentUser.uid)
        let userFollowersRef = Database.database().reference().child(userFollowersPath)
        FollowersService.getFollowerInfo(currentUser.uid, userFollowersRef) { followerInfo in
            // add your uid so you can see your own posts
            var followers = followerInfo.followers
            followers.insert(currentUser.uid)
            // TODO: How does this work when posts are deleted?
            TimelineService.addPostToTimelines(followers, eventPostID) {
                // TODO: Learn how to use DispatchGroups so you don't have to do this BS
                self.dismissNewEventViewControllers()
            }
        }
    }

    private func dismissNewEventViewControllers() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
