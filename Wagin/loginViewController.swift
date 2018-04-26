//
//  ViewController.swift
//  Wagin
//
//  Created by Lucas Wotton on 4/25/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

class loginViewController: UIViewController {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButtonText: UIButton!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginButton(_ sender: Any) {
        let username = self.username.text
        let password = self.password.text

        if username!.isEmpty || password!.isEmpty {
            print("No username or password")
            return
        }
    }

    @IBAction func cancelToMainViewController(_ segue: UIStoryboardSegue) {
    }

}

