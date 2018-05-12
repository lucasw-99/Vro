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
    private let descriptionLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
        setupLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func updateCell(titleText: NSAttributedString, descriptionText: String) {
        titleLabel.attributedText = titleText
        descriptionLabel.text = descriptionText
    }

    private func setupSubviews() {
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.textAlignment = .natural
        titleLabel.textColor = .black
        contentView.addSubview(titleLabel)

        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textAlignment = .natural
        descriptionLabel.textColor = .black
        contentView.addSubview(descriptionLabel)
    }

    private func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
