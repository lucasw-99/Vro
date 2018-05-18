//
//  EventPostCollectionViewCell.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/4/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol EventPostCellDelegate {
    func didTapCommentButton(_ postedByUID: String, eventPostID: String)
    func didTapShareButton(_ postedByUID: String, eventPostID: String)
}

class EventPostCollectionViewCell: UICollectionViewCell {
    private let userHeaderView = UIView()
    private let userImage = UIImageView()
    private let usernameLabel = UILabel()

    private let eventImageView = UIImageView()

    private let likeButton = UIButton()
    private let commentButton = UIButton()
    private let shareButton = UIButton()

    private let separatorView = UIView()

    private let numberOfLikes = UILabel()

    private let captionLabel = UILabel()

    private let daysAgo = UILabel()

    private let containerView = UIView()

    var buttonDelegate: EventPostCellDelegate?
    private var eventPostLikesRef: DatabaseReference?
    private var userLikes: Set<String>

    var eventPost: EventPost! {
        didSet {
            updateUI()
        }
    }

    override init(frame: CGRect) {
        self.userLikes = Set<String>()
        super.init(frame: frame)
        setupSubviews()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateUI() {
        usernameLabel.text = eventPost.postedByUser.username

        print("photoURL: \(eventPost.postedByUser.photoURL), caption: \(eventPost.caption)")
        ImageService.getImage(withURL: eventPost.postedByUser.photoURL, completion: { image in
            self.userImage.image = image
            Util.makeImageCircular(image: self.userImage)
        })
        userImage.layer.borderWidth = 1
        userImage.layer.borderColor = UIColor.lightGray.cgColor

        if let url = URL(string: eventPost.event.eventImageURL) {
            ImageService.getImage(withURL: url) { image in
                self.eventImageView.image = image
            }
        } else {
            ImageService.getImage(withURL: URL(string: Constants.noImageProvidedPhotoURL)!) { image in
                self.eventImageView.image = image
            }
            print("Invalid image URL")
        }

        // start like count at zero, because user likes is empty
        updateNumberOfLikes(numLikes: userLikes.count)
        // disable user interaction until button has updated number
        likeButton.isUserInteractionEnabled = false
        // TODO: Rework logic, possibly do this in the collection view so you don't make
        // a ton of observables
        LikeService.getLikesForPost(eventPost.postedByUser.uid, eventPost.eventPostID) { userLikes, likesRef in
            self.eventPostLikesRef = likesRef
            self.updateNumberOfLikes(numLikes: userLikes.keys.count)
            self.userLikes = Set<String>(userLikes.keys)
            self.likeButton.isUserInteractionEnabled = true
        }

        captionLabel.text = eventPost.caption

        daysAgo.text = smallestTimeUnit(from: eventPost.timestamp)
    }

    private func updateNumberOfLikes(numLikes: Int) {
        numberOfLikes.text = "💗 \(numLikes) like\(numLikes != 1 ? "s" : "")"
    }

    private func smallestTimeUnit(from date: Date) -> String {
        let todaysDate = Date()
        var n = todaysDate.years(from: date)
        guard n >= 0 else { fatalError("Date posted is later than todays date: \(date)") }
        if n != 0 {
            return "\(n) year\(n != 1 ? "s" : "") ago"
        }
        n = todaysDate.months(from: date)
        if n != 0 {
            return "\(n) month\(n != 1 ? "s" : "") ago"
        }
        n = todaysDate.days(from: date)
        if n != 0 {
            return "\(n) day\(n != 1 ? "s" : "") ago"
        }
        n = todaysDate.hours(from: date)
        if n != 0 {
            return "\(n) hour\(n != 1 ? "s" : "") ago"
        }
        n = todaysDate.minutes(from: date)
        if n != 0 {
            return "\(n) minute\(n != 1 ? "s" : "") ago"
        }
        return "less than a minute ago"
    }
}

// MARK: Button functions
extension EventPostCollectionViewCell {
    @objc private func likeButtonPressed(_ sender: Any) {
        print("Like button pressed")
        guard let currentUID = UserService.currentUserProfile?.uid else { fatalError("Current user nil") }
        let likedPost = !userLikes.contains(currentUID)
        let currentNumLikes = userLikes.count
        // TODO: Make sure userLikes gets updated properly
        let numLikes = likedPost ? currentNumLikes + 1 : currentNumLikes - 1
        updateNumberOfLikes(numLikes: numLikes)
        // TODO: Add this to delegate? Why?
        // TODO: Verify this triggers other observable to fire
        LikeService.updateLikesForPost(currentUID, eventPost.postedByUser.uid, eventPostID: eventPost.eventPostID, likedPost: likedPost)
    }

    @objc private func commentButtonPressed(_ sender: Any) {
        print("Comment button pressed")
        buttonDelegate?.didTapCommentButton(eventPost.postedByUser.uid, eventPostID: eventPost.eventPostID)
    }

    @objc private func shareButtonPressed(_ sender: Any) {
        print("Share button pressed")
        buttonDelegate?.didTapShareButton(eventPost.postedByUser.uid, eventPostID: eventPost.eventPostID)
    }
}

// MARK: Setup subviews
extension EventPostCollectionViewCell {
    private func setupSubviews() {
        userImage.image = #imageLiteral(resourceName: "user_group_man_woman")
        userHeaderView.addSubview(userImage)

        usernameLabel.text = "User"
        usernameLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        usernameLabel.textAlignment = .natural
        usernameLabel.numberOfLines = 1
        userHeaderView.addSubview(usernameLabel)

        containerView.addSubview(userHeaderView)

        eventImageView.contentMode = .scaleToFill
        containerView.addSubview(eventImageView)

        likeButton.setImage(#imageLiteral(resourceName: "following"), for: .normal)
        likeButton.addTarget(self, action: #selector(EventPostCollectionViewCell.likeButtonPressed(_:)), for: .touchUpInside)
        containerView.addSubview(likeButton)

        commentButton.setImage(#imageLiteral(resourceName: "speech_buble"), for: .normal)
        containerView.addSubview(commentButton)

        shareButton.setImage(#imageLiteral(resourceName: "contact_card"), for: .normal)
        containerView.addSubview(shareButton)

        separatorView.backgroundColor = .gray
        containerView.addSubview(separatorView)

        numberOfLikes.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        numberOfLikes.numberOfLines = 1
        containerView.addSubview(numberOfLikes)

        captionLabel.font = UIFont.systemFont(ofSize: 20)
        captionLabel.textAlignment = .left
        captionLabel.numberOfLines = 3
        containerView.addSubview(captionLabel)

        daysAgo.font = UIFont.systemFont(ofSize: 12)
        daysAgo.textAlignment = .natural
        daysAgo.textColor = .darkGray
        daysAgo.numberOfLines = 1
        containerView.addSubview(daysAgo)

        containerView.backgroundColor = .white
        contentView.addSubview(containerView)
    }

    private func setupLayout() {
        userImage.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.width.equalTo(36)
            make.height.equalTo(36)
            make.centerY.equalToSuperview()
        }

        usernameLabel.snp.makeConstraints { make in
            make.leading.equalTo(userImage.snp.trailing).offset(15)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        userHeaderView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(57)
        }

        eventImageView.snp.makeConstraints { make in
            make.top.equalTo(userHeaderView.snp.bottom).offset(10)
            make.height.equalTo(300)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        likeButton.snp.makeConstraints { make in
            make.top.equalTo(eventImageView.snp.bottom).offset(17)
            make.leading.equalToSuperview().offset(8)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }

        commentButton.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton.snp.centerY)
            make.leading.equalTo(likeButton.snp.trailing).offset(15)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }

        shareButton.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton.snp.centerY)
            make.leading.equalTo(commentButton.snp.trailing).offset(15)
            make.height.equalTo(30)
            make.width.equalTo(30)
        }

        separatorView.snp.makeConstraints { make in
            make.top.equalTo(likeButton.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(containerView.snp.width).multipliedBy(0.97)
            make.height.equalTo(1)
        }

        numberOfLikes.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview()
            make.height.equalTo(50)
        }

        captionLabel.snp.makeConstraints { make in
            make.top.equalTo(numberOfLikes.snp.bottom)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview()
            make.height.equalTo(20)
        }

        daysAgo.snp.makeConstraints { make in
            make.top.equalTo(captionLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(12)
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
