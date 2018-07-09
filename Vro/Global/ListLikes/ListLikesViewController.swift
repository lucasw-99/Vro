//
//  ListLikesViewController.swift
//  Vro
//
//  Created by Lucas Wotton on 7/7/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ListLikesViewController: UIViewController {
    private let backButton = UIButton()
    private let eventLikesLabel = UILabel()
    private let headerView = UIView()
    private let separatorView = UIView()
    private let likesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        return cv
    }()
    
    private var dataSource = [Like]()
    
    init(postedByUid: String, eventPostId: String) {
        super.init(nibName: nil, bundle: nil)
        let postLikesPath = String(format: Constants.Database.postLikes, postedByUid, eventPostId)
        let postLikesRef = Database.database().reference().child(postLikesPath)
        
        postLikesRef.observeSingleEvent(of: .value) { snapshot in
            for childSnapshot in snapshot.children {
                guard let childSnapshot = childSnapshot as? DataSnapshot else { fatalError("Didn't expect this") }
                let like = Like(forSnapshot: childSnapshot)
                self.dataSource.append(like)
            }
            self.likesCollectionView.reloadData()
        }
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

// MARK: Button functions
extension ListLikesViewController {
    @objc private func didTapBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: Setup subviews
extension ListLikesViewController {
    private func setupSubviews() {
        backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(ListLikesViewController.didTapBackButton(_:)), for: .touchUpInside)
        headerView.addSubview(backButton)
        
        eventLikesLabel.text = "Event Likes"
        eventLikesLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        eventLikesLabel.textAlignment = .center
        headerView.addSubview(eventLikesLabel)
    
        view.addSubview(headerView)
        
        separatorView.backgroundColor = .gray
        view.addSubview(separatorView)
        
        likesCollectionView.delegate = self
        likesCollectionView.dataSource = self
        likesCollectionView.register(LikeCollectionViewCell.self, forCellWithReuseIdentifier: "LikeCell")
        view.addSubview(likesCollectionView)
        
        view.backgroundColor = .white
    }
    
    private func setupLayout() {
        headerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
        }
        
        backButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.leading.equalToSuperview().offset(15)
        }
        
        eventLikesLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(1)
        }
        
        likesCollectionView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

// MARK: Collection view
extension ListLikesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TODO: Change later to always return 1, check if it still works
        return dataSource.isEmpty ? 0 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = likesCollectionView.dequeueReusableCell(withReuseIdentifier: "LikeCell", for: indexPath) as! LikeCollectionViewCell
        let like = dataSource[indexPath.section]
        cell.like = like
        return cell
    }
}

// MARK: Collection view flow layout
extension ListLikesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 10, right: 5)
    }
}
