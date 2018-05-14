//
//  ManageProfileViewController.swift
//  Wagin
//
//  Created by Lucas Wotton on 4/30/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import FirebaseStorageUI

class ManageProfileViewController: UIViewController {

    private let changeProfileButton = UIButton()
    private let profileLabel = UILabel()
    private let followerStatsLabel = UILabel()

    private let logoutButton = UIButton()
    private let logoutLabel = UILabel()

    private var imagePicker = UIImagePickerController()

    @IBAction func logoutUser(_ sender: Any) {
        try! Auth.auth().signOut()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupLayout()
    }

    private func setupSubviews() {
        changeProfileButton.setImage(#imageLiteral(resourceName: "add_user_male"), for: .normal)
        Util.roundedCorners(ofColor: .black, element: changeProfileButton.imageView!)
        changeProfileButton.addTarget(self, action: #selector(ManageProfileViewController.changeProfilePicture(_:)), for: .touchUpInside)
        view.addSubview(changeProfileButton)

        profileLabel.text = "Tap to change profile photo"
        profileLabel.textColor = .darkGray
        profileLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        profileLabel.numberOfLines = 1
        profileLabel.textAlignment = .center
        view.addSubview(profileLabel)

        guard let currentUser = UserService.currentUserProfile else { fatalError("Current User shouldn't be nil") }
        let followerCount = currentUser.followers.count
        let followingCount = currentUser.following.count
        followerStatsLabel.text = "\(followerCount) follower\(followerCount != 1 ? "s" : "")\n\(followingCount) following"
        followerStatsLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        followerStatsLabel.numberOfLines = 0
        followerStatsLabel.textAlignment = .center
        view.addSubview(followerStatsLabel)

        logoutButton.setImage(#imageLiteral(resourceName: "exit"), for: .normal)
        logoutButton.addTarget(self, action: #selector(ManageProfileViewController.logoutUser(_:)), for: .touchUpInside)
        view.addSubview(logoutButton)

        logoutLabel.text = "Tap to logout"
        logoutLabel.textColor = .darkGray
        logoutLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        logoutLabel.numberOfLines = 1
        logoutLabel.textAlignment = .center
        view.addSubview(logoutLabel)

        guard let currUser = UserService.currentUserProfile else { fatalError("Current user is nil") }
        setProfileImage(currUser.photoURL)

        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self

        view.backgroundColor = .white
    }

    private func setupLayout() {
        changeProfileButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.centerX.equalToSuperview()
            make.width.equalTo(75)
            make.height.equalTo(75)
        }

        changeProfileButton.imageView!.snp.makeConstraints { make in
            make.width.equalTo(75)
            make.height.equalTo(75)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        profileLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(changeProfileButton.snp.bottom).offset(15)
        }

        followerStatsLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(profileLabel.snp.bottom).offset(10)
        }

        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(followerStatsLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(50)
        }

        logoutLabel.snp.makeConstraints { make in
            make.top.equalTo(logoutButton.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }

    private func setProfileImage(_ url: URL) {
        ImageService.getImage(withURL: url, completion: { image in
            self.changeProfileButton.setImage(image, for: .normal)
            Util.makeImageCircular(image: self.changeProfileButton.imageView!, 75)
        })
    }
}

extension ManageProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBAction func changeProfilePicture(_ sender: Any) {
        // open image picker
        self.present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            changeProfileButton.setImage(pickedImage, for: .normal)
            Util.makeImageCircular(image: changeProfileButton.imageView!)
            ImageService.currentUserImage = pickedImage
            guard let uid = UserService.currentUserProfile?.uid else { fatalError("Current user is nil") }
            let profilePicPath = String(format: Constants.Storage.userProfileImage, uid)
            ImageService.uploadImage(pickedImage, profilePicPath) { url in
                guard let url = url else {
                    print("Url was nil")
                    return
                }
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.photoURL = url
                changeRequest?.commitChanges { error in
                    if error == nil {
                        let photoURLPath = String(format: Constants.Database.userProfilePhotoURL, UserService.currentUserProfile!.uid)
                        let photoURLRef = Database.database().reference().child(photoURLPath)
                        photoURLRef.setValue(url.absoluteString)
                        // photo url changed, so we need to update current user
                        UserService.updateCurrentUser(uid) {
                            // dismiss view after user has been updated
                            print("dismissing image picker")
                            self.dismiss(animated: true, completion: nil)
                        }
                    } else {
                        print("Error: \(error!.localizedDescription)")
                    }
                }
            }

        }
        picker.dismiss(animated: true, completion: nil)
    }
}
