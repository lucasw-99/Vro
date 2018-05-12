//
//  UserTableViewCell.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/11/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

class SearchUsersTableViewCell: UITableViewCell {
    private let usernameLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Setup subviews
extension SearchUsersTableViewCell {
    private func setupSubviews() {
        contentView.addSubview(usernameLabel)
    }

    private func setupLayout() {
        usernameLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: Update cell
extension SearchUsersTableViewCell {
    func updateCell(username: String) {
        usernameLabel.text = username
    }
}
