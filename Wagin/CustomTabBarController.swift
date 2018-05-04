//
//  CustomTabBarController.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/3/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        self.delegate = self
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is NewEventDummyViewController {
            // present modally
            let homeStoryBoard = UIStoryboard(name: "Home", bundle: nil)
            let nextViewController = homeStoryBoard.instantiateViewController(withIdentifier: "NewEvent")
            tabBarController.present(nextViewController, animated: true)
            return false
        } else {
            return true
        }
    }
}
