//
//  ProfileHeaderCollectionViewCell.swift
//  Vro
//
//  Created by Lucas Wotton on 7/26/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ProfileHeaderCollectionViewCell: UICollectionViewCell {
    private let profilePhotoView = UIImageView()
    private let followerStatsLabel = UILabel()
    private let followButton = UIButton()
    private let separatorView = UIView()
    
    private let currentUser: UserProfile
    private var followerCount: Int
    private var followingCount: Int
    
    var selectedUser: UserProfile! {
        didSet {
            updateUI()
        }
    }

    override init(frame: CGRect) {
        guard let user = UserService.currentUserProfile else { fatalError("Current user is nil fuk") }
        self.currentUser = user
        self.followerCount = 0
        self.followingCount = 0
        super.init(frame: frame)
        setupSubviews()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: Setup subviews
private extension ProfileHeaderCollectionViewCell {
    private func setupSubviews() {
        contentView.addSubview(profilePhotoView)
        
        // TODO: Weird stuff going on with this not showing up..
        followerStatsLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        followerStatsLabel.textColor = UIColor.black
        followerStatsLabel.numberOfLines = 0
        followerStatsLabel.textAlignment = .center
        followerStatsLabel.text = "\(followerCount) follower\(followerCount != 1 ? "s" : "")\n\(followingCount) following"
        contentView.addSubview(followerStatsLabel)
        
        followButton.setTitle("Follow", for: .normal)
        followButton.setTitle("Following", for: .selected)
        followButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        followButton.setTitleColor(.black, for: .normal)
        followButton.addTarget(self, action: #selector(ProfileHeaderCollectionViewCell.followButtonPressed(_:)), for: .touchUpInside)
        Util.roundedCorners(ofColor: .black, element: followButton)
        self.followButton.isUserInteractionEnabled = false
        contentView.addSubview(followButton)
        
        separatorView.backgroundColor = .gray
        contentView.addSubview(separatorView)
    }
    
    private func setupLayout() {
        profilePhotoView.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(100)
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        
        followerStatsLabel.snp.makeConstraints { make in
            make.top.equalTo(profilePhotoView.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        followButton.snp.makeConstraints { make in
            make.top.equalTo(followerStatsLabel.snp.bottom).offset(30)
            make.width.equalTo(100)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
    }
    
    private func updateUI() {
        // don't show follow button if you're looking up your own profile
        followButton.isHidden = currentUser.uid == selectedUser.uid ? true : false
        
        separatorView.snp.makeConstraints { make in
            let isCurrentUser = currentUser.uid == selectedUser.uid
            make.top.equalTo(isCurrentUser ? followerStatsLabel.snp.bottom : followButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
        
        ImageService.getImage(withURL: selectedUser.photoURL) { image in
            guard let image = image else { fatalError("User image was nil") }
            self.profilePhotoView.image = image
            Util.makeImageCircular(image: self.profilePhotoView, 100)
        }
        
        let selectedUserFollowersPath = String(format: Constants.Database.userFollowerInfo, selectedUser.uid)
        let selectedUserFollowersRef = Database.database().reference().child(selectedUserFollowersPath)
        
        FollowersService.getFollowerInfo(selectedUser.uid, selectedUserFollowersRef) { selectedUserFollowerInfo in
            print("UserProfileViewController selectedUser observable")
            self.followerCount = selectedUserFollowerInfo.followers.count
            self.followingCount = selectedUserFollowerInfo.following.count
            self.followerStatsLabel.text = "\(self.followerCount) follower\(self.followerCount != 1 ? "s" : "")\n\(self.followingCount) following"
            let currentUser = Follower(self.currentUser.uid)
            self.followButton.isSelected = selectedUserFollowerInfo.followers.contains(currentUser)
            self.followButton.isUserInteractionEnabled = true
            // TODO: Make use of the fact that the followers shit is an observable?
            selectedUserFollowersRef.removeAllObservers()
        }
    }
}

// MARK: Button functions
extension ProfileHeaderCollectionViewCell {
    @objc private func followButtonPressed(_ sender: Any) {
        print("BUTTON FUCKING pressed")
        // disable button while editing
        Util.toggleButton(button: self.followButton, isEnabled: false)
        guard let currentUser = UserService.currentUserProfile else { fatalError("current user nil??") }
        print("follow button disabled")
        let wasSelected = followButton.isSelected
        followButton.isSelected = !followButton.isSelected
        print("updating followers")
        FollowersService.updateFollowers(uid: currentUser.uid, followedUid: selectedUser.uid, addFollower: !wasSelected) {
            DispatchQueue.main.async {
                self.followerCount += wasSelected ? -1 : 1
                Util.toggleButton(button: self.followButton, isEnabled: true)
                self.followerStatsLabel.text = "\(self.followerCount) follower\(self.followerCount != 1 ? "s" : "")\n\(self.followingCount) following"
            }
        }
    }
}
