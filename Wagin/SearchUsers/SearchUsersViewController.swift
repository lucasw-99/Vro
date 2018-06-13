//
//  SearchUsersViewController.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/11/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import Segmentio

class SearchUsersViewController: UIViewController, UIGestureRecognizerDelegate {
    private let searchBar = UISearchBar()
    private let userCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        return cv
    }()


    private var dataSource = [UserProfile]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupLayout()
    }

    @objc private func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        print("tap gesture recognizer called")
        view.endEditing(true)
    }
}

// MARK: Setup subviews
extension SearchUsersViewController {
    private func setupSubviews() {
        searchBar.autocorrectionType = .no
        searchBar.autocapitalizationType = .none
        searchBar.delegate = self
        view.addSubview(searchBar)

        userCollectionView.register(SearchUsersCollectionViewCell.self, forCellWithReuseIdentifier: Constants.Cells.searchUsersCell)
        userCollectionView.delegate = self
        userCollectionView.dataSource = self
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchUsersViewController.dismissKeyboard(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.cancelsTouchesInView = false
        userCollectionView.addGestureRecognizer(tapRecognizer)
        view.addSubview(userCollectionView)

        view.backgroundColor = .white
    }

    private func setupLayout() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(56)
        }

        userCollectionView.snp.makeConstraints { make in
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
            if let foundUser = user {
                self.dataSource = [foundUser]
            } else {
                self.dataSource = []
            }
            self.userCollectionView.reloadData()
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // TODO: Check if enough characters for autocomplete search?
        UserService.getPartialUsernameMatches(searchText) { matchingUsers in
            self.dataSource = matchingUsers
            DispatchQueue.main.async {
                self.userCollectionView.reloadData()
            }
        }
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
}

// MARK: Collection view
extension SearchUsersViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TODO: Change later to always return 1, check if it still works
        return dataSource.isEmpty ? 0 : 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = userCollectionView.dequeueReusableCell(withReuseIdentifier: Constants.Cells.searchUsersCell, for: indexPath) as! SearchUsersCollectionViewCell
        let user = dataSource[indexPath.section]
        cell.user = user
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // TODO: Empty table view here?
        let selectedUser = dataSource[indexPath.section]
        let userProfileController = UserProfileViewController(selectedUser)
        navigationController?.pushViewController(userProfileController, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let user = dataSource[indexPath.section]
        let sizingCell = SearchUsersCollectionViewCell()
        sizingCell.user = user
        let zeroHeightSize = CGSize(width: collectionView.frame.width - 5 - 5, height: 0)
        let size = sizingCell.contentView.systemLayoutSizeFitting(zeroHeightSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
        return size
    }
}

// Collection view flow layout
extension SearchUsersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 10, right: 5)
    }
}


