//
//  CommentCollectionViewCell.swift
//  Vro
//
//  Created by Lucas Wotton on 5/20/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

class CommentCollectionViewCell: UICollectionViewCell {
    private let userProfileImageView = UIImageView()
    private let usernameLabel = UILabel()
    private let commentLabel = UILabel()
    private let containerView = UIView()

    var comment: Comment! {
        didSet {
            updateCommentUI()
        }
    }

    var commentAuthor: UserProfile! {
        didSet {
            updateUserUI()
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
extension CommentCollectionViewCell {
    private func setupSubviews() {
        usernameLabel.textAlignment = .natural
        usernameLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        usernameLabel.numberOfLines = 0
        containerView.addSubview(usernameLabel)

        commentLabel.textAlignment = .natural
        commentLabel.font = UIFont.systemFont(ofSize: 16)
        commentLabel.numberOfLines = 0
        containerView.addSubview(commentLabel)

        contentView.addSubview(containerView)
    }

    private func setupLayout() {
        usernameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }

        commentLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalTo(usernameLabel.snp.bottom)
            make.bottom.equalToSuperview()
        }

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func updateCommentUI() {
        commentLabel.text = comment.commentText
    }

    private func updateUserUI() {
        usernameLabel.text = commentAuthor.username
    }
}
