//
//  ImageService.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/5/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import Foundation
import UIKit

class ImageService {
    static func downloadImage(withURL url: URL, completion: @escaping (_ image: UIImage?) -> ()) {
        let dataTask = URLSession.shared.dataTask(with: url) { data, url, error in
            var downloadedImage: UIImage?
            if error != nil {
                print("Error: \(error!.localizedDescription)")
            }
            if let data = data {
                downloadedImage = UIImage(data: data)
            }
            DispatchQueue.main.async {
                completion(downloadedImage)
            }
        }
        dataTask.resume()
    }
}
