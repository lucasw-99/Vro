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
    private var followedUsers: Set<String>?
    private var userFollowersRef: DatabaseReference?

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
    private lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .black
        refreshControl.addTarget(self, action: #selector(NewsFeedViewController.observeEventPosts), for: .valueChanged)
        return refreshControl
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupLayout()
        loadFollowers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

}

// MARK: Setup subviews
extension NewsFeedViewController {
    private func setupSubviews() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.refreshControl = refresher
        collectionView.register(EventPostCollectionViewCell.self, forCellWithReuseIdentifier: "EventPostCell")

        waginLabel.text = "Wagin"
        waginLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        waginLabel.numberOfLines = 1
        waginLabel.textAlignment = .center
        headerView.addSubview(waginLabel)

        separatorView.backgroundColor = .lightGray
        headerView.addSubview(separatorView)

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
}

// MARK: Populate timeline
extension NewsFeedViewController {
    @objc private func observeEventPosts() {
        guard var followedUsers = followedUsers else { fatalError("observeEventPosts called with nil userFollowersInfo") }
        // add yourself to followedUsers because you want to see your posts
        followedUsers.insert(UserService.currentUserProfile!.uid)
        var tempPosts = [EventPost]()
        let numFollowed = followedUsers.count
        var usersSeen = 0
        for uid in followedUsers {
            observeUserEventPosts(uid) { userPosts in
                tempPosts.append(contentsOf: userPosts)
                usersSeen += 1
                if usersSeen == numFollowed {
                    // sort posts in ascending order
                    tempPosts.sort(by: { (ep1, ep2) -> Bool in
                        return ep2.timestamp.compare(ep1.timestamp) == .orderedAscending
                    })
                    self.DataSource = tempPosts
                    self.collectionView.reloadData()
                    if self.refresher.isRefreshing {
                        let deadline = DispatchTime.now() + .milliseconds(700)
                        DispatchQueue.main.asyncAfter(deadline: deadline) {
                            self.refresher.endRefreshing()
                        }
                    }
                }
            }
        }
    }

    // uid: Fetches event post belonging to user with passed in uid
    private func observeUserEventPosts(_ uid: String, completion: @escaping ( (_ userPosts: [EventPost]) -> () )) {
        var userPosts = [EventPost]()
        let followedUserEvents = String(format: Constants.Database.userEventPosts, uid)
        let eventPostsRef = Database.database().reference().child(followedUserEvents)
        eventPostsRef.observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let eventPostDict = childSnapshot.value as? [String: Any],
                    let postedByUserDict = eventPostDict["postedByUser"] as? [String: Any],
                    let postedByUID = postedByUserDict["uid"] as? String,
                    let postedByUsername = postedByUserDict["username"] as? String,
                    let postedByPhotoURLString = postedByUserDict["photoURL"] as? String,
                    let postedByPhotoURL = URL(string: postedByPhotoURLString),
                    let eventDict = eventPostDict["event"] as? [String: Any],
                    let hostUID = eventDict["hostUID"] as? String,
                    let eventDescription = eventDict["description"] as? String,
                    let eventAddress = eventDict["address"] as? String,
                    let eventImageURL = eventDict["eventImageURL"] as? String,
                    let eventTime = eventDict["eventTime"] as? String,
                    let eventPostCaption = eventPostDict["caption"] as? String,
                    let eventPostTimestamp = eventPostDict["timestamp"] as? TimeInterval,
                    let eventPostID = eventPostDict["eventPostID"] as? String {

                    print("postedByPhotoURL: \(postedByPhotoURL), uid: \(uid)")

                    let eventDate = Util.stringToDate(dateString: eventTime)
                    let timestamp = Date(timeIntervalSince1970: eventPostTimestamp / 1000)

                    // TODO: Get followers

                    let postedByUser = UserProfile(postedByUID, postedByUsername, postedByPhotoURL)

                    let event = Event(hostUID, eventImageURL, eventDescription, eventAddress, eventDate)
                    let eventPost = EventPost(postedByUser, event, Set<String>(), eventPostCaption, timestamp, eventPostID)

                    userPosts.append(eventPost)
                }
            }
            completion(userPosts)
        })
    }
}

// MARK: Button delegate for EventPostCollectionViewCell
extension NewsFeedViewController: EventPostCellDelegate {
    func didTapLikeButton(_ postedByUID: String, _ likePost: Bool, _ eventPostID: String) {
        print("unimplemented")
    }

    func didTapCommentButton(_ postedByUID: String, eventPostID: String) {
        print("unimplemented")
    }

    func didTapShareButton(_ postedByUID: String, eventPostID: String) {
        print("unimplemented")
    }


}

// MARK: Collection view
extension NewsFeedViewController {
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
        cell.buttonDelegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 10, height: 550)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    }
}

// MARK: Load new followers
extension NewsFeedViewController {
    // TODO: Load followers through an observable
    func loadFollowers() {
        guard let currentUserUID = UserService.currentUserProfile?.uid else { fatalError("current user is nil") }
        let userFollowersPath = String(format: Constants.Database.userFollowerInfo, currentUserUID)
        userFollowersRef = Database.database().reference().child(userFollowersPath)

        UserService.getFollowerInfo(currentUserUID, userFollowersRef!) { followersInfo in
            self.followedUsers = followersInfo.followers
            self.observeEventPosts()
        }
    }
}
