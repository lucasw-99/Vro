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
    private let backButton = UIButton()
    private let separatorView = UIView()

    // add copy address button?
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let addressTextView = UITextView()
    private let descriptionLabel = UILabel()
    private let footerView = UIView()

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
        backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(EventViewController.backButtonPressed(_:)), for: .touchUpInside)
        view.addSubview(backButton)

        separatorView.backgroundColor = .gray
        view.addSubview(separatorView)

        addressTextView.text = event.address
        addressTextView.textColor = .black
        addressTextView.textAlignment = .center
        addressTextView.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        addressTextView.isEditable = false
        addressTextView.isSelectable = true
        addressTextView.isScrollEnabled = false
        contentView.addSubview(addressTextView)

        descriptionLabel.text = event.description
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 0
        contentView.addSubview(descriptionLabel)

        footerView.backgroundColor = .black
        contentView.addSubview(footerView)

        scrollView.addSubview(contentView)

        scrollView.backgroundColor = .white
        view.addSubview(scrollView)

        view.backgroundColor = .white
    }

    private func setupLayout() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.leading.equalToSuperview().offset(15)
        }

        separatorView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(1)
        }

        addressTextView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        // TODO: Remove ambiguous scroll view height stuff somehow!
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(addressTextView.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualTo(footerView.snp.top)
//            make.bottom.equalTo(footerView.snp.top).priority(999)
        }

        footerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view.snp.width)
            make.height.greaterThanOrEqualTo(scrollView.snp.height)
            make.centerX.equalToSuperview()
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(20)
        }
    }
}
