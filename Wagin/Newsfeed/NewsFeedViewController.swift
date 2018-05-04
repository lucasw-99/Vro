//
//  NewsFeedViewController.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/4/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import SnapKit

class NewsFeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    static var testUser = UserProfile(uid: "1", username: "Lucas", photoURL: URL(fileURLWithPath: "Haha.com"))
    static var testEvent = Event(host: testUser, eventImage: #imageLiteral(resourceName: "home"), description: "nah", address: nil)

    private var DataSource: [EventPost] = [EventPost(postedBy: testUser, event: testEvent, likedBy: [testUser], caption: "Whats up hoes", dayPosted: Date().addingTimeInterval(-30)), EventPost(postedBy: testUser, event: testEvent, likedBy: [testUser], caption: "Whats up hoes", dayPosted: Date().addingTimeInterval(-3000)), EventPost(postedBy: testUser, event: testEvent, likedBy: [testUser], caption: "Whats up hoes", dayPosted: Date().addingTimeInterval(-30)), EventPost(postedBy: testUser, event: testEvent, likedBy: [testUser], caption: "Whats up hoes", dayPosted: Date().addingTimeInterval(-30000))]

    private let headerView = UIView()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setupSubviews() {
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(EventPostCollectionViewCell.self, forCellWithReuseIdentifier: "EventPostCell")

        headerView.backgroundColor = .black
        view.addSubview(headerView)

        view.addSubview(collectionView)

        view.backgroundColor = .white
    }

    private func setupLayout() {
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(100)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return DataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TODO: Change later to always return 1, check if it still works
        return DataSource.isEmpty ? 0 : 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventPostCell", for: indexPath) as! EventPostCollectionViewCell
        cell.eventPost = DataSource[indexPath.section]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 10, height: 550)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    }
}
