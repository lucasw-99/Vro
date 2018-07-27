//
//  EventPostCollectionViewCell.swift
//  Vro
//
//  Created by Lucas Wotton on 5/4/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Foundation

protocol EventPostCellDelegate {
    func didTapUsernameButton(_ usernameButton: UIButton, forUser user: UserProfile)
    func didTapAttendButton(_ attendButton: UIButton, forCell cell: EventPostCollectionViewCell)
    func didTapLikeButton(_ likeButton: UIButton, forCell cell: EventPostCollectionViewCell)
    func didTapCommentButton(_ commentButton: UIButton, forEvent event: EventPost)
    func didTapShareButton(_ shareButton: UIButton, forEvent event: Event)
    func didTapShowCommentsButton(showCommentsButton: UIButton, forEvent event: EventPost)
    func didTapNumLikesButton(numLikesButton: UIButton, forEvent event: EventPost)
    func didTapNumGuestsButton(numGuestsButton: UIButton, forEvent event: EventPost)
}

class EventPostCollectionViewCell: UICollectionViewCell {
    private let userHeaderView = UIView()
    private let userImage = UIImageView()
    private let usernameButton = UIButton()
    private let attendButton = UIButton()

    private let eventImageView = UIImageView()

    private let likeButton = UIButton()
    private let commentButton = UIButton()
    private let shareButton = UIButton()

    private let separatorView = UIView()
    private let numberOfLikesButton = UIButton()
    private let numberOfGuestsButton = UIButton()
    private let captionLabel = UILabel()
    private let showCommentsButton = UIButton()
    private let eventTimeLabel = UILabel()
    private let daysAgo = UILabel()

    private let containerView = UIView()

    var buttonDelegate: EventPostCellDelegate?
    private var eventPostLikesRef: DatabaseReference?

    var eventPost: EventPost! {
        didSet {
            updateUI()
        }
    }

    var numLikes: Int = 0 {
        didSet {
            setLikes(numLikes: numLikes)
        }
    }

    var numAttending: Int = 0 {
        didSet {
            setAttending(numAttending: numAttending)
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

// MARK: Button functions
extension EventPostCollectionViewCell {
    @objc private func usernamePressed(_ sender: UIButton) {
        buttonDelegate?.didTapUsernameButton(usernameButton, forUser: eventPost.event.host)
    }
    
    @objc private func attendButtonPressed(_ sender: UIButton) {
        buttonDelegate?.didTapAttendButton(attendButton, forCell: self)
    }

    @objc private func likeButtonPressed(_ sender: UIButton) {
        buttonDelegate?.didTapLikeButton(likeButton, forCell: self)
    }

    @objc private func commentButtonPressed(_ sender: UIButton) {
        buttonDelegate?.didTapCommentButton(commentButton, forEvent: eventPost)
    }

    @objc private func shareButtonPressed(_ sender: UIButton) {
        buttonDelegate?.didTapShareButton(shareButton, forEvent: eventPost.event)
    }

    @objc private func showCommentsButtonPressed(_ sender: UIButton) {
        buttonDelegate?.didTapShowCommentsButton(showCommentsButton: sender, forEvent: eventPost)
    }
    
    @objc private func showNumLikes(_ sender: UIButton) {
        buttonDelegate?.didTapNumLikesButton(numLikesButton: sender, forEvent: eventPost)
    }
    
    @objc private func showNumGuests(_ sender: UIButton) {
        buttonDelegate?.didTapNumGuestsButton(numGuestsButton: sender, forEvent: eventPost)
    }
}

// MARK: Setup subviews
extension EventPostCollectionViewCell {
    private func setupSubviews() {
        userImage.image = #imageLiteral(resourceName: "user")
        Util.makeImageCircular(image: userImage, 36)
        userHeaderView.addSubview(userImage)

        usernameButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        usernameButton.titleLabel?.textAlignment = .natural
        usernameButton.setTitleColor(.black, for: .normal)
        usernameButton.addTarget(self, action: #selector(EventPostCollectionViewCell.usernamePressed(_:)), for: .touchUpInside)
        userHeaderView.addSubview(usernameButton)

        attendButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        attendButton.titleLabel?.textAlignment = .natural
        attendButton.setTitle("Go", for: .normal)
        attendButton.setTitleColor(.black, for: .normal)
        attendButton.setTitle("Going", for: .selected)
        attendButton.setTitleColor(.gray, for: .selected)
        attendButton.addTarget(self, action: #selector(EventPostCollectionViewCell.attendButtonPressed(_:)), for: .touchUpInside)
        Util.roundedCorners(ofColor: .black, element: attendButton)
        userHeaderView.addSubview(attendButton)

        containerView.addSubview(userHeaderView)

        eventImageView.contentMode = .scaleToFill
        containerView.addSubview(eventImageView)

        let heartImage: UIImage = #imageLiteral(resourceName: "heart")
        likeButton.setImage(heartImage, for: .normal)
        likeButton.setImage(heartImage.maskWithColor(color: .red), for: .selected)
        likeButton.addTarget(self, action: #selector(EventPostCollectionViewCell.likeButtonPressed(_:)), for: .touchUpInside)
        containerView.addSubview(likeButton)

        let commentImage: UIImage = #imageLiteral(resourceName: "comment")
        commentButton.setImage(commentImage, for: .normal)
        commentButton.setImage(commentImage.maskWithColor(color: .white), for: .selected)
        commentButton.addTarget(self, action: #selector(EventPostCollectionViewCell.commentButtonPressed(_:)), for: .touchUpInside)
        containerView.addSubview(commentButton)

        shareButton.setImage(#imageLiteral(resourceName: "seeDetails"), for: .normal)
        shareButton.addTarget(self, action: #selector(EventPostCollectionViewCell.shareButtonPressed(_:)), for: .touchUpInside)
        containerView.addSubview(shareButton)

        separatorView.backgroundColor = .gray
        containerView.addSubview(separatorView)

        numberOfLikesButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        numberOfLikesButton.titleLabel?.numberOfLines = 1
        numberOfLikesButton.setTitleColor(.black, for: .normal)
        numberOfLikesButton.addTarget(self, action: #selector(EventPostCollectionViewCell.showNumLikes(_:)), for: .touchUpInside)
        containerView.addSubview(numberOfLikesButton)

        numberOfGuestsButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        numberOfGuestsButton.titleLabel?.numberOfLines = 1
        numberOfGuestsButton.setTitleColor(.black, for: .normal)
        numberOfGuestsButton.addTarget(self, action: #selector(EventPostCollectionViewCell.showNumGuests(_:)), for: .touchUpInside)
        containerView.addSubview(numberOfGuestsButton)

        captionLabel.font = UIFont.systemFont(ofSize: 20)
        captionLabel.textAlignment = .left
        captionLabel.numberOfLines = 3
        captionLabel.isHidden = true
        containerView.addSubview(captionLabel)

        showCommentsButton.setTitle("Show comments...", for: .normal)
        showCommentsButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        showCommentsButton.setTitleColor(.blue, for: .normal)
        showCommentsButton.setTitleColor(.black, for: .selected)
        showCommentsButton.titleLabel?.textAlignment = .natural
        showCommentsButton.addTarget(self, action: #selector(EventPostCollectionViewCell.showCommentsButtonPressed(_:)), for: .touchUpInside)
        containerView.addSubview(showCommentsButton)

        eventTimeLabel.font = UIFont.systemFont(ofSize: 12)
        eventTimeLabel.textAlignment = .natural
        eventTimeLabel.textColor = .darkGray
        eventTimeLabel.numberOfLines = 1
        containerView.addSubview(eventTimeLabel)

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
            make.leading.equalToSuperview()
            make.width.equalTo(36)
            make.height.equalTo(36)
            make.centerY.equalToSuperview()
        }

        usernameButton.snp.makeConstraints { make in
            make.leading.equalTo(userImage.snp.trailing).offset(10)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        attendButton.snp.makeConstraints { make in
            make.width.equalTo(70)
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
        }

        userHeaderView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(57)
        }

        eventImageView.snp.makeConstraints { make in
            make.top.equalTo(userHeaderView.snp.bottom)
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
            make.leading.equalTo(likeButton.snp.trailing).offset(20)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }

        shareButton.snp.makeConstraints { make in
            make.centerY.equalTo(likeButton.snp.centerY)
            make.leading.equalTo(commentButton.snp.trailing).offset(20)
            make.height.equalTo(30)
            make.width.equalTo(30)
        }

        separatorView.snp.makeConstraints { make in
            make.top.equalTo(likeButton.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(containerView.snp.width).multipliedBy(0.97)
            make.height.equalTo(1)
        }

        numberOfLikesButton.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(12)
            make.height.equalTo(30)
        }

        numberOfGuestsButton.snp.makeConstraints { make in
            make.top.equalTo(numberOfLikesButton.snp.bottom)
            make.leading.equalToSuperview().offset(12)
            make.height.equalTo(30)
        }

        captionLabel.snp.makeConstraints { make in
            make.top.equalTo(numberOfGuestsButton.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview()
        }

        showCommentsButton.snp.makeConstraints { make in
            make.top.equalTo(captionLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(12)
            make.height.equalTo(40)
        }

        eventTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(showCommentsButton.snp.bottom)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview()
        }

        daysAgo.snp.makeConstraints { make in
            make.top.equalTo(eventTimeLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(12)
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func updateUI() {
        guard let currentUid = UserService.currentUserProfile?.uid else { fatalError("current user nil") }

        usernameButton.setTitle(eventPost.event.host.username, for: .normal)

        ImageService.getImage(withURL: eventPost.event.host.photoURL, completion: { image in
            self.userImage.image = image
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
        if !eventPost.caption.isEmpty {
            captionLabel.text = eventPost.caption
            captionLabel.isHidden = false
        }

        numLikes = eventPost.likeCount

        likeButton.isSelected = eventPost.isLiked

        numAttending = eventPost.event.attendeeCount

        attendButton.isSelected = eventPost.isAttending
        attendButton.isHidden = currentUid == eventPost.event.host.uid

        eventTimeLabel.text = "Event happening in \(Util.smallestTimeUnit(from: eventPost.event.eventTime))"

        daysAgo.text = "Posted \(Util.smallestTimeUnit(from: eventPost.timestamp))"
    }

    private func setLikes(numLikes: Int) {
        likeButton.isUserInteractionEnabled = false
        let numLikesText = "💗 \(numLikes) like\(numLikes != 1 ? "s" : "")"
        numberOfLikesButton.setTitle(numLikesText, for: .normal)
        likeButton.isUserInteractionEnabled = true
    }

    private func setAttending(numAttending: Int) {
        attendButton.isUserInteractionEnabled = false
        let numGuestsText = "💃🏽 \(numAttending) \(numAttending != 1 ? "people" : "person") going"
        numberOfGuestsButton.setTitle(numGuestsText, for: .normal)
        attendButton.isUserInteractionEnabled = true
    }
}
