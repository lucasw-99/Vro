//
//  AutocompleteResultTableViewCell.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/7/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

class AutocompleteResultTableViewCell: UITableViewCell {
    private let titleLabel = UILabel()

    var title: String! {
        didSet {
            titleLabel.text = title
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupSubviews()
        setupLayout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func setupSubviews() {
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
    }

    private func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
