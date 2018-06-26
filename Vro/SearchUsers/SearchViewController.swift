//
//  Search'ViewController.swift
//  Vro
//
//  Created by Lucas Wotton on 6/12/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//
// Implementation based off of https://cocoacasts.com/managing-view-controllers-with-container-view-controllers/

import UIKit

class SearchViewController: UIViewController {
    
    private let tabbar = UISegmentedControl()
    private lazy var searchUsersViewController: SearchUsersViewController = {
        let viewController = SearchUsersViewController()
        self.add(asChildViewController: viewController)
        return viewController
    }()
    private lazy var searchEventsViewController: MapViewController = {
        let viewController = MapViewController()
        self.add(asChildViewController: viewController)
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupLayout()
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        addChildViewController(viewController)
        view.addSubview(viewController.view)
        viewController.view.snp.makeConstraints { make in
            make.top.equalTo(tabbar.snp.bottom).offset(1)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        viewController.didMove(toParentViewController: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
}


// MARK: Setup subviews
extension SearchViewController {
    private func setupSubviews() {
        tabbar.removeAllSegments()
        tabbar.insertSegment(withTitle: "Users", at: 0, animated: false)
        tabbar.insertSegment(withTitle: "Events", at: 1, animated: false)
        tabbar.addTarget(self, action: #selector(self.tabDidChange(_:)), for: .valueChanged)
        tabbar.selectedSegmentIndex = 0
        view.addSubview(tabbar)
        // this statement instantiates searchUsersViewController, because it's lazy
        let _ = searchUsersViewController
        view.backgroundColor = .white
    }
    
    private func setupLayout() {
        tabbar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(30)
        }
    }
    
    @objc private func tabDidChange(_ sender: UISegmentedControl) {
        if tabbar.selectedSegmentIndex == 0 {
            remove(asChildViewController: searchEventsViewController)
            add(asChildViewController: searchUsersViewController)
        } else {
            remove(asChildViewController: searchUsersViewController)
            add(asChildViewController: searchEventsViewController)
        }
    }
}
