//
//  homeViewController.swift
//  Wagin
//
//  Created by Lucas Wotton on 4/26/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

class HomeViewController: UITableViewController {

    let dataSource = ["Sean", "Trong", "Yeah", "yeah", "yeah"]
    @IBOutlet var guestTableView: UITableView!

    override func viewDidLoad() {
        guestTableView.delegate = self
        guestTableView.dataSource = self
        super.viewDidLoad()
        setupSubviews()
        setupLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = guestTableView.dequeueReusableCell(withIdentifier: "GuestCell") as! GuestTableViewCell

        let label = UILabel()
        label.text = dataSource[indexPath.row]
        label.backgroundColor = UIColor.white
        label.textAlignment = .center
        print("label text: \(label.text)")
        cell.guestName = label

        return cell
    }

    private func setupSubviews() {
        view.backgroundColor = UIColor.black
    }

    private func setupLayout() {

    }
}
