//
//  UserProfileViewController.swift
//  Vro
//
//  Created by Lucas Wotton on 5/12/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import SnapKit

// TODO: Alot of duplicate code in this class. Maybe reduce
// code duplication by making Collection view a class?
class UserProfileViewController: UIViewController {
    private let selectedUser: UserProfile
    
    private let headerView = UIView()
    private let backButton = UIButton()
    private let usernameLabel = UILabel()
    private let separatorView = UIView()
    
    private let eventsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        return cv
    }()
    
    private lazy var refresher: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .black
        refreshControl.addTarget(self, action: #selector(UserProfileViewController.observeEventPosts), for: .valueChanged)
        return refreshControl
    }()
    
    private var dataSource = [EventPost]()


    init(_ userProfile: UserProfile) {
        selectedUser = userProfile
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
    }
}

// MARK: Setup subviews
extension UserProfileViewController {
    private func setupSubviews() {
        backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(UserProfileViewController.backButtonPressed(_:)), for: .touchUpInside)
        headerView.addSubview(backButton)
        
        usernameLabel.text = selectedUser.username
        usernameLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        usernameLabel.numberOfLines = 0
        usernameLabel.textAlignment = .center
        headerView.addSubview(usernameLabel)
        
        view.addSubview(headerView)
        
        separatorView.backgroundColor = .gray
        view.addSubview(separatorView)
        
        eventsCollectionView.delegate = self
        eventsCollectionView.dataSource = self
        eventsCollectionView.refreshControl = refresher
        eventsCollectionView.register(EventPostCollectionViewCell.self, forCellWithReuseIdentifier: "EventPostCell")
        // TODO: HACK. One day I should fix this. https://stackoverflow.com/questions/17681183/uicollectionview-header-and-footer-view
        eventsCollectionView.register(ProfileHeaderCollectionViewCell.self, forCellWithReuseIdentifier: "UserProfileHeader")
        view.addSubview(eventsCollectionView)

        view.backgroundColor = .white
    }

    private func setupLayout() {
        usernameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.leading.equalTo(backButton.snp.trailing).offset(20)
        }
        
        backButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.leading.equalToSuperview().offset(15)
        }

        headerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
        }
        
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(1)
        }
        
        eventsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

// MARK: Populate dataSource
extension UserProfileViewController: UICollectionViewDataSource {
    @objc private func observeEventPosts() {
        EventPostService.getUserEvents(String(selectedUser.uid)) { eventPosts in
            // TODO: Store and sort by negative timestamps, akin to how you did notifications
            self.dataSource = eventPosts.reversed()
            // Do UI updating on main thread
            DispatchQueue.main.async {
                self.eventsCollectionView.reloadData()
                // stop refresher from spinning, but not too quickly
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

// MARK: Button functions
extension UserProfileViewController {
    @objc private func backButtonPressed(_ sender: UIButton) {
        // Stop observing updates to user followers
        navigationController?.popViewController(animated: true)
    }
}

// MARK: Button delegate for EventPostCollectionViewCell
extension UserProfileViewController: EventPostCellDelegate {
    func didTapUsernameButton(_ usernameButton: UIButton, forUser user: UserProfile) {
        usernameButton.isUserInteractionEnabled = false
        defer {
            usernameButton.isUserInteractionEnabled = true
        }
        
        let userProfileViewController = UserProfileViewController(user)
        navigationController?.pushViewController(userProfileViewController, animated: true)
    }
    
    func didTapAttendButton(_ attendButton: UIButton, forCell cell: EventPostCollectionViewCell) {
        guard let indexPath = eventsCollectionView.indexPath(for: cell) else { fatalError("Couldn't get index path for attending") }
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
        guard let indexPath = eventsCollectionView.indexPath(for: cell) else { fatalError("Couldn't get index path") }
        likeButton.isUserInteractionEnabled = false
        let post = dataSource[indexPath.section]
        let wasPreviouslyLiked = likeButton.isSelected
        LikeService.setLiked(didLikePost: !wasPreviouslyLiked, for: post) { (success) in
            defer {
                likeButton.isUserInteractionEnabled = true
            }
            guard success else {
                print("Failed to like post")
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
//        numLikesButton.isUserInteractionEnabled = false
//        defer {
//            numLikesButton.isUserInteractionEnabled = true
//        }
//
//        let listLikesViewController = ListLikesViewController(postedByUid: String(event.event.host.uid), eventPostId: event.eventPostID)
//        navigationController?.pushViewController(listLikesViewController, animated: true)
    }
    
    func didTapNumGuestsButton(numGuestsButton: UIButton, forEvent event: EventPost) {
//        numGuestsButton.isUserInteractionEnabled = false
//        defer {
//            numGuestsButton.isUserInteractionEnabled = true
//        }
//
//        let listGuestsViewController = ListGuestsViewController(eventPostId: event.eventPostID)
//        navigationController?.pushViewController(listGuestsViewController, animated: true)
    }
}

// MARK: Collection view
extension UserProfileViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            // TODO: Hack. Need to eventually fix this?
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserProfileHeader", for: indexPath) as! ProfileHeaderCollectionViewCell
            cell.selectedUser = selectedUser
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventPostCell", for: indexPath) as! EventPostCollectionViewCell
        let eventPost = dataSource[indexPath.section - 1]
        cell.eventPost = eventPost
        cell.buttonDelegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let zeroHeightSize = CGSize(width: collectionView.frame.width - 10 - 10, height: 0)
        if indexPath.section == 0 {
            let sizingCell = ProfileHeaderCollectionViewCell()
            sizingCell.selectedUser = selectedUser
            let size = sizingCell.contentView.systemLayoutSizeFitting(zeroHeightSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
            return size
        }
        let eventPost = dataSource[indexPath.section - 1]
        let sizingCell = EventPostCollectionViewCell()
        sizingCell.eventPost = eventPost
        let size = sizingCell.contentView.systemLayoutSizeFitting(zeroHeightSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}
