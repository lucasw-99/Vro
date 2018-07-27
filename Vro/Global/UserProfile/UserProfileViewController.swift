//
//  UserProfileViewController.swift
//  Vro
//
//  Created by Lucas Wotton on 5/12/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SnapKit

// TODO: Alot of duplicate code in this class. Maybe reduce
// code duplication by making Collection view a class?
class UserProfileViewController: UIViewController {
    private let selectedUser: UserProfile
    private var selectedUserFollowers: UserFollowers!
    private let selectedUserFollowersRef: DatabaseReference
    private let currentUserUid: String

    private let headerView = UIView()
    private let backButton = UIButton()
    private let usernameLabel = UILabel()
    private let separatorView = UIView()
    private let profilePhotoView = UIImageView()
    private let followerStatsLabel = UILabel()
    private let followButton = UIButton()
    private let separatorView2 = UIView()
    
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

    // TODO: Add selectable followers and following, possibly in scroll view. Maybe
    // make it linkable text??

    init(_ userProfile: UserProfile) {
        selectedUser = userProfile
        
        guard let uid = UserService.currentUserProfile?.uid else { fatalError("current user nil") }
        currentUserUid = uid
        let selectedUserFollowersPath = String(format: Constants.Database.userFollowerInfo, selectedUser.uid)
        selectedUserFollowersRef = Database.database().reference().child(selectedUserFollowersPath)
        
        super.init(nibName: nil, bundle: nil)

        // disable follow button until observable fires
        followButton.isUserInteractionEnabled = false

        // TODO: Put this code in viewDidDisappear and remove the DatabaseReferences
        FollowersService.getFollowerInfo(selectedUser.uid, selectedUserFollowersRef) { selectedUserFollowerInfo in
            print("UserProfileViewController selectedUser observable")
            self.selectedUserFollowers = selectedUserFollowerInfo
            self.setupFollowingLabelText()
            let currentUser = Follower(self.currentUserUid)
            self.followButton.isSelected = selectedUserFollowerInfo.followers.contains(currentUser)
            self.followButton.isUserInteractionEnabled = true
        }
        
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
        
        ImageService.getImage(withURL: selectedUser.photoURL) { image in
            guard let image = image else { fatalError("User image was nil") }
            self.profilePhotoView.image = image
            Util.makeImageCircular(image: self.profilePhotoView, 100)
        }
        view.addSubview(profilePhotoView)

        followerStatsLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        followerStatsLabel.numberOfLines = 0
        followerStatsLabel.textAlignment = .center
        view.addSubview(followerStatsLabel)

        followButton.setTitle("Follow", for: .normal)
        followButton.setTitle("Following", for: .selected)
        followButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        followButton.setTitleColor(.black, for: .normal)
        followButton.addTarget(self, action: #selector(UserProfileViewController.followButtonPressed(_:)), for: .touchUpInside)
        // don't show follow button if you're looking up your own profile
        followButton.isHidden = UserService.currentUserProfile!.uid == selectedUser.uid ? true : false
        Util.roundedCorners(ofColor: .black, element: followButton)
        view.addSubview(followButton)
        
        separatorView2.backgroundColor = .gray
        view.addSubview(separatorView2)
        
        eventsCollectionView.delegate = self
        eventsCollectionView.dataSource = self
        eventsCollectionView.refreshControl = refresher
        eventsCollectionView.register(EventPostCollectionViewCell.self, forCellWithReuseIdentifier: "EventPostCell")
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

        profilePhotoView.snp.makeConstraints { make in
            make.width.equalTo(100)
            make.height.equalTo(100)
            make.top.equalTo(separatorView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        followerStatsLabel.snp.makeConstraints { make in
            make.top.equalTo(profilePhotoView.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        followButton.snp.makeConstraints { make in
            make.top.equalTo(followerStatsLabel.snp.bottom).offset(30)
            make.width.equalTo(100)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
        
        separatorView2.snp.makeConstraints { make in
            let isCurrentUser = currentUserUid == selectedUser.uid
            make.top.equalTo(isCurrentUser ? followerStatsLabel.snp.bottom : followButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(1)
        }
        
        eventsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(separatorView2.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    private func setupFollowingLabelText() {
        let followerCount = selectedUserFollowers.followers.count
        let followingCount = selectedUserFollowers.following.count
        followerStatsLabel.text = "\(followerCount) follower\(followerCount != 1 ? "s" : "")\n\(followingCount) following"
    }
}

// MARK: Populate dataSource
extension UserProfileViewController: UICollectionViewDataSource {
    @objc private func observeEventPosts() {
        guard let currentUid = UserService.currentUserProfile?.uid else { fatalError("Current user is nil") }
        
        EventPostService.getUserEvents(currentUid) { eventPosts in
            self.dataSource = eventPosts
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
        print("back button pressed")
        selectedUserFollowersRef.removeAllObservers()
        navigationController?.popViewController(animated: true)
    }

    @objc private func followButtonPressed(_ sender: Any) {
        // disable button while editing
        Util.toggleButton(button: self.followButton, isEnabled: false)
        guard let currentUser = UserService.currentUserProfile else { fatalError("current user nil??") }
        print("follow button disabled")
        let wasSelected = followButton.isSelected
        followButton.isSelected = !followButton.isSelected
        print("updating followers")
        FollowersService.updateFollowers(uid: currentUser.uid, followedUid: selectedUserFollowers.uid, addFollower: !wasSelected) {
            Util.toggleButton(button: self.followButton, isEnabled: true)
        }
    }
}

// MARK: Button delegate for EventPostCollectionViewCell
extension UserProfileViewController: EventPostCellDelegate {
    func didTapUsernameButton(_ usernameButton: UIButton, forUser: UserProfile) {
        print("Soon")
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
extension UserProfileViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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

