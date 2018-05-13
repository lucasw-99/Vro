//
//  UserProfileViewController.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/12/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import FirebaseDatabase

class UserProfileViewController: UIViewController {
    private let selectedUser: UserProfile

    private let usernameLabel = UILabel()
    private let profilePhotoView = UIImageView()
    private let followerStatsLabel = UILabel()
    private let followButton = UIButton()
    private let backButton = UIButton()

    // TODO: Add selectable followers and following, possibly in scroll view

    init(_ userProfile: UserProfile) {
        selectedUser = userProfile
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupLayout()
    }
}

// MARK: Setup subviews
extension UserProfileViewController {
    private func setupSubviews() {
        ImageService.getImage(withURL: selectedUser.photoURL) { image in
            guard let image = image else { fatalError("User image was nil") }
            self.profilePhotoView.image = image
            Util.makeImageCircular(image: self.profilePhotoView)
        }
        view.addSubview(profilePhotoView)

        usernameLabel.text = selectedUser.username
        usernameLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        usernameLabel.numberOfLines = 0
        usernameLabel.textAlignment = .center
        view.addSubview(usernameLabel)

        setupFollowingLabelText()
        followerStatsLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        followerStatsLabel.numberOfLines = 0
        followerStatsLabel.textAlignment = .center
        view.addSubview(followerStatsLabel)

        followButton.setTitle("Follow", for: .normal)
        followButton.setTitle("Following", for: .selected)
        followButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        followButton.setTitleColor(.black, for: .normal)
        // set state to selected if currentUser is already following selectedUser
        followButton.isSelected = UserService.currentUserProfile!.following.contains(selectedUser.uid)
        followButton.addTarget(self, action: #selector(UserProfileViewController.followButtonPressed(_:)), for: .touchUpInside)
        Util.roundedCorners(ofColor: .black, element: followButton)
        view.addSubview(followButton)

        backButton.setTitle("Back", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        backButton.setTitleColor(.black, for: .normal)
        backButton.addTarget(self, action: #selector(UserProfileViewController.backButtonPressed(_:)), for: .touchUpInside)
        Util.roundedCorners(ofColor: .black, element: backButton)
        view.addSubview(backButton)

        view.backgroundColor = .white
    }

    private func setupLayout() {
        profilePhotoView.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(100)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(50)
            make.centerX.equalToSuperview()
        }

        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(profilePhotoView.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        followerStatsLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(40)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        followButton.snp.makeConstraints { make in
            make.top.equalTo(followerStatsLabel.snp.bottom).offset(50)
            make.width.equalTo(100)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }

        backButton.snp.makeConstraints { make in
            make.top.equalTo(followButton.snp.bottom).offset(20)
            make.width.equalTo(100)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
    }

    private func setupFollowingLabelText() {
        let followerCount = selectedUser.following.count
        let followingCount = selectedUser.followers.count
        followerStatsLabel.text = "\(followerCount) follower\(followerCount != 1 ? "s" : "")\n\(followingCount) following"
    }
}

// MARK: Button functions
extension UserProfileViewController {
    @objc private func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @objc private func followButtonPressed(_ sender: Any) {
        // disable button while editing
        followButton.isEnabled = false
        let wasSelected = followButton.isSelected
        followButton.isSelected = !followButton.isSelected
        let currentUser = UserService.currentUserProfile!
        if wasSelected {
            guard let followingIndex = currentUser.following.index(of: selectedUser.uid) else { fatalError("Says that user was following other user, but they weren't in the following list") }
            currentUser.following.remove(at: followingIndex)

            guard let followerIndex = selectedUser.followers.index(of: currentUser.uid) else { fatalError("Issue with follower counts") }
            selectedUser.followers.remove(at: followerIndex)

        } else {
            currentUser.following.append(selectedUser.uid)
            selectedUser.followers.append(currentUser.uid)
        }
        updateFollowArrays(currentUser: currentUser, selectedUser: selectedUser)
        UserService.updateCurrentUser(currentUser.uid)
        setupFollowingLabelText()
        followButton.isEnabled = true
    }

    private func updateFollowArrays(currentUser: UserProfile, selectedUser: UserProfile) {
        // edit the selectedUser's followers list, and the currentUser's following list
        let followersPath = String(format: Constants.Database.userFollowers, selectedUser.uid)
        let followingPath = String(format: Constants.Database.userFollowing, currentUser.uid)

        let followersRef = Database.database().reference().child(followersPath)
        followersRef.setValue(selectedUser.followers)

        let followingRef = Database.database().reference().child(followingPath)
        followingRef.setValue(currentUser.following)
        print("Updated database!")
    }

}
