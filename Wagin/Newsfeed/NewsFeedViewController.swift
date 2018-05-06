//
//  NewsFeedViewController.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/4/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseDatabase

class NewsFeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    private var DataSource: [EventPost] = []

    private let waginLabel = UILabel()
    private let separatorView = UIView()
    private let headerView = UIView()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        return cv
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
        observeEventPosts()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupLayout()
        observeEventPosts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func observeEventPosts() {
        let eventPostsRef = Database.database().reference().child(Constants.eventPosts)
        eventPostsRef.observe(.value, with: { snapshot in
            var tempPosts = [EventPost]()
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                let eventPostDict = childSnapshot.value as? [String: Any],
                    let postedByDict = eventPostDict["postedBy"] as? [String: Any],
                    let postedByUid = postedByDict["uid"] as? String,
                    let postedByUsername = postedByDict["username"] as? String,
                    let postedByAbsolutePhotoURL = postedByDict["photoURL"] as? String,
                    let postedByPhotoURL = URL(string: postedByAbsolutePhotoURL),
                    let eventDict = eventPostDict["event"] as? [String: Any],
                    let hostDict = eventDict["host"] as? [String: Any],
                    let hostUid = hostDict["uid"] as? String,
                    let hostUsername = hostDict["username"] as? String,
                    let hostAbsolutePhotoURL = hostDict["photoURL"] as? String,
                    let hostPhotoURL = URL(string: hostAbsolutePhotoURL),
                    let eventDescription = eventDict["description"] as? String,
                    let eventAddress = eventDict["address"] as? String,
                    let eventTime = eventDict["eventTime"] as? String,
                    let eventPostCaption = eventPostDict["caption"] as? String,
                    let eventPostTimestamp = eventPostDict["timestamp"] as? TimeInterval {

                    let hostUser = UserProfile(uid: hostUid, username: hostUsername, photoURL: hostPhotoURL)
                    let postedByUser = UserProfile(uid: postedByUid, username: postedByUsername, photoURL: postedByPhotoURL)

                    let eventDate = Util.stringToDate(dateString: eventTime)
                    let timestamp = Date(timeIntervalSince1970: eventPostTimestamp / 1000)
                    
                    let event = Event(host: hostUser, eventImage: #imageLiteral(resourceName: "settings"), description: eventDescription, address: eventAddress, eventTime: eventDate)
                    let eventPost = EventPost(postedBy: postedByUser, event: event, likedBy: [], caption: eventPostCaption, timestamp: timestamp)

                    tempPosts.append(eventPost)
                }
            }
            self.DataSource = tempPosts
            self.collectionView.reloadData()
        })
    }

    private func setupSubviews() {
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.register(EventPostCollectionViewCell.self, forCellWithReuseIdentifier: "EventPostCell")

        waginLabel.text = "Wagin"
        waginLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        waginLabel.numberOfLines = 1
        waginLabel.textAlignment = .center
        headerView.addSubview(waginLabel)

        separatorView.backgroundColor = .lightGray
        headerView.addSubview(separatorView)

//        headerView.backgroundColor = .white
        view.addSubview(headerView)

        view.addSubview(collectionView)

        view.backgroundColor = .white
    }

    private func setupLayout() {
        waginLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
            make.bottom.equalToSuperview()
        }

        separatorView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }

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
