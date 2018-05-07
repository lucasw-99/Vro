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
            let modalViewController = NewEventViewController()
            tabBarController.present(modalViewController, animated: true)
            return false
        } else {
            return true
        }
    }

    func initializeTabViewControllers() {
        let newsFeedController = NewsFeedViewController()
        newsFeedController.title = "News Feed"
        newsFeedController.tabBarItem = UITabBarItem(title: "News Feed", image: #imageLiteral(resourceName: "people"), tag: 0)

        let manageProfileController = ManageProfileViewController()
        manageProfileController.title = "Manage Profile"
        manageProfileController.tabBarItem = UITabBarItem(title: "Manage Profile", image: #imageLiteral(resourceName: "settings"), tag: 1)

        let nearYouController = MapViewController()
        nearYouController.title = "Near You"
        nearYouController.tabBarItem = UITabBarItem(title: "Near You", image: #imageLiteral(resourceName: "map_marker"), tag: 2)

        let newEventController = ChooseAddressViewController()
        newEventController.title = "New Event"
        newEventController.tabBarItem = UITabBarItem(title: "New Event", image: #imageLiteral(resourceName: "create_new"), tag: 3)

        let tabBarItems = [newsFeedController, manageProfileController, nearYouController, newEventController]

        self.viewControllers = tabBarItems
    }
}
