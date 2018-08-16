//
//  RootViewController.swift
//  Vro
//
//  Created by Lucas Wotton on 8/15/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//
// Based on https://medium.com/@stasost/ios-root-controller-navigation-3625eedbbff

import UIKit

class RootViewController: UIViewController {
    private var current: UIViewController
    
    init() {
        self.current = SplashViewController()
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildViewController(current)
        current.view.frame = view.bounds
        view.addSubview(current.view)
        current.didMove(toParentViewController: self)
    }
}

// MARK: Screen transitions
extension RootViewController {
    func switchToMainScreen() {
        let tabBar = CustomTabBarController()
        tabBar.initializeTabViewControllers()
        animateFadeTransition(to: tabBar)
    }
    
    func showLoginScreen() {
        let loginScreen = UINavigationController(rootViewController: LoginViewController())
        loginScreen.isNavigationBarHidden = true
        addChildViewController(loginScreen)
        loginScreen.view.frame = view.bounds
        view.addSubview(loginScreen.view)
        loginScreen.didMove(toParentViewController: self)
        current.willMove(toParentViewController: nil)
        current.view.removeFromSuperview()
        current.removeFromParentViewController()
        current = loginScreen
    }
    
    func switchToLogout() {
        let loginViewController = LoginViewController()
        let logoutScreen = UINavigationController(rootViewController: loginViewController)
        logoutScreen.isNavigationBarHidden = true
        animateDismissTransition(to: logoutScreen)
    }
    
    private func animateFadeTransition(to newVC: UIViewController, completion: (() -> Void)? = nil) {
        current.willMove(toParentViewController: nil)
        addChildViewController(newVC)
        
        transition(from: current, to: newVC, duration: 0.3, options: [.transitionCrossDissolve, .curveEaseOut], animations: {
        }) { completed in
            self.current.removeFromParentViewController()
            newVC.didMove(toParentViewController: self)
            self.current = newVC
            completion?()
        }
    }
    
    private func animateDismissTransition(to new: UIViewController, completion: (() -> Void)? = nil) {
        current.willMove(toParentViewController: nil)
        addChildViewController(new)
        transition(from: current, to: new, duration: 0.3, options: [], animations: {
            new.view.frame = self.view.bounds
        }) { completed in
            self.current.removeFromParentViewController()
            new.didMove(toParentViewController: self)
            self.current = new
            completion?()
        }
    }
}
