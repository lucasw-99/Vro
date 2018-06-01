//
//  EventViewController.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/31/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

class EventViewController: UIViewController {
    private let event: Event
    // TODO: Add copy button?
    private let addressLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let backButton = UIButton()

    // TODO: Add the rest of the event fields

    init(forEvent event: Event) {
        self.event = event
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupLayout()
    }
}

// MARK: Button functions
extension EventViewController {
    @objc private func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: Setup subviews
extension EventViewController {
    private func setupSubviews() {
        backButton.setTitle("Back", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        backButton.setTitleColor(.black, for: .normal)
        backButton.addTarget(self, action: #selector(EventViewController.backButtonPressed(_:)), for: .touchUpInside)
        Util.roundedCorners(ofColor: .black, element: backButton)
        view.addSubview(backButton)

        addressLabel.text = event.address
        addressLabel.textAlignment = .center
        addressLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        addressLabel.numberOfLines = 0
        view.addSubview(addressLabel)

        descriptionLabel.text = event.description
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 0
        view.addSubview(descriptionLabel)

        view.backgroundColor = .white
    }

    private func setupLayout() {
        addressLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        backButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(100)
            make.width.equalTo(100)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
    }
}
