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
    private let usernameInput: UITextField = UITextField()
    private let passwordInput: UITextField = UITextField()
    private let usernameLabel: UILabel = UILabel()
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
        guard let user = Auth.auth().currentUser else { return }
        print("Going to home screen")
        let homeStoryBoard = UIStoryboard(name: "Home", bundle: nil)
        let nextViewController = homeStoryBoard.instantiateInitialViewController()
        present(nextViewController!, animated: true, completion: nil)
    }

    @objc func loginUser(_ sender: Any) {
        guard let username: String = usernameInput.text, username != "" else {
            print("Username empty")
            return
        }
        guard let password: String = passwordInput.text, password != "" else {
            print("password empty")
            return
        }
        print("Neither username nor password were empty")
        // TODO: Validate users
        let homeStoryBoard = UIStoryboard(name: "Home", bundle: nil)
        let nextViewController = homeStoryBoard.instantiateInitialViewController()
        present(nextViewController!, animated: true, completion: nil)
        //navigationController?.pushViewController(HomeViewController(), animated: true)
    }

    @objc func signupUser(_ sender: Any) {
        print("Called signupUser")
        navigationController?.pushViewController(SignupViewController(), animated: true)
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

