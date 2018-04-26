//
//  SignUpViewController.swift
//  Wagin
//
//  Created by Lucas Wotton on 4/25/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func signUpButtonClicked(_ sender: Any) {
        print("Sign up button clicked")
        guard let email = emailTextField.text, let username = usernameTextField.text, let password = passwordTextField.text else { return }
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if user != nil && error == nil {
                print("User created")
                // reassign userID to username
                let changeUsernameRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeUsernameRequest?.displayName = username
                changeUsernameRequest?.commitChanges { error in
                    if error == nil {
                        print("Username created")
                        self.dismiss(animated: true) { print("Dismissed signUpView")}
                    } else {
                        print("Username not changed")
                    }
                }
            } else {
                print("Error creating user: \(error!.localizedDescription)")
            }
        }

    }

}
