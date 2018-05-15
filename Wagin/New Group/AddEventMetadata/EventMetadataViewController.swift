//
//  EventMetadataViewController.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/7/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import MapKit

class EventMetadataViewController: UIViewController {
    private let contentView = UIView()

    private let addressLabel = UILabel()

    private let captionLabel = UILabel()
    private let captionText = UITextView()

    private let timeLabel = UILabel()
    private let eventDate = UIDatePicker()

    private let confirmButton = UIButton()
    private let cancelButton = UIButton()

    private var selectedPin: MKPointAnnotation

    init(selectedPin: MKPointAnnotation) {
        self.selectedPin = selectedPin
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

    // address: An address passed from the previous view controller
    // This function is used to initialize the address field in this controller.
    func setAddressLabelText() {
        let addressPrompt = "Address of Event: \n"
        let providedAddress = selectedPin.title ?? "Not Provided"
        let addressLabelString = "\(addressPrompt)\(providedAddress)"
        let nsrange = NSMakeRange(addressPrompt.count, providedAddress.count)
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: addressLabelString)
        attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 20, weight: .semibold), range: nsrange)
        addressLabel.attributedText = attributedString
    }

    @IBAction func confirmSelections(_ sender: Any) {
        // TODO: Check for nil caption?
        let uploadEventViewController = UploadEventViewController(pin: selectedPin, date: eventDate.date, caption: captionText.text)
        navigationController?.pushViewController(uploadEventViewController, animated: true)
    }

    @IBAction func popEventMetadataView(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

}

// MARK: Subview setup
extension EventMetadataViewController {
    private func setupSubviews() {
        addressLabel.font = UIFont.systemFont(ofSize: 20)
        addressLabel.numberOfLines = 0
        addressLabel.textAlignment = .center
        setAddressLabelText()
        contentView.addSubview(addressLabel)

        captionLabel.text = "Caption of Event"
        captionLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        captionLabel.numberOfLines = 1
        captionLabel.textAlignment = .center
        contentView.addSubview(captionLabel)

        Util.roundedCorners(ofColor: .lightGray, element: captionText)
        captionText.doneAccessory = true
        contentView.addSubview(captionText)

        timeLabel.text = "Time of Event"
        timeLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        timeLabel.numberOfLines = 1
        timeLabel.textAlignment = .center
        contentView.addSubview(timeLabel)

        eventDate.datePickerMode = .dateAndTime
        eventDate.minuteInterval = 15
        eventDate.date = Date()
        eventDate.minimumDate = Date()
        contentView.addSubview(eventDate)

        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        cancelButton.addTarget(self, action: #selector(EventMetadataViewController.popEventMetadataView(_:)), for: .touchUpInside)
        cancelButton.backgroundColor = .lightGray
        Util.roundedCorners(ofColor: .lightGray, element: cancelButton)
        contentView.addSubview(cancelButton)

        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        confirmButton.addTarget(self, action: #selector(EventMetadataViewController.confirmSelections(_:)), for: .touchUpInside)
        confirmButton.backgroundColor = .lightGray
        Util.roundedCorners(ofColor: .lightGray, element: confirmButton)
        contentView.addSubview(confirmButton)

        contentView.backgroundColor = .white
        view.addSubview(contentView)
    }

    private func setupLayout() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(view.layoutMarginsGuide.snp.topMargin).offset(40)
            make.leading.equalTo(contentView.snp.leadingMargin)
            make.trailing.equalTo(contentView.snp.trailingMargin)
        }

        captionLabel.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(40)
            make.leading.equalTo(contentView.snp.leadingMargin)
            make.trailing.equalTo(contentView.snp.trailingMargin)
        }

        captionText.snp.makeConstraints { make in
            make.top.equalTo(captionLabel.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalTo(225)
            make.height.equalTo(85)
        }

        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(captionText.snp.bottom).offset(35)
            make.leading.equalTo(contentView.snp.leadingMargin)
            make.trailing.equalTo(contentView.snp.trailingMargin)
        }

        eventDate.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalTo(200)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(eventDate.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(90)
            make.height.equalTo(40)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(cancelButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(90)
            make.height.equalTo(40)
        }
    }
}
