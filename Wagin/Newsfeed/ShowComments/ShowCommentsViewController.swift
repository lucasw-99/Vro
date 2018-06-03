//
//  ShowCommentsViewController.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/20/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import SnapKit

class ShowCommentsViewController: UIViewController {
    private var dataSource = [(Comment, UserProfile)]()
    private let eventPostID: String
    private let postNewComment: Bool

    private let titleView = UIView()
    private let titleLabel = UILabel()
    private let backButton = UIButton()
    private let topSeparatorView = UIView()

    private let dimView = UIView()

    private let bottomSeparatorView = UIView()
    private let commentView = UIView()
    private let commentTextField = PaddedTextField()

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
        refreshControl.addTarget(self, action: #selector(ShowCommentsViewController.observeEventComments), for: .valueChanged)
        return refreshControl
    }()

    init(eventPostID: String, postNewComment: Bool) {
        self.eventPostID = eventPostID
        self.postNewComment = postNewComment
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupLayout()
        observeEventComments()
        if postNewComment {
            selectCommentTextField()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func selectCommentTextField() {
        commentTextField.becomeFirstResponder()
    }
}

// MARK: Populate dataSource
extension ShowCommentsViewController: UICollectionViewDataSource {
    @objc private func observeEventComments() {
        CommentService.commentsForEvent(eventPostID) { comments in
            CommentService.commentsForEvent(self.eventPostID) { comments in
                print("Loading comments: \(comments)")
                // get username for each comment
                let userComments = self.observeUserComments(forComments: comments)
                self.dataSource = userComments
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

        }
    }

    private func observeUserComments(forComments comments: [Comment]) -> [(Comment, UserProfile)] {
        var userComments = [(Comment, UserProfile)]()
        let dispatchGroup = DispatchGroup()
        for comment in comments {
            let commentAuthorUID = comment.commentAuthorID
            dispatchGroup.enter()
            UserService.observeUserProfile(commentAuthorUID) { userProfile in
                dispatchGroup.leave()
                guard let userProfile = userProfile else { fatalError("userProfile read from comment is nil") }
                userComments.append((comment, userProfile))
            }
        }
        print("waiting for dispatch group")
        dispatchGroup.wait()
        print("dispatch group done")
        return userComments
    }
}

// MARK: Button functions
extension ShowCommentsViewController {
    @objc private func didTapBackButton(_ sender: UIButton) {
        print("Tapped back button")
        navigationController?.popViewController(animated: true)
    }

    @objc private func didTapAddCommentButton(_ sender: UIButton) {
        print("Tapped add comment button")

    }
}

// MARK: Collection view
extension ShowCommentsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TODO: Change later to always return 1, check if it still works
        return dataSource.isEmpty ? 0 : 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Cells.commentsCell, for: indexPath) as! CommentCollectionViewCell
        let commentAndAuthor = dataSource[indexPath.section]
        cell.comment = commentAndAuthor.0
        cell.commentAuthor = commentAndAuthor.1
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let (comment, userProfile) = dataSource[indexPath.row]
        let sizingCell = CommentCollectionViewCell()
        sizingCell.comment = comment
        sizingCell.commentAuthor = userProfile
        let zeroHeightSize = CGSize(width: collectionView.frame.width - 10 - 10, height: 0)
        let size = sizingCell.contentView.systemLayoutSizeFitting(zeroHeightSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
        return size
    }
}

// MARK: Setup subviews
extension ShowCommentsViewController {
    private func setupSubviews() {
        guard let currentUser = UserService.currentUserProfile else { fatalError("User nil") }

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)

        titleLabel.text = "Comments"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        titleView.addSubview(titleLabel)

        backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(ShowCommentsViewController.didTapBackButton(_:)), for: .touchUpInside)
        titleView.addSubview(backButton)

        view.addSubview(titleView)

        topSeparatorView.backgroundColor = .gray
        view.addSubview(topSeparatorView)

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.refreshControl = refresher
        collectionView.register(CommentCollectionViewCell.self, forCellWithReuseIdentifier: Constants.Cells.commentsCell)
        view.addSubview(collectionView)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ShowCommentsViewController.dimViewTapped(sender:)))
        tapRecognizer.numberOfTapsRequired = 1
        dimView.addGestureRecognizer(tapRecognizer)

        dimView.backgroundColor = .gray
        dimView.alpha = 0.2
        dimView.isHidden = !postNewComment
        view.addSubview(dimView)

        bottomSeparatorView.backgroundColor = .gray
        commentView.addSubview(bottomSeparatorView)

        Util.roundedCorners(ofColor: .gray, element: commentTextField)
        commentTextField.placeholder = "add comment as \(currentUser.username)..."
        commentTextField.delegate = self
        commentView.addSubview(commentTextField)

        view.addSubview(commentView)

        view.backgroundColor = .white
    }

    private func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(10)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(50)
        }

        titleView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(100)
        }

        topSeparatorView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(titleView.snp.bottom)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(topSeparatorView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        dimView.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(collectionView.snp.bottom)
        }

        bottomSeparatorView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalToSuperview()
        }

        commentTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-15)
            make.top.equalTo(bottomSeparatorView.snp.bottom).offset(20)
        }

        commentView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(collectionView.snp.bottom)
            make.height.equalTo(75)
        }
    }
}

// MARK: Keyboard animations
extension ShowCommentsViewController {
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            let keyboardOffScreen: Bool = endFrameY >= UIScreen.main.bounds.size.height
            if keyboardOffScreen {
                commentView.snp.updateConstraints { make in
                    make.bottom.equalToSuperview()
                }
            } else {
                commentView.snp.updateConstraints { make in
                    make.bottom.equalToSuperview().offset(-(endFrame?.size.height ?? 0.0))
                }
            }
            let rawValue = Int(animationCurveRaw)
            let curveValue = UIViewAnimationCurve(rawValue: rawValue)
            // TODO: Why doesn't animating dim view out work?
            UIViewPropertyAnimator(duration: duration, curve: curveValue!) {
                self.dimView.isHidden = keyboardOffScreen ? true : false
                self.dimView.alpha = self.dimView.isHidden ? 0.0 : 0.5
                print("self.dimView.alpha: \(self.dimView.alpha)")
                self.view.layoutIfNeeded()
            }.startAnimation()
        }
    }
}

// MARK: Text field delegate
extension ShowCommentsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("text field should return called")
        textField.resignFirstResponder()

        // post comment
        let commentText = textField.text!
        if commentText.isEmpty {
            // TODO: Post alert about not posting empty comments maybe
        } else {
            CommentService.postComment(text: commentText, eventPostID: eventPostID) { success in
                if success {
                    print("Comment posted successfully")
                    // update view so user can see newly posted comment
                    self.observeEventComments()
                } else {
                    print("Error posting comment")
                }
            }
        }
        textField.text = ""
        return false
    }
}

// MARK: Gesture recognizer for dim view
extension ShowCommentsViewController {
    @objc private func dimViewTapped(sender: UITapGestureRecognizer?) {
        commentTextField.resignFirstResponder()
    }
}
