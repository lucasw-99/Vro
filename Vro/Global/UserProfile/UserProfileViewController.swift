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
    private var selectedUserFollowers: UserFollowers!
    private let selectedUserFollowersRef: DatabaseReference

    private let headerView = UIView()
    private let backButton = UIButton()
    private let usernameLabel = UILabel()
    private let separatorView = UIView()
    private let profilePhotoView = UIImageView()
    private let followerStatsLabel = UILabel()
    private let followButton = UIButton()
    
    private let userProfileLabel = UILabel()
    private let likesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        return cv
    }()
    
    private var dataSource = [EventPost]()

    // TODO: Add selectable followers and following, possibly in scroll view. Maybe
    // make it linkable text??

    init(_ userProfile: UserProfile) {
        selectedUser = userProfile
        guard let currentUserUID = UserService.currentUserProfile?.uid else { fatalError("current user nil") }
        let selectedUserFollowersPath = String(format: Constants.Database.userFollowerInfo, selectedUser.uid)
        selectedUserFollowersRef = Database.database().reference().child(selectedUserFollowersPath)
        
        super.init(nibName: nil, bundle: nil)

        // disable follow button until observable fires
        followButton.isUserInteractionEnabled = false

        // TODO: Put this code in viewDidDisappear and remove the DatabaseReferences
        FollowersService.getFollowerInfo(selectedUser.uid, selectedUserFollowersRef) { selectedUserFollowerInfo in
            print("UserProfileViewController selectedUser observable")
            self.selectedUserFollowers = selectedUserFollowerInfo
            self.setupFollowingLabelText()
            let currentUser = Follower(currentUserUID)
            self.followButton.isSelected = selectedUserFollowerInfo.followers.contains(currentUser)
            self.followButton.isUserInteractionEnabled = true
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
        backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(UserProfileViewController.backButtonPressed(_:)), for: .touchUpInside)
        headerView.addSubview(backButton)
        
        usernameLabel.text = selectedUser.username
        usernameLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        usernameLabel.numberOfLines = 0
        usernameLabel.textAlignment = .center
        headerView.addSubview(usernameLabel)
        
        view.addSubview(headerView)
        
        separatorView.backgroundColor = .gray
        view.addSubview(separatorView)
        
        ImageService.getImage(withURL: selectedUser.photoURL) { image in
            guard let image = image else { fatalError("User image was nil") }
            self.profilePhotoView.image = image
            Util.makeImageCircular(image: self.profilePhotoView, 100)
        }
        view.addSubview(profilePhotoView)

        followerStatsLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        followerStatsLabel.numberOfLines = 0
        followerStatsLabel.textAlignment = .center
        view.addSubview(followerStatsLabel)

        followButton.setTitle("Follow", for: .normal)
        followButton.setTitle("Following", for: .selected)
        followButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        followButton.setTitleColor(.black, for: .normal)
        followButton.addTarget(self, action: #selector(UserProfileViewController.followButtonPressed(_:)), for: .touchUpInside)
        // don't show follow button if you're looking up your own profile
        followButton.isHidden = UserService.currentUserProfile!.uid == selectedUser.uid ? true : false
        Util.roundedCorners(ofColor: .black, element: followButton)
        view.addSubview(followButton)

        view.backgroundColor = .white
    }

    private func setupLayout() {
        usernameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.leading.equalTo(backButton.snp.trailing).offset(20)
        }
        
        backButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.leading.equalToSuperview().offset(15)
        }

        headerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
        }
        
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(1)
        }

        profilePhotoView.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(100)
            make.top.equalTo(separatorView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }

        followerStatsLabel.snp.makeConstraints { make in
            make.top.equalTo(profilePhotoView.snp.bottom).offset(40)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        followButton.snp.makeConstraints { make in
            make.top.equalTo(followerStatsLabel.snp.bottom).offset(50)
            make.width.equalTo(100)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
    }

    private func setupFollowingLabelText() {
        let followerCount = selectedUserFollowers.followers.count
        let followingCount = selectedUserFollowers.following.count
        followerStatsLabel.text = "\(followerCount) follower\(followerCount != 1 ? "s" : "")\n\(followingCount) following"
    }
}

// MARK: Button functions
extension UserProfileViewController {
    @objc private func backButtonPressed(_ sender: UIButton) {
        // Stop observing updates to user followers
        print("back button pressed")
        selectedUserFollowersRef.removeAllObservers()
        navigationController?.popViewController(animated: true)
    }

    @objc private func followButtonPressed(_ sender: Any) {
        // disable button while editing
        Util.toggleButton(button: self.followButton, isEnabled: false)
        guard let currentUser = UserService.currentUserProfile else { fatalError("current user nil??") }
        print("follow button disabled")
        let wasSelected = followButton.isSelected
        followButton.isSelected = !followButton.isSelected
        print("updating followers")
        FollowersService.updateFollowers(uid: currentUser.uid, followedUid: selectedUserFollowers.uid, addFollower: !wasSelected) {
            Util.toggleButton(button: self.followButton, isEnabled: true)
        }
    }
}
