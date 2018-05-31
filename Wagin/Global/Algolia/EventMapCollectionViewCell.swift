//
//  EventMapCollectionViewCell.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/30/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import SnapKit

class EventMapCollectionViewCell: UICollectionViewCell {
    private let eventPostIdLabel = UILabel()

    var eventPostId: String! {
        didSet {
            eventPostIdLabel.text = eventPostId
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
extension EventMapCollectionViewCell {
    private func setupSubviews() {
        eventPostIdLabel.textAlignment = .natural
        eventPostIdLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        eventPostIdLabel.numberOfLines = 0

        contentView.addSubview(eventPostIdLabel)
    }

    private func setupLayout() {
        eventPostIdLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
