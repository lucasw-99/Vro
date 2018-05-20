//
//  EventPostCollectionViewCell.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/4/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Foundation

protocol EventPostCellDelegate {
    func didTapLikeButton(likeButton: UIButton, forCell cell: EventPostCollectionViewCell)
    func didTapCommentButton(_ postedByUID: String, eventPostID: String)
    func didTapShareButton(_ postedByUID: String, eventPostID: String)
    func didTapShowCommentsButton(showCommentsButton: UIButton, forEvent event: EventPost)
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
    private let showCommentsButton = UIButton()
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
    @objc private func likeButtonPressed(_ sender: UIButton) {
        print("Like button pressed")
        buttonDelegate?.didTapLikeButton(likeButton: likeButton, forCell: self)
    }

    @objc private func commentButtonPressed(_ sender: Any) {
        print("Comment button pressed")
        buttonDelegate?.didTapCommentButton(eventPost.postedByUser.uid, eventPostID: eventPost.eventPostID)
    }

    @objc private func shareButtonPressed(_ sender: Any) {
        print("Share button pressed")
        buttonDelegate?.didTapShareButton(eventPost.postedByUser.uid, eventPostID: eventPost.eventPostID)
    }

    @objc private func showCommentsButtonPressed(_ sender: UIButton) {
        print("Show comments button pressed")
        buttonDelegate?.didTapShowCommentsButton(showCommentsButton: sender, forEvent: eventPost)
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

        let heartImage: UIImage = #imageLiteral(resourceName: "heart")
        likeButton.setImage(heartImage, for: .normal)
        likeButton.setImage(heartImage.maskWithColor(color: .red), for: .selected)
        likeButton.addTarget(self, action: #selector(EventPostCollectionViewCell.likeButtonPressed(_:)), for: .touchUpInside)
        containerView.addSubview(likeButton)

        let commentImage: UIImage = #imageLiteral(resourceName: "speech_buble")
        commentButton.setImage(commentImage, for: .normal)
        commentButton.setImage(commentImage.maskWithColor(color: .white), for: .selected)
        commentButton.addTarget(self, action: #selector(EventPostCollectionViewCell.commentButtonPressed(_:)), for: .touchUpInside)
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

        showCommentsButton.setTitle("Show comments", for: .normal)
        showCommentsButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        showCommentsButton.setTitleColor(.blue, for: .normal)
        showCommentsButton.setTitleColor(.black, for: .selected)
        showCommentsButton.titleLabel?.textAlignment = .natural
        showCommentsButton.addTarget(self, action: #selector(EventPostCollectionViewCell.showCommentsButtonPressed(_:)), for: .touchUpInside)
        containerView.addSubview(showCommentsButton)

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
            make.height.equalTo(40)
        }

        showCommentsButton.snp.makeConstraints { make in
            make.top.equalTo(captionLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(200)
            make.height.equalTo(40)
        }

        daysAgo.snp.makeConstraints { make in
            make.top.equalTo(showCommentsButton.snp.bottom)
            make.leading.equalToSuperview().offset(12)
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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

        captionLabel.text = eventPost.caption

        numLikes = eventPost.likeCount

        setIsLiked(isLiked: eventPost.isLiked)

        daysAgo.text = Util.smallestTimeUnit(from: eventPost.timestamp)
    }

    private func setLikes(numLikes: Int) {
        likeButton.isUserInteractionEnabled = false
        numberOfLikes.text = "💗 \(numLikes) like\(numLikes != 1 ? "s" : "")"
        likeButton.isUserInteractionEnabled = true
    }

    private func setIsLiked(isLiked: Bool) {
        likeButton.isSelected = isLiked
    }
}
