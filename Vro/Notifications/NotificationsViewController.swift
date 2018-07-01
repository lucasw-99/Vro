//
//  NotificationsViewController.swift
//  Vro
//
//  Created by Lucas Wotton on 6/28/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import FirebaseDatabase

class NotificationsViewController: UIViewController {
    private let notificationsLabel = UILabel()
    private let headerView = UIView()
    private let separatorView = UIView()
    private let dataSource = [Notification]()
    
    private let newNotificationsRef: DatabaseReference = {
        guard let currentUid = UserService.currentUserProfile?.uid else { fatalError("Current user nil") }
        let newNotificationsPath = String(format: Constants.Database.notifications, currentUid)
        return Database.database().reference().child(newNotificationsPath)
    }()

    private let notificationsCollectionView: UICollectionView = {
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
        refreshControl.addTarget(self, action: #selector(NotificationsViewController.observeNotifications), for: .valueChanged)
        return refreshControl
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        showNewNotifications()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupLayout()
    }
    
    deinit {
        print("notificationsViewController deinit called")
        // remove new notification observer
        newNotificationsRef.removeAllObservers()
    }
}

// MARK: Setup subviews
extension NotificationsViewController {
    private func setupSubviews() {
        notificationsLabel.text = "Notifications"
        notificationsLabel.textAlignment = .center
        notificationsLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        notificationsLabel.numberOfLines = 1
        headerView.addSubview(notificationsLabel)
        
        view.addSubview(headerView)
        
        separatorView.backgroundColor = .gray
        view.addSubview(separatorView)
        
        notificationsCollectionView.delegate = self
        notificationsCollectionView.dataSource = self
        notificationsCollectionView.refreshControl = refresher
        view.addSubview(notificationsCollectionView)
        
        view.backgroundColor = .white
    }
    
    private func setupLayout() {
        notificationsLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        headerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
        }
        
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(1)
        }
        
        notificationsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

// MARK: Collection view
extension NotificationsViewController: UICollectionViewDelegate {
    
}

// MARK: Data source
extension NotificationsViewController: UICollectionViewDataSource {
    private func showNewNotifications() {
        newNotificationsRef.observe(.childAdded) { snapshot in
            print("new snapshots: \(snapshot)")
        }
        
        newNotificationsRef.observe(.childRemoved) { snapshot in
            print("snapshot from child removed: \(snapshot)")
        }
    }
    
    @objc private func observeNotifications() {
        // Do UI updating on main thread
        DispatchQueue.main.async {
            self.notificationsCollectionView.reloadData()
            // stop refresher from spinning, but not too quickly
            if self.refresher.isRefreshing {
                let deadline = DispatchTime.now() + .milliseconds(700)
                DispatchQueue.main.asyncAfter(deadline: deadline) {
                    self.refresher.endRefreshing()
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell.init()
    }
}
