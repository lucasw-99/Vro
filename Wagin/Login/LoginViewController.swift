//
//  ViewController.swift
//  Wagin
//
//  Created by Lucas Wotton on 4/25/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import FirebaseAuth
import SnapKit

class LoginViewController: UIViewController {
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButtonText: UIButton!

    private let backgroundImage: UIImageView = UIImageView(image: #imageLiteral(resourceName: "waginLoginScreensaver"))
    private let emailInput: UITextField = UITextField()
    private let passwordInput: UITextField = UITextField()
    private let emailLabel: UILabel = UILabel()
    private let passwordLabel: UILabel = UILabel()
    private let loginButton: UIButton = UIButton(type: UIButtonType.system)
    private let signupButton: UIButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupSubviews()
        setupLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @objc func loginUser(_ sender: Any) {

        guard let email: String = emailInput.text, email != "" else {
            let alert = Util.makeOKAlert(alertTitle: "Error with Sign In", message: "The email field is empty.")
            self.present(alert, animated: true, completion: nil)
            return
        }
        guard let password: String = passwordInput.text, password != "" else {
            let alert = Util.makeOKAlert(alertTitle: "Error with Sign In", message: "The password field is empty.")
            self.present(alert, animated: true, completion: nil)
            return
        }
        Util.toggleButton(button: loginButton, isEnabled: false)
        // TODO: Validate users
        let spinner = Util.displaySpinner(onView: view)
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if error == nil && user != nil {
                Util.removeSpinner(spinner)
                self.dismiss(animated: false, completion: nil)
                self.transitionToHome()
            } else {
                let alert = Util.makeOKAlert(alertTitle: "Error with Sign In", message: error!.localizedDescription)
                Util.removeSpinner(spinner)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    @objc func signupUser(_ sender: Any) {
        navigationController?.pushViewController(SignupViewController(), animated: true)
    }

    private func transitionToHome() {
        Util.toggleButton(button: self.loginButton, isEnabled: true)
        emailInput.text = ""
        passwordInput.text = ""
        let tabBar = UITabBarController()
        let homeStoryBoard = UIStoryboard(name: "Home", bundle: nil)
        Util.initializeTabViewControllers(tabBar: tabBar, storyBoard: homeStoryBoard)
        navigationController?.pushViewController(tabBar, animated: true)
    }

    private func setupSubviews() {
        view.backgroundColor = UIColor.white

        backgroundImage.alpha = 0.9
        view.addSubview(backgroundImage)

        emailLabel.textAlignment = .center
        emailLabel.font = UIFont.boldSystemFont(ofSize: 20)
        emailLabel.text = "Email"
        emailLabel.textColor = UIColor.white
        view.addSubview(emailLabel)

        emailInput.backgroundColor = UIColor.white
        emailInput.borderStyle = .roundedRect
        emailInput.autocorrectionType = .no
        emailInput.autocapitalizationType = .none
        view.addSubview(emailInput)

        passwordLabel.textAlignment = .center
        passwordLabel.font = UIFont.boldSystemFont(ofSize: 20)
        passwordLabel.text = "Password"
        passwordLabel.textColor = UIColor.white
        view.addSubview(passwordLabel)

        passwordInput.backgroundColor = UIColor.white
        passwordInput.borderStyle = .roundedRect
        passwordInput.autocorrectionType = .no
        passwordInput.autocapitalizationType = .none
        passwordInput.isSecureTextEntry = true
        view.addSubview(passwordInput)

        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(UIColor.blue, for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addTarget(self, action: #selector(LoginViewController.loginUser(_:)), for: .touchUpInside)
        view.addSubview(loginButton)

        signupButton.setTitle("Sign Up", for: .normal)
        signupButton.setTitleColor(UIColor.blue, for: .normal)
        signupButton.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        signupButton.translatesAutoresizingMaskIntoConstraints = false
        signupButton.addTarget(self, action: #selector(LoginViewController.signupUser(_:)), for: .touchUpInside)
        view.addSubview(signupButton)

    }

    private func setupLayout() {
        backgroundImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        emailLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(75)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        emailInput.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalTo(190)
        }

        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(emailInput.snp.bottom).offset(45)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        passwordInput.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalTo(190)
        }

        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordInput.snp.bottom).offset(45)
            make.centerX.equalToSuperview()
        }

        signupButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }

}

