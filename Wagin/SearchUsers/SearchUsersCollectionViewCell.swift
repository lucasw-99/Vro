//
//  UserTableViewCell.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/11/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

class SearchUsersCollectionViewCell: UICollectionViewCell {
    private let usernameLabel = UILabel()
    private let userProfileImage = UIImageView()

    var user: UserProfile! {
        didSet {
            updateUI(user: user)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Setup subviews
extension SearchUsersCollectionViewCell {
    private func setupSubviews() {
        userProfileImage.clipsToBounds = true
        contentView.addSubview(userProfileImage)

        usernameLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        usernameLabel.textAlignment = .natural
        usernameLabel.numberOfLines = 0
        contentView.addSubview(usernameLabel)
    }

    private func setupLayout() {
        userProfileImage.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(50)
        }

        usernameLabel.snp.makeConstraints { make in
            make.leading.equalTo(userProfileImage.snp.trailing).offset(10)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

// MARK: Update cell
extension SearchUsersCollectionViewCell {
    func updateUI(user: UserProfile) {
        usernameLabel.text = user.username
        ImageService.getImage(withURL: user.photoURL) { image in
            self.userProfileImage.image = image
            self.userProfileImage.layer.cornerRadius = self.userProfileImage.frame.width / 2
        }
    }
}
