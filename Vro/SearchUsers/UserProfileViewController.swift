//
//  UserProfileViewController.swift
//  Vro
//
//  Created by Lucas Wotton on 5/12/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SnapKit

class UserProfileViewController: UIViewController {
    private let selectedUser: UserProfile

    private var selectedUserFollowers: UserFollowers?
    private var currentUserFollowers: UserFollowers?

    private let selectedUserFollowersRef: DatabaseReference
    private let currentUserFollowersRef: DatabaseReference

    private let usernameLabel = UILabel()
    private let profilePhotoView = UIImageView()
    private let followerStatsLabel = UILabel()
    private let followButton = UIButton()
    private let backButton = UIButton()

    // TODO: Add selectable followers and following, possibly in scroll view. Maybe
    // make it linkable text??

    init(_ userProfile: UserProfile) {
        selectedUser = userProfile
        guard let currentUserUID = UserService.currentUserProfile?.uid else { fatalError("current user nil") }
        let selectedUserFollowersPath = String(format: Constants.Database.userFollowerInfo, selectedUser.uid)
        selectedUserFollowersRef = Database.database().reference().child(selectedUserFollowersPath)
        let currentUserFollowersPath = String(format: Constants.Database.userFollowerInfo, currentUserUID)
        currentUserFollowersRef = Database.database().reference().child(currentUserFollowersPath)
        super.init(nibName: nil, bundle: nil)

        // disable follow button until both observables fire
        followButton.isUserInteractionEnabled = false

        // TODO: Figure out how to avoid potential race condition with setting followButton.isEnabled
        // TODO: Put this code in viewDidDisappear and remove the DatabaseReferences
        FollowersService.getFollowerInfo(selectedUser.uid, selectedUserFollowersRef) { selectedUserFollowerInfo in
            print("UserProfileViewController selectedUser observable")
            self.selectedUserFollowers = selectedUserFollowerInfo
            self.setupFollowingLabelText()
            self.setFollowButtonIsSelected()
            if self.currentUserFollowers != nil {
                self.followButton.isUserInteractionEnabled = true
            }
        }

        FollowersService.getFollowerInfo(currentUserUID, currentUserFollowersRef) { currentUserFollowerInfo in
            print("UserProfileViewController currentUser observable")
            self.currentUserFollowers = currentUserFollowerInfo
            self.setFollowButtonIsSelected()
            if self.selectedUserFollowers != nil {
                self.followButton.isUserInteractionEnabled = true
            }
        }
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
        setFollowButtonIsSelected()
        followButton.addTarget(self, action: #selector(UserProfileViewController.followButtonPressed(_:)), for: .touchUpInside)
        // don't show follow button if you're looking up your own profile
        followButton.isHidden = UserService.currentUserProfile!.uid == selectedUser.uid ? true : false
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

        let (backButtonTopAnchor, offset) = UserService.currentUserProfile!.uid != selectedUser.uid ? (followButton.snp.bottom, 20) : (followerStatsLabel.snp.bottom, 50)

        backButton.snp.makeConstraints { make in
            make.top.equalTo(backButtonTopAnchor).offset(offset)
            make.width.equalTo(100)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
    }

    private func setupFollowingLabelText() {
        let followerCount = selectedUserFollowers?.followers.count ?? 0
        let followingCount = selectedUserFollowers?.following.count ?? 0
        followerStatsLabel.text = "\(followerCount) follower\(followerCount != 1 ? "s" : "")\n\(followingCount) following"
    }

    private func setFollowButtonIsSelected() {
        // set state to selected if currentUser is already following selectedUser
        if let currFollowing = currentUserFollowers?.following {
            followButton.isSelected = currFollowing.contains(selectedUser.uid)
        } else if let selectedFollowers = selectedUserFollowers?.followers {
            guard let currUID = UserService.currentUserProfile?.uid else { fatalError("Current user nil") }
            let currUser = Follower(currUID)
            followButton.isSelected = selectedFollowers.contains(currUser)
        } else {
            followButton.isSelected = false
        }
    }
}

// MARK: Button functions
extension UserProfileViewController {
    @objc private func backButtonPressed(_ sender: Any) {
        // Stop observing updates to user followers
        selectedUserFollowersRef.removeAllObservers()
        currentUserFollowersRef.removeAllObservers()
        navigationController?.popViewController(animated: true)
    }

    @objc private func followButtonPressed(_ sender: Any) {
        // disable button while editing
        Util.toggleButton(button: self.followButton, isEnabled: false)
        print("follow button disabled")
        let wasSelected = followButton.isSelected
        followButton.isSelected = !followButton.isSelected
        guard let currentUser = currentUserFollowers else { fatalError("follow button pressed before currentUserFollowers was initialized") }
        guard let followedUser = selectedUserFollowers else { fatalError("follow button pressed before selectedUserFollowers was initialized") }
        let currentUserFollower = Follower(currentUser.uid)
        let followedUserFollower = Follower(followedUser.uid)
        if wasSelected {
            guard followedUser.followers.contains(currentUserFollower) else { fatalError("Says that user was following other user, but they weren't in the other users followers list") }
            followedUser.followers.remove(currentUserFollower)

            guard currentUser.following.contains(followedUserFollower.followerId) else { fatalError("Issue with follower counts") }
            currentUser.following.remove(followedUserFollower.followerId)

        } else {
            currentUser.following.insert(followedUserFollower.followerId)
            followedUser.followers.insert(currentUserFollower)
        }
        // TODO: Check for adding vs removing followers, use wasSelected
        print("updating followers")
        FollowersService.updateFollowers(uid: currentUser.uid, followedUid: followedUser.uid, addFollower: !wasSelected) {
            Util.toggleButton(button: self.followButton, isEnabled: true)
        }
    }
}
