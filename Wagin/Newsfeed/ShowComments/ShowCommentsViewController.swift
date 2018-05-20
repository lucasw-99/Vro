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

    private let titleLabel = UILabel()

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: Populate DataSource
extension ShowCommentsViewController: UICollectionViewDataSource {
    @objc private func observeEventComments() {

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
        titleLabel.text = "Comments"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        view.addSubview(titleLabel)

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.refreshControl = refresher
        collectionView.register(CommentCollectionViewCell.self, forCellWithReuseIdentifier: Constants.Cells.commentsCell)
        view.addSubview(collectionView)

        view.backgroundColor = .white
    }

    private func setupLayout() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(100)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
