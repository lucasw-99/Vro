//
//  CommentCollectionViewCell.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/20/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

class CommentCollectionViewCell: UICollectionViewCell {
    private var userProfileImageView = UIImageView()
    private var usernameLabel = UILabel()
    private var commentLabel = UILabel()

    var comment: Comment! {
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
extension CommentCollectionViewCell {
    private func setupSubviews() {
        usernameLabel.textAlignment = .natural
        usernameLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)

        commentLabel.textAlignment = .natural
        commentLabel.font = UIFont.systemFont(ofSize: 16)
    }

    private func setupLayout() {
        usernameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        commentLabel.snp.makeConstraints { make in
            make.leading.equalTo(usernameLabel.snp.trailing).offset(10)
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    private func updateUI() {
        usernameLabel.text = comment.authorUsername

        commentLabel.text = comment.comment
    }
}
