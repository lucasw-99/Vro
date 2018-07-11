//
//  EventCollectionViewCell.swift
//  Vro
//
//  Created by Lucas Wotton on 7/10/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

class EventCollectionViewCell: UICollectionViewCell {
    private let likeAuthorProfileImageView = UIImageView()
    private let likeAuthorUsernameLabel = UILabel()
    
    var like: Like! {
        didSet {
            updateUI()
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
extension EventCollectionViewCell {
    private func setupSubviews() {
        Util.makeImageCircular(image: likeAuthorProfileImageView, 50)
        contentView.addSubview(likeAuthorProfileImageView)
        
        likeAuthorUsernameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        likeAuthorUsernameLabel.textAlignment = .natural
        likeAuthorUsernameLabel.numberOfLines = 0
        contentView.addSubview(likeAuthorUsernameLabel)
    }
    
    private func setupLayout() {
        likeAuthorProfileImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        likeAuthorUsernameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalTo(likeAuthorProfileImageView.snp.trailing).offset(10)
        }
    }
    
    private func updateUI() {
        // TODO: Use timestamp?
        UserService.observeUserProfile(like.likeAuthorId) { userProfile in
            guard let userProfile = userProfile else { fatalError("user who made like was nil") }
            self.likeAuthorUsernameLabel.text = userProfile.username
            ImageService.getImage(withURL: userProfile.photoURL) { fromUserImage in
                guard let fromUserImage = fromUserImage else { fatalError("invalid photoUrl") }
                self.likeAuthorProfileImageView.image = fromUserImage
            }
        }
    }
}
