//
//  ViewController.swift
//  Vro
//
//  Created by Lucas Wotton on 4/25/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import FirebaseAuth
import SnapKit
import Alamofire

class LoginViewController: UIViewController {
    private let backgroundImage: UIImageView = UIImageView(image: #imageLiteral(resourceName: "allMyVrosPng"))
    private let usernameInput: UITextField = UITextField()
    private let passwordInput: UITextField = UITextField()
    private let usernameLabel: UILabel = UILabel()
    private let passwordLabel: UILabel = UILabel()
    private let loginButton: UIButton = UIButton(type: .system)
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
    
    @objc func loginButtonPressed(_ sender: UIButton) {
        guard let username: String = usernameInput.text, username != "" else {
            let alert = Util.makeOKAlert(alertTitle: "Error with Sign In", message: "The email field is empty.")
            self.present(alert, animated: true, completion: nil)
            return
        }
        guard let password: String = passwordInput.text, password != "" else {
            let alert = Util.makeOKAlert(alertTitle: "Error with Sign In", message: "The password field is empty.")
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        loginUser(username, password)
    }

    @objc func signupUser(_ sender: Any) {
        let signupViewController = SignupViewController()
        signupViewController.loginUserDelegate = self
        navigationController?.pushViewController(signupViewController, animated: true)
    }

    private func setupSubviews() {
        view.backgroundColor = UIColor.white

        backgroundImage.alpha = 0.9
        view.addSubview(backgroundImage)

        usernameLabel.textAlignment = .center
        usernameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        usernameLabel.text = "Username"
        usernameLabel.textColor = UIColor.white
        view.addSubview(usernameLabel)

        usernameInput.backgroundColor = UIColor.white
        usernameInput.borderStyle = .roundedRect
        usernameInput.autocorrectionType = .no
        usernameInput.autocapitalizationType = .none
        view.addSubview(usernameInput)

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
        loginButton.addTarget(self, action: #selector(LoginViewController.loginButtonPressed(_:)), for: .touchUpInside)
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

        usernameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(75)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        usernameInput.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalTo(190)
        }

        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameInput.snp.bottom).offset(45)
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

extension LoginViewController: UserSignupDelegate {
    func loginUser(_ username: String, _ password: String) {
        Util.toggleButton(button: loginButton, isEnabled: false)
        // TODO: Validate user input
        let spinner = Util.displaySpinner(onView: view)
        
        let parameters: [String: Any] = [
            "username" : username,
            "password": password
        ]
        
        Alamofire.request("http://178.128.183.75/users/authenticate", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                Util.removeSpinner(spinner)
                Util.toggleButton(button: self.loginButton, isEnabled: true)
                guard response.result.error == nil else {
                    let error = response.result.error!
                    let alert = Util.makeOKAlert(alertTitle: "Error with Sign In", message: error.localizedDescription)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                guard let data = response.result.value as? [String: Any],
                    let success = data["success"] as? Bool else {
                    let errorMessage = "No data present in response"
                    let alert = Util.makeOKAlert(alertTitle: "Error with Sign In", message: errorMessage)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                if !success {
                    let alert = Util.makeOKAlert(alertTitle: "Error with Sign In", message: "Username or password incorrect")
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                print("received data: \(data)")
                guard let newUserPhotoUrl = URL(string: Constants.newUserProfilePhotoURL) else {
                    fatalError("new user photo URL doesn't work!")
                }
                
                guard let token = data["token"] as? String,
                    let userDict = data["user"] as? [String: Any],
                    let uid = userDict["id"] as? String,
                    let username = userDict["username"] as? String else {
                        fatalError("Malformatted data from server!")
                }
                let currentUser = UserProfile(uid, username, newUserPhotoUrl)
                UserService.loginUser(currentUser, token)
                
                self.usernameInput.text = ""
                self.passwordInput.text = ""
                let tabBar = CustomTabBarController()
                tabBar.initializeTabViewControllers()
                self.navigationController?.pushViewController(tabBar, animated: true)
        }
    }
}

