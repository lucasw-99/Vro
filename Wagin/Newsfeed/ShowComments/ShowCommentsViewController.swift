//
//  ShowCommentsViewController.swift
//  Wagin
//
//  Created by Lucas Wotton on 5/20/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

class ShowCommentsViewController: UIViewController {
    private var dataSource = [Comment]()

    private let titleView = UIView()
    private let titleLabel = UILabel()
    private let backButton = UIButton()

    private let commentView = UIView()
    private let commentTextField = UITextField()

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


    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupLayout()
    }
}

// MARK: Populate DataSource
extension ShowCommentsViewController: UICollectionViewDataSource {
    @objc private func observeEventComments() {

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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventPostCell", for: indexPath) as! CommentCollectionViewCell
        let comment = dataSource[indexPath.section]
        cell.comment = comment
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
}

// MARK: Setup subviews
extension ShowCommentsViewController {
    private func setupSubviews() {
        guard let currentUser = UserService.currentUserProfile else { fatalError("User nil") }

        titleLabel.text = "Comments"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        titleView.addSubview(titleLabel)

        backButton.setImage(#imageLiteral(resourceName: "cancel"), for: .normal)
        backButton.addTarget(self, action: #selector(ShowCommentsViewController.didTapBackButton(_:)), for: .touchUpInside)
        titleView.addSubview(backButton)

        view.addSubview(titleView)

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.refreshControl = refresher
        collectionView.register(CommentCollectionViewCell.self, forCellWithReuseIdentifier: Constants.Cells.commentsCell)
        view.addSubview(collectionView)

        Util.roundedCorners(ofColor: .gray, element: commentTextField)
        commentTextField.placeholder = "add comment as \(currentUser.username)..."
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

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        commentTextField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 20, left: 10, bottom: 15, right: 10))
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
