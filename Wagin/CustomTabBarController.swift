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
            // present new navigation controller modally
            let modalViewController = ChooseAddressViewController()
            let navController = UINavigationController(rootViewController: modalViewController)
            navController.setNavigationBarHidden(true, animated: false)
            tabBarController.present(navController, animated: true)
            return false
        } else {
            return true
        }
    }

    func initializeTabViewControllers() {
        let newsFeedController = NewsFeedViewController()
        newsFeedController.title = "News Feed"
        newsFeedController.tabBarItem = UITabBarItem(title: "News Feed", image: #imageLiteral(resourceName: "party"), tag: 0)

        let searchUsersController = SearchViewController()
        searchUsersController.title = "Search"
        searchUsersController.tabBarItem = UITabBarItem(title: "Search Users", image: #imageLiteral(resourceName: "magnifyingGlass"), tag: 1)

        let newEventController = NewEventDummyViewController()
        newEventController.title = "New Event"
        newEventController.tabBarItem = UITabBarItem(title: "New Event", image: #imageLiteral(resourceName: "plus"), tag: 2)

        let nearYouController = MapViewController()
        nearYouController.title = "Near You"
        nearYouController.tabBarItem = UITabBarItem(title: "Near You", image: #imageLiteral(resourceName: "earth"), tag: 3)

        let manageProfileController = ManageProfileViewController()
        manageProfileController.title = "Manage Profile"
        manageProfileController.tabBarItem = UITabBarItem(title: "Manage Profile", image: #imageLiteral(resourceName: "settings"), tag: 4)

        let tabBarItems = [newsFeedController, searchUsersController, newEventController, nearYouController, manageProfileController]

        self.viewControllers = tabBarItems
    }
}
