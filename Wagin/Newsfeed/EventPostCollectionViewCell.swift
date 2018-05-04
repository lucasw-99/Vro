//
//  EventPostCollectionViewCell.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/4/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

class EventPostCollectionViewCell: UICollectionViewCell {
    private let eventImageView = UIImageView()

    private let likeButton = UIButton()
    private let commentButton = UIButton()

    private let separatorView = UIView()

    private let numberOfLikes = UILabel()

    private let captionLabel = UILabel()

    private let containerView = UIView()

    var eventPost: EventPost! {
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

    private func setupSubviews() {
        eventImageView.contentMode = .scaleAspectFill
        containerView.addSubview(eventImageView)

        likeButton.setImage(#imageLiteral(resourceName: "following"), for: .normal)
        containerView.addSubview(likeButton)

        commentButton.setImage(#imageLiteral(resourceName: "speech_buble"), for: .normal)
        containerView.addSubview(commentButton)

        separatorView.backgroundColor = .gray
        containerView.addSubview(separatorView)

        numberOfLikes.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        numberOfLikes.numberOfLines = 1
        containerView.addSubview(numberOfLikes)

        captionLabel.font = UIFont.systemFont(ofSize: 20)
        captionLabel.textAlignment = .left
        captionLabel.numberOfLines = 3
        containerView.addSubview(captionLabel)

        containerView.backgroundColor = .white
        contentView.addSubview(containerView)
    }

    private func setupLayout() {
        eventImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(300)
            make.width.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
        }

        likeButton.snp.makeConstraints { make in
            make.top.equalTo(eventImageView.snp.bottom).offset(7)
            make.leading.equalToSuperview().offset(8)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }

        commentButton.snp.makeConstraints { make in
            make.top.equalTo(eventImageView.snp.bottom).offset(7)
            make.leading.equalTo(likeButton.snp.trailing).offset(15)
            make.width.equalTo(30)
            make.height.equalTo(30)
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

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func updateUI() {
        eventImageView.image = eventPost.eventImage

        numberOfLikes.text = "💗 \(eventPost.likedBy.count) likes"

        captionLabel.text = eventPost.caption
    }
}
