//
//  SplashViewController.swift
//  Vro
//
//  Created by Lucas Wotton on 8/15/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import SwiftSpinner
import SwiftKeychainWrapper

class SplashViewController: UIViewController {
    
    private let backgroundImage: UIImageView = UIImageView(image: #imageLiteral(resourceName: "allMyVrosPng"))

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupLayout()
        showStartingScreen()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        SwiftSpinner.show("Loading")
    }
}


// MARK: Setup subviews
private extension SplashViewController {
    private func setupSubviews() {
        view.addSubview(backgroundImage)
    }
    
    private func setupLayout() {
        backgroundImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}


// MARK: API calls to authenticate user
private extension SplashViewController {
    func showStartingScreen() {
        let username = KeychainWrapper.standard.string(forKey: Constants.Keychain.username)
        let password = KeychainWrapper.standard.string(forKey: Constants.Keychain.password)
        if let username = username, let password = password {
            // show tab bar
            UserService.authenticateUser(username, password) { error in
                if let error = error {
                    fatalError("Username and password were set but didn't authenticate properly. \(error.localizedDescription)")
                }
                SwiftSpinner.hide()
                AppDelegate.shared.rootViewController.switchToMainScreen()
            }
        } else {
            SwiftSpinner.hide()
            guard username == nil && password == nil else { fatalError("One of username or password wasn't nil") }
            AppDelegate.shared.rootViewController.showLoginScreen()
        }
    }
}
