//
//  SearchUsersViewController.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/11/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

class SearchUsersViewController: UIViewController {
    private let searchBar = UISearchBar()
    private let userTable = UITableView()

    private var dataSource = [UserProfile]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupLayout()
    }

}

// MARK: Setup subviews
extension SearchUsersViewController {
    private func setupSubviews() {
        searchBar.autocorrectionType = .no
        searchBar.autocapitalizationType = .none
        searchBar.delegate = self
        view.addSubview(searchBar)

        userTable.register(SearchUsersTableViewCell.self, forCellReuseIdentifier: Constants.Cells.searchUsersCell)
        userTable.delegate = self
        userTable.dataSource = self
        view.addSubview(userTable)

        view.backgroundColor = .white
    }

    private func setupLayout() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(56)
        }

        userTable.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

// MARK: Search bar
extension SearchUsersViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        let usernameToFind = searchBar.text!
        UserService.fetchUser(usernameToFind) { user in
            print("userProfile: \(user)")
            if let foundUser = user {
                self.dataSource = [foundUser]
                self.userTable.reloadData()
            } else {
                // TODO: Do something when empty table view is shown
            }
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
}

// MARK: Table view
extension SearchUsersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cells.searchUsersCell, for: indexPath) as! SearchUsersTableViewCell
        let user = dataSource[indexPath.row]
        cell.updateCell(username: user.username)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: Empty table view here
        let selectedUser = dataSource[indexPath.row]
        let userProfileController = UserProfileViewController(selectedUser)
        navigationController?.pushViewController(userProfileController, animated: true)
    }
}
