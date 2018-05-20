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
    private var userTimelineRef: DatabaseReference?
    // eventPostID => cell
    private var eventPostCells = [String: EventPostCollectionViewCell]()
    // eventPostID => userLikes, likesReference
    private var eventPostLikesObserver = [String: (Set<String>, DatabaseReference)]()

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
        observeEventPosts()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // remove all observers when view disappears
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        for values in eventPostLikesObserver.values {
            let observer = values.1
            observer.removeAllObservers()
        }
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
        guard let currentUID = UserService.currentUserProfile?.uid else { fatalError("Current user is nil") }
        if let ref = userTimelineRef {
            ref.removeAllObservers()
        }
        let userTimelinePath = String(format: Constants.Database.getTimelinePosts, currentUID)
        let ref = Database.database().reference().child(userTimelinePath)
        // TODO: Any point of refresh control? Should I just have it call reloadData?
        TimelineService.populateUserTimeline(currentUID, ref) { posts in
            self.DataSource = posts
            // Do UI updating on main thread
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                // stop refresher from spinning, but not too quickly
                if self.refresher.isRefreshing {
                    let deadline = DispatchTime.now() + .milliseconds(700)
                    DispatchQueue.main.asyncAfter(deadline: deadline) {
                        self.refresher.endRefreshing()
                    }
                }
            }
        }
        userTimelineRef = ref
    }
}

// MARK: Button delegate for EventPostCollectionViewCell
extension NewsFeedViewController: EventPostCellDelegate {
    func didTapLikeButton(likeButton: UIButton, forCell cell: EventPostCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { fatalError("Couldn't get index path") }
        likeButton.isUserInteractionEnabled = false
        let post = DataSource[indexPath.item]
        let wasPreviouslyLiked = likeButton.isSelected
        LikeService.setLiked(didLikePost: !wasPreviouslyLiked, for: post) { (success) in
            defer {
                likeButton.isUserInteractionEnabled = true
            }
            guard success else {
                print("Failure")
                return
            }

            DispatchQueue.main.async {
                cell.numLikes += !wasPreviouslyLiked ? 1 : -1
                likeButton.isSelected = !likeButton.isSelected
            }
        }


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
        let eventPost = DataSource[indexPath.section]
        cell.eventPost = eventPost
        cell.buttonDelegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 550)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }

//    private func setLikes(forCell cell: EventPostCollectionViewCell, eventPost: EventPost) {
//        eventPostCells[eventPost.eventPostID] = cell
//        if let (userLikes, _) = eventPostLikesObserver[eventPost.eventPostID] {
//            cell.updateLikes(numLikes: userLikes.count, userLikes: userLikes)
//        } else {
//            LikeService.getLikesForPost(eventPost.postedByUser.uid, eventPost.eventPostID) { userLikes, likesRef in
//                let userLikesSet = Set<String>(userLikes.keys)
//                self.eventPostLikesObserver[eventPost.eventPostID] = (userLikesSet, likesRef)
//                // TODO: Should I update the cell in the observable?
//                guard let currentCell = self.eventPostCells[eventPost.eventPostID] else { fatalError("cell is nil") }
//                currentCell.updateLikes(numLikes: userLikesSet.count, userLikes: userLikesSet)
//            }
//        }
//    }
}
