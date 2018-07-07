//
//  NotificationCollectionViewCell.swift
//  Vro
//
//  Created by Lucas Wotton on 7/6/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

class NotificationCollectionViewCell: UICollectionViewCell {
    private let fromUserImageView = UIImageView()
    private let fromUserLabel = UILabel()
    
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
        Util.makeImageCircular(image: fromUserImageView, 50)
        contentView.addSubview(fromUserImageView)
        
        fromUserLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        fromUserLabel.textAlignment = .natural
        fromUserLabel.numberOfLines = 0
        contentView.addSubview(fromUserLabel)
    }
    
    private func setupLayout() {
        fromUserImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
        
        fromUserLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.leading.equalTo(fromUserImageView.snp.trailing).offset(10)
        }
    }
    
    private func updateUI() {
        guard let timestamp = notification.timestamp else { fatalError("timestamp nil in notification") }
        let dateStr = Util.smallestTimeUnit(from: timestamp)
        let attribute = [NSAttributedStringKey.foregroundColor: UIColor.gray,
                         NSAttributedStringKey.font: UIFont(name: "GillSans", size: 12)
                        ]
    
        switch notification.type {
        case .Like:
            guard let like = notification as? LikeNotification else { fatalError("Mismatched types for like") }
            getUser(withUid: like.userUid) { username in
                let likeText = "\(username) liked your event  "
                let dateRange = NSRange(location: likeText.count, length: dateStr.count)
                let attrString = NSMutableAttributedString(string: "\(likeText)\(dateStr)")
                attrString.addAttributes(attribute, range: dateRange)
                self.fromUserLabel.attributedText = attrString
            }
        case .Comment:
            guard let comment = notification as? CommentNotification else { fatalError("Mismatched types for comment") }
            getUser(withUid: comment.userUid) { username in
                let commentText = "\(username) commented on your post  "
                let dateRange = NSRange(location: commentText.count, length: dateStr.count)
                let attrString = NSMutableAttributedString(string: "\(commentText)\(dateStr)")
                attrString.addAttributes(attribute, range: dateRange)
                self.fromUserLabel.attributedText = attrString
            }
        case .Follower:
            guard let follower = notification as? FollowerNotification else { fatalError("Mismatched types for follower") }
            getUser(withUid: follower.followerUid) { username in
                let followerText = "\(username) followed you  "
                let dateRange = NSRange(location: followerText.count, length: dateStr.count)
                let attrString = NSMutableAttributedString(string: "\(followerText)\(dateStr)")
                attrString.addAttributes(attribute, range: dateRange)
                self.fromUserLabel.attributedText = attrString
            }
        case .Attendee:
            guard let attendee = notification as? AttendeeNotification else { fatalError("Mismatched types for attendee") }
            getUser(withUid: attendee.userUid) { username in
                let attendeeText = "\(username) is attending your event  "
                let dateRange = NSRange(location: attendeeText.count, length: dateStr.count)
                let attrString = NSMutableAttributedString(string: "\(attendeeText)\(dateStr)")
                attrString.addAttributes(attribute, range: dateRange)
                self.fromUserLabel.attributedText = attrString
            }
        }
    }
    
    private func getUser(withUid uid: String, completion: @escaping ( (_ username: String) -> () )) {
        UserService.observeUserProfile(uid) { userProfile in
            guard let userProfile = userProfile else { fatalError("user who made notification was nil") }
            
            ImageService.getImage(withURL: userProfile.photoURL) { fromUserImage in
                guard let fromUserImage = fromUserImage else { fatalError("invalid photoUrl") }
                self.fromUserImageView.image = fromUserImage
            }
            completion(userProfile.username)
        }
    }
}
