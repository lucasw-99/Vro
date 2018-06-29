//
//  EventViewController.swift
//  Vro
//
//  Created by Lucas Wotton on 5/31/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

class EventViewController: UIViewController {
    private let event: Event
    private let backButton = UIButton()
    private let usernameLabel = UILabel()
    private let userProfileImage = UIImageView()
    private let headerView = UIView()
    private let separatorView = UIView()

    // add copy address button?
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let addressTitleLabel = UILabel()
    private let addressTextView = UITextView()
    private let eventImage = UIImageView()
    private let eventTimeTitleLabel = UILabel()
    private let eventTimeLabel = UILabel()
    private let descriptionLabel = UILabel()

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollView.perform(#selector(scrollView.flashScrollIndicators), with: nil, afterDelay: 0)
    }

    override func viewDidLayoutSubviews() {
        userProfileImage.layer.cornerRadius = userProfileImage.frame.width / 2
        eventImage.layer.cornerRadius = eventImage.frame.width / 2
    }
}

// MARK: Button functions
extension EventViewController {
    @objc private func backButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: Setup subviews
extension EventViewController {
    private func setupSubviews() {
        backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(EventViewController.backButtonPressed(_:)), for: .touchUpInside)
        headerView.addSubview(backButton)

        usernameLabel.text = event.host.username
        usernameLabel.textAlignment = .center
        usernameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        usernameLabel.numberOfLines = 1
        headerView.addSubview(usernameLabel)

        userProfileImage.clipsToBounds = true
        ImageService.getImage(withURL: event.host.photoURL) { image in
            self.userProfileImage.image = image
        }
        headerView.addSubview(userProfileImage)

        view.addSubview(headerView)

        separatorView.backgroundColor = .gray
        view.addSubview(separatorView)

        addressTitleLabel.text = "Address"
        addressTitleLabel.textAlignment = .center
        addressTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        addressTitleLabel.numberOfLines = 1
        contentView.addSubview(addressTitleLabel)

        addressTextView.text = event.address
        addressTextView.textColor = .black
        addressTextView.textAlignment = .center
        addressTextView.font = UIFont.systemFont(ofSize: 16)
        addressTextView.textContainerInset = UIEdgeInsets.zero
        addressTextView.textContainer.lineFragmentPadding = 0
        addressTextView.isEditable = false
        addressTextView.isSelectable = true
        addressTextView.isScrollEnabled = false
        contentView.addSubview(addressTextView)

        guard let eventUrl = URL(string: event.eventImageURL) else { fatalError("url invalid") }
        ImageService.getImage(withURL: eventUrl) { image in
            self.eventImage.image = image
        }
        eventImage.clipsToBounds = true
        contentView.addSubview(eventImage)

        eventTimeTitleLabel.text = "Time"
        eventTimeTitleLabel.textAlignment = .center
        eventTimeTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        eventTimeTitleLabel.numberOfLines = 1
        contentView.addSubview(eventTimeTitleLabel)

        eventTimeLabel.text = Util.dateToString(date: event.eventTime)
        eventTimeLabel.textAlignment = .center
        eventTimeLabel.font = UIFont.systemFont(ofSize: 16)
        eventTimeLabel.numberOfLines = 0
        contentView.addSubview(eventTimeLabel)

        descriptionLabel.text = event.description
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 0
        contentView.addSubview(descriptionLabel)

        scrollView.addSubview(contentView)

        scrollView.backgroundColor = .white
        view.addSubview(scrollView)

        view.backgroundColor = .white
    }

    private func setupLayout() {
        backButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.leading.equalToSuperview().offset(15)
        }

        userProfileImage.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(70)
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(50)
        }

        usernameLabel.snp.makeConstraints { make in
            make.leading.equalTo(userProfileImage.snp.trailing).offset(10)
            make.top.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(separatorView.snp.bottom)
        }

        separatorView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(1)
        }

        addressTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        addressTextView.snp.makeConstraints { make in
            make.top.equalTo(addressTitleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        eventImage.snp.makeConstraints { make in
            make.top.equalTo(addressTextView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(200)
        }

        eventTimeTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(eventImage.snp.bottom).offset(30)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        eventTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(eventTimeTitleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(eventTimeLabel.snp.bottom).offset(40)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view.snp.width)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(20)
        }
    }
}
