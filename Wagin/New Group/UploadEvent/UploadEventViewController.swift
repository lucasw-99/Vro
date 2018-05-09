//
//  UploadEventViewController.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/8/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import MapKit

class UploadEventViewController: UIViewController {
    private let pin: MKPointAnnotation
    private let date: Date
    private let caption: String

    private let eventLabel = UILabel()
    private let uploadEventImageButton = UIButton()

    private let postEventButton = UIButton()
    private var backButton = UIButton()

    private let contentView = UIView()

    init(pin: MKPointAnnotation, date: Date, caption: String) {
        self.pin = pin
        self.date = date
        self.caption = caption
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

    @IBAction func uploadEventImage(_ sender: Any) {
        print("Upload button pressed")
        // TODO: Make upload image function global
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        print("Back button pressed")
    }

    @IBAction func postNewEvent(_ sender: Any) {
        print("Post new event pressed")
    }
}

// MARK: Setup subviews
extension UploadEventViewController {
    private func setupSubviews() {
        eventLabel.text = "Upload Event Image"
        eventLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        eventLabel.numberOfLines = 1
        eventLabel.textAlignment = .center
        eventLabel.textColor = .lightGray
        contentView.addSubview(eventLabel)
        uploadEventImageButton.setImage(#imageLiteral(resourceName: "upload"), for: .normal)
        uploadEventImageButton.addTarget(self, action: #selector(NewEventViewController.uploadEventImage(_:)), for: .touchUpInside)
        Util.roundedCorners(ofColor: .lightGray, element: uploadEventImageButton)
        contentView.addSubview(uploadEventImageButton)

        uploadEventImageButton.setImage(#imageLiteral(resourceName: "upload"), for: .normal)
        uploadEventImageButton.addTarget(self, action: #selector(UploadEventViewController.uploadEventImage(_:)), for: .touchUpInside)
        Util.roundedCorners(ofColor: .lightGray, element: uploadEventImageButton)
        contentView.addSubview(uploadEventImageButton)

        backButton.setTitle("Back", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        backButton.addTarget(self, action: #selector(UploadEventViewController.backButtonPressed(_:)), for: .touchUpInside)
        backButton.backgroundColor = .lightGray
        Util.roundedCorners(ofColor: .lightGray, element: backButton)
        contentView.addSubview(backButton)

        postEventButton.setTitle("Post", for: .normal)
        postEventButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        postEventButton.addTarget(self, action: #selector(UploadEventViewController.postNewEvent(_:)), for: .touchUpInside)
        postEventButton.backgroundColor = .lightGray
        Util.roundedCorners(ofColor: .lightGray, element: postEventButton)
        contentView.addSubview(postEventButton)

        contentView.backgroundColor = .white
        view.addSubview(contentView)
    }

    private func setupLayout() {
        eventLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(45)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        uploadEventImageButton.snp.makeConstraints { make in
            make.top.equalTo(eventLabel.snp.bottom).offset(15)
            make.width.equalTo(90)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }

        postEventButton.snp.makeConstraints { make in
            make.top.equalTo(uploadEventImageButton.snp.bottom).offset(45)
            make.centerX.equalToSuperview()
            make.width.equalTo(90)
            make.height.equalTo(40)
        }

        backButton.snp.makeConstraints { make in
            make.top.equalTo(postEventButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(90)
            make.height.equalTo(40)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
