//
//  UserProfileViewController.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/12/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

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

        let followerCount = selectedUser.following.count
        let followingCount = selectedUser.followers.count
        followerStatsLabel.text = "\(followerCount) follower\(followerCount != 1 ? "s" : "")\n\(followingCount) following"
        followerStatsLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        followerStatsLabel.numberOfLines = 0
        followerStatsLabel.textAlignment = .center
        view.addSubview(followerStatsLabel)

        followButton.setTitle("Follow", for: .normal)
        followButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        followButton.setTitleColor(.black, for: .normal)
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
}

// MARK: Button functions
extension UserProfileViewController {
    @objc private func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
