//
//  GuestCollectionViewCell.swift
//  Vro
//
//  Created by Lucas Wotton on 7/9/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

class GuestCollectionViewCell: UICollectionViewCell {
    private let guestProfileImageView = UIImageView()
    private let guestUsernameLabel = UILabel()
    
    var guest: Attendee! {
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
extension GuestCollectionViewCell {
    private func setupSubviews() {
        Util.makeImageCircular(image: guestProfileImageView, 50)
        contentView.addSubview(guestProfileImageView)
        
        guestUsernameLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        guestUsernameLabel.textAlignment = .natural
        guestUsernameLabel.numberOfLines = 0
        contentView.addSubview(guestUsernameLabel)
    }
    
    private func setupLayout() {
        guestProfileImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        guestUsernameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalTo(guestProfileImageView.snp.trailing).offset(10)
        }
    }
    
    private func updateUI() {
        // TODO: Use timestamp?
        UserService.observeUserProfile(guest.attendeeId) { userProfile in
            guard let userProfile = userProfile else { fatalError("user who made like was nil") }
            self.guestUsernameLabel.text = userProfile.username
            ImageService.getImage(withURL: userProfile.photoURL) { fromUserImage in
                guard let fromUserImage = fromUserImage else { fatalError("invalid photoUrl") }
                self.guestProfileImageView.image = fromUserImage
            }
        }
    }
}
