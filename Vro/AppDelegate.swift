//
//  AppDelegate.swift
//  Vro
//
//  Created by Lucas Wotton on 4/25/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        window = UIWindow(frame: UIScreen.main.bounds)
        // TODO: Handle deleted users still having valid auth tokens
        let authListener = Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                // user is logged in
                // TODO: Add these calls appwide
                UserService.updateCurrentUser(user.uid) {
                    // current user is initialized, now log in
                    let tabBar = CustomTabBarController()
                    tabBar.initializeTabViewControllers()

                    let navigationController = UINavigationController(rootViewController: tabBar)
                    navigationController.isNavigationBarHidden = true
                    self.window?.rootViewController = navigationController
                    self.window?.makeKeyAndVisible()
                }
            } else {
                UserService.currentUserProfile = nil

                let loginViewController = LoginViewController()
                loginViewController.view.backgroundColor = UIColor.black
                let navigationController = UINavigationController(rootViewController: loginViewController)
                navigationController.navigationBar.isTranslucent = false
                self.window?.rootViewController = navigationController
                self.window?.makeKeyAndVisible()
            }
        }
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
