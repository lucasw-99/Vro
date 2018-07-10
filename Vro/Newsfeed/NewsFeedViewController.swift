//
//  NewsFeedViewController.swift
//  Vro
//
//  Created by Lucas Wotton on 5/4/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseDatabase

class NewsFeedViewController: UIViewController {

    private var dataSource: [EventPost] = []
    private var followedUsers: Set<String>?
    private var userTimelineRef: DatabaseReference?

    private let vroLabel = UILabel()
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
}

// MARK: Setup subviews
extension NewsFeedViewController {
    private func setupSubviews() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.refreshControl = refresher
        collectionView.register(EventPostCollectionViewCell.self, forCellWithReuseIdentifier: "EventPostCell")

        vroLabel.text = "Vro"
        vroLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        vroLabel.numberOfLines = 1
        vroLabel.textAlignment = .center
        headerView.addSubview(vroLabel)

        separatorView.backgroundColor = .lightGray
        headerView.addSubview(separatorView)

        view.addSubview(headerView)

        view.addSubview(collectionView)

        view.backgroundColor = .white
    }

    private func setupLayout() {
        vroLabel.snp.makeConstraints { make in
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

// MARK: Populate dataSource
extension NewsFeedViewController: UICollectionViewDataSource {
    @objc private func observeEventPosts() {
        guard let currentUID = UserService.currentUserProfile?.uid else { fatalError("Current user is nil") }
        if let ref = userTimelineRef {
            ref.removeAllObservers()
        }
        let userTimelinePath = String(format: Constants.Database.getTimelinePosts, currentUID)
        let ref = Database.database().reference().child(userTimelinePath)
        // TODO: Remove old posts from user timelines
        TimelineService.populateUserTimeline(currentUID, ref) { posts in
            self.dataSource = posts
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
    func didTapAttendButton(_ attendButton: UIButton, forCell cell: EventPostCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { fatalError("Couldn't get index path for attending") }
        attendButton.isUserInteractionEnabled = false
        let eventPost = dataSource[indexPath.section]
        let wasPreviouslyAttending = attendButton.isSelected
        AttendEventService.setPotentiallyAttending(nowAttendingEvent: !wasPreviouslyAttending, for: eventPost) { success in
            defer {
                attendButton.isUserInteractionEnabled = true
            }
            guard success else {
                print("Failure setting attending")
                return
            }
            DispatchQueue.main.async {
                cell.numAttending += !wasPreviouslyAttending ? 1 : -1
                attendButton.isSelected = !attendButton.isSelected
            }
        }
    }

    func didTapLikeButton(_ likeButton: UIButton, forCell cell: EventPostCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { fatalError("Couldn't get index path") }
        likeButton.isUserInteractionEnabled = false
        let post = dataSource[indexPath.section]
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

    func didTapCommentButton(_ commentButton: UIButton, forEvent event: EventPost) {
        commentButton.isUserInteractionEnabled = false
        defer {
            commentButton.isUserInteractionEnabled = true
        }

        let commentsViewController = ShowCommentsViewController(eventPost: event, postNewComment: true)
        navigationController?.pushViewController(commentsViewController, animated: true)
    }

    func didTapShareButton(_ shareButton: UIButton, forEvent event: Event) {
        shareButton.isUserInteractionEnabled = false
        defer {
            shareButton.isUserInteractionEnabled = true
        }

        let eventViewController = EventViewController(forEvent: event)
        navigationController?.pushViewController(eventViewController, animated: true)
    }

    func didTapShowCommentsButton(showCommentsButton: UIButton, forEvent event: EventPost) {
        showCommentsButton.isUserInteractionEnabled = false
        defer {
            showCommentsButton.isUserInteractionEnabled = true
        }
        
        let commentsViewController = ShowCommentsViewController(eventPost: event, postNewComment: false)
        navigationController?.pushViewController(commentsViewController, animated: true)
    }
    
    func didTapNumLikesButton(numLikesButton: UIButton, forEvent event: EventPost) {
        numLikesButton.isUserInteractionEnabled = false
        defer {
            numLikesButton.isUserInteractionEnabled = true
        }
        
        let listLikesViewController = ListLikesViewController(postedByUid: event.event.host.uid, eventPostId: event.eventPostID)
        navigationController?.pushViewController(listLikesViewController, animated: true)
    }
    
    func didTapNumGuestsButton(numGuestsButton: UIButton, forEvent event: EventPost) {
        numGuestsButton.isUserInteractionEnabled = false
        defer {
            numGuestsButton.isUserInteractionEnabled = true
        }
        
        let listGuestsViewController = ListGuestsViewController(eventPostId: event.eventPostID)
        navigationController?.pushViewController(listGuestsViewController, animated: true)
    }
}

// MARK: Collection view
extension NewsFeedViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TODO: Change later to always return 1, check if it still works
        return dataSource.isEmpty ? 0 : 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventPostCell", for: indexPath) as! EventPostCollectionViewCell
        let eventPost = dataSource[indexPath.section]
        cell.eventPost = eventPost
        cell.buttonDelegate = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let eventPost = dataSource[indexPath.section]
        let sizingCell = EventPostCollectionViewCell()
        sizingCell.eventPost = eventPost
        let zeroHeightSize = CGSize(width: collectionView.frame.width - 10 - 10, height: 0)
        let size = sizingCell.contentView.systemLayoutSizeFitting(zeroHeightSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
        return size
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}
