//
//  CollectionViewController.swift
//  Vro
//
//  Created by Lucas Wotton on 6/25/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

class CommentCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: Setup subviews
extension CommentCollectionViewController {
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
            // TODO: Fix!
            // https://stackoverflow.com/questions/20884381/tableview-showing-behind-tab-bar
            make.bottom.equalToSuperview().offset(-(tabBarController?.tabBar.frame.height ?? 0))
            make.top.equalTo(collectionView.snp.bottom)
            make.height.equalTo(75)
        }
    }
}
