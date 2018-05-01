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

class ManageProfileViewController: UIViewController {

    private var imagePicker = UIImagePickerController()
    @IBOutlet weak var profilePictureButton: UIButton!

    @IBAction func logOutUser(_ sender: Any) {
        try! Auth.auth().signOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeProfilePicture(_ sender: Any) {
        print("Called changeProfilePicture")
        // open image picker
        self.present(imagePicker, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupLayout()
        // Do any additional setup after loading the view.
    }

    private func setupSubviews() {
        Util.makeImageCircular(image: profilePictureButton.imageView!)

        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
    }

    private func setupLayout() {

    }
}

extension ManageProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            profilePictureButton.setImage(pickedImage, for: .normal)
            Util.makeImageCircular(image: profilePictureButton.imageView!)
            print("Changing user profile")
            self.uploadProfileImage(pickedImage) { url in
                guard let url = url else {
                    print("Url was nil")
                    return
                }
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.photoURL = url

                changeRequest?.commitChanges { error in
                    if error == nil {
                        print("User photo url committed")
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

    func uploadProfileImage(_ image: UIImage, completion: @escaping ((_ url: URL?) -> ())) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let filename = "user/\(uid)"
        let storageRef = Storage.storage().reference().child(filename)

        guard let imageData = UIImageJPEGRepresentation(image, 0.75) else {
            print()
            return
        }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil {
                Storage.storage().reference().child(filename).downloadURL { (url, error) in
                    if error == nil {
                        guard let imageUrl = url?.absoluteURL else {
                            print("Failed to upload photo")
                            completion(nil)
                            return
                        }
                        completion(imageUrl)
                    } else {
                        print("Failed to upload photo")
                        completion(nil)
                    }
                }
                print("Successfully uploaded photo")
            } else {
                print("Failed to upload photo")
                completion(nil)
            }
        }
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
