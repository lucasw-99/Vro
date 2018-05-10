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

    private let logoutButton = UIButton()
    private let logoutLabel = UILabel()

    private var imagePicker = UIImagePickerController()

    private var setProfileImage = false

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
        changeProfileButton.addTarget(self, action: #selector(ManageProfileViewController.changeProfilePicture(_:)), for: .touchUpInside)
        view.addSubview(changeProfileButton)

        profileLabel.text = "Tap to change profile photo"
        profileLabel.textColor = .darkGray
        profileLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        profileLabel.numberOfLines = 1
        profileLabel.textAlignment = .center
        view.addSubview(profileLabel)

        logoutButton.setImage(#imageLiteral(resourceName: "exit"), for: .normal)
        logoutButton.addTarget(self, action: #selector(ManageProfileViewController.logoutUser(_:)), for: .touchUpInside)
        view.addSubview(logoutButton)

        logoutLabel.text = "Tap to logout"
        logoutLabel.textColor = .darkGray
        logoutLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        logoutLabel.numberOfLines = 1
        logoutLabel.textAlignment = .center
        view.addSubview(logoutLabel)

        changeProfileButton.setImage(#imageLiteral(resourceName: "add_user_male"), for: .normal)
        if let currUser = UserService.currentUserProfile {
            setProfileImage(currUser.photoURL)
        } else {
            let uid = Auth.auth().currentUser!.uid
            let userRef = Database.database().reference().child("users/profile/\(uid)/photoURL")
            userRef.observe(.value) { snapshot in
                if let absolutePhotoURL = snapshot.value as? String,
                    let photoURL = URL(string: absolutePhotoURL) {
                    self.setProfileImage(photoURL)
                }
            }
        }

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

        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(profileLabel.snp.bottom).offset(20)
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
            ImageService.uploadImage(pickedImage) { url in
                guard let url = url else {
                    print("Url was nil")
                    return
                }
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.photoURL = url

                changeRequest?.commitChanges { error in
                    if error == nil {
                        self.saveProfile(profileImageUrl: url) { success in
                            if success {
                                self.dismiss(animated: true, completion: nil)
                            } else {
                                print("Error")
                            }
                        }
                    } else {
                        print("Error: \(error!.localizedDescription)")
                    }
                }
            }

        }
        picker.dismiss(animated: true, completion: nil)
    }

    func saveProfile(profileImageUrl: URL, completion: @escaping ((_ success: Bool) -> ())) {
        guard let username = Auth.auth().currentUser?.displayName else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let databaseRef = Database.database().reference().child("users/profile/\(uid)")

        let userObject = [
            "username": username,
            "photoURL": profileImageUrl.absoluteString
        ] as [String: Any]

        databaseRef.setValue(userObject) { error, ref in
            completion(error == nil)
        }
    }
}
