//
//  SignUpViewController.swift
//  Vro
//
//  Created by Lucas Wotton on 4/25/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import Alamofire

protocol UserSignupDelegate {
    func loginUser(_ username: String, _ password: String)
}

class SignupViewController: UIViewController {

    private let alertTitle: String = "Sign Up Error"

    private let titleLabel: UILabel = UILabel()
    private let emailLabel: UILabel = UILabel()
    private let usernameLabel: UILabel = UILabel()
    private let passwordLabel: UILabel = UILabel()
    private let emailInput: UITextField = UITextField()
    private let usernameInput: UITextField = UITextField()
    private let passwordInput: UITextField = UITextField()
    private let signupButton: UIButton = UIButton()

    private let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var loginUserDelegate: UserSignupDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setupSubviews() {
        view.backgroundColor = UIColor.black

        titleLabel.text = "VRO"
        titleLabel.textColor = UIColor.blue
        titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)

        emailLabel.text = "Email"
        emailLabel.textColor = UIColor.white
        emailLabel.font = UIFont.systemFont(ofSize: 20)
        emailLabel.textAlignment = .center
        view.addSubview(emailLabel)

        emailInput.backgroundColor = UIColor.white
        emailInput.borderStyle = .roundedRect
        emailInput.autocorrectionType = .no
        emailInput.autocapitalizationType = .none
        view.addSubview(emailInput)

        usernameLabel.text = "Username"
        usernameLabel.textColor = UIColor.white
        usernameLabel.font = UIFont.systemFont(ofSize: 20)
        usernameLabel.textAlignment = .center
        view.addSubview(usernameLabel)

        usernameInput.backgroundColor = UIColor.white
        usernameInput.borderStyle = .roundedRect
        usernameInput.autocorrectionType = .no
        usernameInput.autocapitalizationType = .none
        view.addSubview(usernameInput)

        passwordLabel.text = "Password"
        passwordLabel.textColor = UIColor.white
        passwordLabel.font = UIFont.systemFont(ofSize: 20)
        passwordLabel.textAlignment = .center
        view.addSubview(passwordLabel)

        passwordInput.backgroundColor = UIColor.white
        passwordInput.borderStyle = .roundedRect
        passwordInput.autocorrectionType = .no
        passwordInput.autocapitalizationType = .none
        passwordInput.isSecureTextEntry = true
        view.addSubview(passwordInput)

        signupButton.setTitle("Sign Up", for: .normal)
        signupButton.setTitleColor(UIColor.blue, for: .normal)
        signupButton.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        signupButton.translatesAutoresizingMaskIntoConstraints = false
        signupButton.addTarget(self, action: #selector(SignupViewController.signupUser(_:)), for: .touchUpInside)
        view.addSubview(signupButton)
    }

    private func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(85)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(50)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        emailInput.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.width.equalTo(175)
        }

        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(emailInput.snp.bottom).offset(50)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        usernameInput.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.width.equalTo(175)
        }

        passwordLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameInput.snp.bottom).offset(50)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        passwordInput.snp.makeConstraints { make in
            make.top.equalTo(passwordLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.width.equalTo(175)
        }

        signupButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-50)
            make.centerX.equalToSuperview()
        }
    }

    @objc func signupUser(_ sender: Any) {
        guard let email = emailInput.text, email != "" else {
            let alert = Util.makeOKAlert(alertTitle: alertTitle, message: "Email cannot be empty")
            present(alert, animated: true, completion: nil)
            return
        }
        guard let username = usernameInput.text, username != "" else {
            let alert = Util.makeOKAlert(alertTitle: alertTitle, message: "Username cannot be empty")
            present(alert, animated: true, completion: nil)
            return
        }
        guard let password = passwordInput.text, password != "" else {
            let alert = Util.makeOKAlert(alertTitle: alertTitle, message: "Password cannot be empty")
            present(alert, animated: true, completion: nil)
            return
        }
        createUser(email, username, password)
    }

    private func createUser(_ email: String, _ username: String, _ password: String) {
        let spinner = Util.displaySpinner(onView: view)
        Util.toggleButton(button: self.signupButton, isEnabled: false)
        UserService.createUser(email, username, password) { response in
            Util.removeSpinner(spinner)
            Util.toggleButton(button: self.signupButton, isEnabled: true)
            guard response.result.error == nil else {
                let error = response.result.error!
                let alert = Util.makeOKAlert(alertTitle: self.alertTitle, message: error.localizedDescription)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            guard let data = response.result.value as? [String: Any] else {
                let errorMessage = "No data was present in the response"
                let alert = Util.makeOKAlert(alertTitle: self.alertTitle, message: errorMessage)
                self.present(alert, animated: true, completion: nil)
                return
            }
            print("received data: \(data)")
            print("Now login!")
            self.loginUserDelegate?.loginUser(username, password)
        }
    }
}
