//
//  ImageService.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/5/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseStorage

class ImageService {
    static let cache = NSCache<NSString, UIImage>()
    static var currentUserImage: UIImage?

    static func downloadImage(withURL url: URL, completion: @escaping (_ image: UIImage?) -> ()) {
        let dataTask = URLSession.shared.dataTask(with: url) { data, responseURL, error in
            var downloadedImage: UIImage?
            if error != nil {
                print("Error: \(error!.localizedDescription)")
            }
            if let data = data {
                downloadedImage = UIImage(data: data)
            }

            if downloadedImage != nil {
                cache.setObject(downloadedImage!, forKey: url.absoluteString as NSString)
            }

            DispatchQueue.main.async {
                completion(downloadedImage)
            }
        }
        dataTask.resume()
    }

    static func getImage(withURL url: URL, completion: @escaping (_ image: UIImage?) -> ()) {
        if let image = cache.object(forKey: url.absoluteString as NSString) {
            completion(image)
        } else {
            downloadImage(withURL: url, completion: completion)
        }
    }

    static func uploadImage(_ image: UIImage, _ section: String, completion: @escaping ((_ url: URL?) -> ())) {
        let storageRef = Storage.storage().reference().child(section)

        guard let imageData = UIImageJPEGRepresentation(image, 0.75) else {
            return
        }
        // TODO: Add an observer
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil {
                storageRef.downloadURL { (url, error) in
                    if error == nil {
                        guard let imageUrl = url?.absoluteURL else {
                            print("Failed to upload photo")
                            completion(nil)
                            return
                        }
                        // cache image
                        cache.setObject(image, forKey: imageUrl.absoluteString as NSString)
                        print("Successfully uploaded photo")
                        completion(imageUrl)
                    } else {
                        print("Failed to upload photo")
                        completion(nil)
                    }
                }
            } else {
                print("Failed to upload photo")
                completion(nil)
            }
        }
    }

    static func updateUserImage(_ userPhotoURL: URL) {
        ImageService.getImage(withURL: userPhotoURL, completion: { userImage in
            guard let userImage = userImage else { fatalError("User image is nil") }
            ImageService.currentUserImage = userImage
        })
    }
}
