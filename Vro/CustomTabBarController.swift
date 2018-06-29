//
//  CustomTabBarController.swift
//  Vro
//
//  Created by Lucas Wotton on 5/3/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        self.delegate = self
        tabBar.isTranslucent = false
        tabBar.alpha = 0.95
        tabBar.backgroundColor = UIColor.white
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
        let newsFeedNavController = UINavigationController(rootViewController: newsFeedController)
        newsFeedNavController.title = "News Feed"
        newsFeedNavController.isNavigationBarHidden = true
        newsFeedNavController.tabBarItem = UITabBarItem(title: "News Feed", image: #imageLiteral(resourceName: "party"), tag: 0)

        let searchUsersController = SearchViewController()
        let searchUsersNavController = UINavigationController(rootViewController: searchUsersController)
        searchUsersNavController.title = "Search"
        searchUsersNavController.isNavigationBarHidden = true
        searchUsersNavController.tabBarItem = UITabBarItem(title: "Search", image: #imageLiteral(resourceName: "magnifyingGlass"), tag: 1)

        let newEventController = NewEventDummyViewController()
        newEventController.title = "New Event"
        newEventController.tabBarItem = UITabBarItem(title: "New Event", image: #imageLiteral(resourceName: "plus"), tag: 2)

        let notificationsController = NotificationsViewController()
        let nearYouNavController = UINavigationController(rootViewController: notificationsController)
        nearYouNavController.title = "Notifications"
        nearYouNavController.isNavigationBarHidden = true
        nearYouNavController.tabBarItem = UITabBarItem(title: "Notifications", image: #imageLiteral(resourceName: "bell"), tag: 3)

        let manageProfileController = ManageProfileViewController()
        let manageProfileNavController = UINavigationController(rootViewController: manageProfileController)
        manageProfileNavController.title = "Manage Profile"
        manageProfileNavController.isNavigationBarHidden = true
        manageProfileNavController.tabBarItem = UITabBarItem(title: "Manage Profile", image: #imageLiteral(resourceName: "settings"), tag: 4)

        let tabBarItems = [newsFeedNavController, searchUsersNavController, newEventController, nearYouNavController, manageProfileNavController]

        self.viewControllers = tabBarItems
    }
}
