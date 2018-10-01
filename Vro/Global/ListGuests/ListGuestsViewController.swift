//
//  ListGuestsViewController.swift
//  Vro
//
//  Created by Lucas Wotton on 7/9/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

class ListGuestsViewController: UIViewController {
    private let backButton = UIButton()
    private let eventGuestsLabel = UILabel()
    private let headerView = UIView()
    private let separatorView = UIView()
    private let guestsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        return cv
    }()
    
    private var dataSource = [Attendee]()
    
    init(eventPostId: String) {
        super.init(nibName: nil, bundle: nil)
        let postGuestsPath = String(format: Constants.Database.eventPotentialGuests, eventPostId)
//        let postLikesRef = Database.database().reference().child(postGuestsPath)
        
//        postLikesRef.observeSingleEvent(of: .value) { snapshot in
//            for childSnapshot in snapshot.children {
//                guard let childSnapshot = childSnapshot as? DataSnapshot else { fatalError("Didn't expect this") }
//                let guest = Attendee(forSnapshot: childSnapshot)
//                self.dataSource.append(guest)
//            }
//            self.guestsCollectionView.reloadData()
//        }
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
extension ListGuestsViewController {
    @objc private func didTapBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: Setup subviews
extension ListGuestsViewController {
    private func setupSubviews() {
        backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(ListGuestsViewController.didTapBackButton(_:)), for: .touchUpInside)
        headerView.addSubview(backButton)
        
        // TODO: Make it potential vs actual depending on if event has already happened?
        eventGuestsLabel.text = "Potential Event Guests"
        eventGuestsLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        eventGuestsLabel.textAlignment = .center
        headerView.addSubview(eventGuestsLabel)
        
        view.addSubview(headerView)
        
        separatorView.backgroundColor = .gray
        view.addSubview(separatorView)
        
        guestsCollectionView.delegate = self
        guestsCollectionView.dataSource = self
        guestsCollectionView.register(GuestCollectionViewCell.self, forCellWithReuseIdentifier: "GuestCell")
        view.addSubview(guestsCollectionView)
        
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
        
        eventGuestsLabel.snp.makeConstraints { make in
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
        
        guestsCollectionView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

// MARK: Collection view
extension ListGuestsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TODO: Change later to always return 1, check if it still works
        return dataSource.isEmpty ? 0 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = guestsCollectionView.dequeueReusableCell(withReuseIdentifier: "GuestCell", for: indexPath) as! GuestCollectionViewCell
        let guest = dataSource[indexPath.section]
        cell.guest = guest
        return cell
    }
}

// MARK: Collection view flow layout
extension ListGuestsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 10, right: 5)
    }
}
