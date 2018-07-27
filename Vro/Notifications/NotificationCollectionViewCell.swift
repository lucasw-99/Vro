//
//  NotificationCollectionViewCell.swift
//  Vro
//
//  Created by Lucas Wotton on 7/6/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

protocol NotificationCellDelegate {
    func didTapUserButton(_ userImageButton: UIButton, _ usernameButton: UIButton, user: UserProfile)
}

class NotificationCollectionViewCell: UICollectionViewCell {
    private let fromUserImageButton = UIButton()
    private let usernameButton = UIButton()
    
    var buttonDelegate: NotificationCellDelegate?
    var fromUser: UserProfile?
    
    var notification: Notification! {
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
extension NotificationCollectionViewCell {
    private func setupSubviews() {
        fromUserImageButton.addTarget(self, action: #selector(NotificationCollectionViewCell.usernameButtonPressed(_:)), for: .touchUpInside)
        Util.makeImageCircular(image: fromUserImageButton.imageView!, 50)
        contentView.addSubview(fromUserImageButton)
        
        usernameButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        usernameButton.titleLabel?.textAlignment = .natural
        usernameButton.titleLabel?.numberOfLines = 0
        usernameButton.titleLabel?.lineBreakMode = .byWordWrapping
        usernameButton.addTarget(self, action: #selector(NotificationCollectionViewCell.usernameButtonPressed(_:)), for: .touchUpInside)
        usernameButton.isUserInteractionEnabled = true
        
        contentView.addSubview(usernameButton)
    }
    
    private func setupLayout() {
        fromUserImageButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        usernameButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalTo(fromUserImageButton.snp.trailing).offset(10)
            make.trailing.lessThanOrEqualToSuperview()
        }
    }
    
    private func updateUI() {
        guard let timestamp = notification.timestamp else { fatalError("timestamp nil in notification") }
        let dateStr = Util.smallestTimeUnit(from: timestamp)
        let attribute = [NSAttributedStringKey.foregroundColor: UIColor.gray,
                         NSAttributedStringKey.font: UIFont(name: "GillSans", size: 12) as Any
                        ] as [NSAttributedStringKey: Any]
    
        switch notification.type {
        case .Like:
            guard let like = notification as? LikeNotification else { fatalError("Mismatched types for like") }
            getUser(withUid: like.userUid) { username in
                let likeText = "\(username) liked your event  "
                let dateRange = NSRange(location: likeText.count, length: dateStr.count)
                let attrString = NSMutableAttributedString(string: "\(likeText)\(dateStr)")
                attrString.addAttributes(attribute, range: dateRange)
                self.usernameButton.setAttributedTitle(attrString, for: .normal)
            }
        case .Comment:
            guard let comment = notification as? CommentNotification else { fatalError("Mismatched types for comment") }
            getUser(withUid: comment.userUid) { username in
                let commentText = "\(username) commented on your post  "
                let dateRange = NSRange(location: commentText.count, length: dateStr.count)
                let attrString = NSMutableAttributedString(string: "\(commentText)\(dateStr)")
                attrString.addAttributes(attribute, range: dateRange)
                self.usernameButton.setAttributedTitle(attrString, for: .normal)
            }
        case .Follower:
            guard let follower = notification as? FollowerNotification else { fatalError("Mismatched types for follower") }
            getUser(withUid: follower.followerUid) { username in
                let followerText = "\(username) followed you  "
                let dateRange = NSRange(location: followerText.count, length: dateStr.count)
                let attrString = NSMutableAttributedString(string: "\(followerText)\(dateStr)")
                attrString.addAttributes(attribute, range: dateRange)
                self.usernameButton.setAttributedTitle(attrString, for: .normal)
            }
        case .Attendee:
            guard let attendee = notification as? AttendeeNotification else { fatalError("Mismatched types for attendee") }
            getUser(withUid: attendee.userUid) { username in
                let attendeeText = "\(username) is attending your event  "
                let dateRange = NSRange(location: attendeeText.count, length: dateStr.count)
                let attrString = NSMutableAttributedString(string: "\(attendeeText)\(dateStr)")
                attrString.addAttributes(attribute, range: dateRange)
                self.usernameButton.setAttributedTitle(attrString, for: .normal)
            }
        }
    }
    
    private func getUser(withUid uid: String, completion: @escaping ( (_ username: String) -> () )) {
        UserService.observeUserProfile(uid) { userProfile in
            guard let userProfile = userProfile else { fatalError("user who made notification was nil") }
            self.fromUser = userProfile
            ImageService.getImage(withURL: userProfile.photoURL) { fromUserImage in
                guard let fromUserImage = fromUserImage else { fatalError("invalid photoUrl") }
                self.fromUserImageButton.setImage(fromUserImage, for: .normal)
            }
            completion(userProfile.username)
        }
    }
}

// MARK: Button functions
extension NotificationCollectionViewCell {
    @objc private func usernameButtonPressed(_ sender: UIButton) {
        print("username pressed")
        if let fromUser = fromUser {
            buttonDelegate?.didTapUserButton(fromUserImageButton, usernameButton, user: fromUser)
        }
    }
}
