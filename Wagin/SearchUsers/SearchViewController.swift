//
//  Search'ViewController.swift
//  Wagin
//
//  Created by Lucas Wotton on 6/12/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit
import Segmentio

class SearchViewController: UIViewController {
    
    let tabbar: Segmentio = Segmentio()
    let viewControllers = [SearchUsersViewController(), MapViewController()]
    var currentView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupLayout()
    }
}


// MARK: Setup subviews
extension SearchViewController {
    private func setupSubviews() {
        var content = [SegmentioItem]()
        let searchUsers = SegmentioItem(title: "Users", image: #imageLiteral(resourceName: "user"))
        let searchEvents = SegmentioItem(title: "Events", image: #imageLiteral(resourceName: "defaultEvent"))
        content.append(searchUsers)
        content.append(searchEvents)
        let defaultState = SegmentioState(backgroundColor: .white,
                                   titleFont: .systemFont(ofSize: 28, weight: .semibold),
                                   titleTextColor: .black)
        let selectedState = SegmentioState(backgroundColor: .lightGray,
                                           titleFont: .systemFont(ofSize: 28, weight: .semibold),
                                           titleTextColor: .black)
        let highlightedState = selectedState
        
        tabbar.setup(content: content, style: .onlyLabel, options: nil)
//
//        tabbar.setup(content: content, style: SegmentioStyle.onlyLabel, options: SegmentioOptions(backgroundColor: .white,
//                                                                                                  segmentPosition: .dynamic,
//                                                                                                  scrollEnabled: false,
//                                                                                                  indicatorOptions: nil,
//                                                                                                  horizontalSeparatorOptions: SegmentioHorizontalSeparatorOptions(type: .topAndBottom,
//                                                                                                                                                                  height: 1,
//                                                                                                                                                color: .black),
//                                                                                                  verticalSeparatorOptions: SegmentioVerticalSeparatorOptions(ratio: 1, color: .gray),
//                                                                                                  imageContentMode: .center,
//                                                                                                  labelTextAlignment: .center,
//                                                                                                  labelTextNumberOfLines: 0,
//                                                                                                  segmentStates: SegmentioStates(
//                                                                                                    defaultState: defaultState,
//                                                                                                    selectedState: selectedState,
//                                                                                                    highlightedState: highlightedState)))
        tabbar.selectedSegmentioIndex = 0
        tabbar.valueDidChange = { _, segmentioIndex in
            // TODO: Clean up logic that switches VC's?
            if segmentioIndex == 0 {
                print("Selected users view")
                let previousVC = self.viewControllers[1]
                let nextVC = self.viewControllers[0]
                self.removePreviousVC(previousVC: previousVC)
                self.view.addSubview(nextVC.view)
                self.currentView = nextVC.view
                self.currentViewConstraints()
                nextVC.didMove(toParentViewController: self)
            } else if segmentioIndex == 1 {
                print("Selected events view")
                let previousVC = self.viewControllers[0]
                let nextVC = self.viewControllers[1]
                self.removePreviousVC(previousVC: previousVC)
                self.view.addSubview(nextVC.view)
                self.currentView = nextVC.view
                self.currentViewConstraints()
                nextVC.didMove(toParentViewController: self)
            } else {
                fatalError("Invalid index")
            }
        }
        view.addSubview(tabbar)
        
        view.addSubview(viewControllers[0].view)
        currentView = viewControllers[0].view
        
        view.backgroundColor = .white
    }
    
    private func setupLayout() {
        tabbar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        
        currentViewConstraints()
    }
    
    private func removePreviousVC(previousVC: UIViewController) {
        previousVC.willMove(toParentViewController: nil)
        previousVC.view.removeFromSuperview()
        previousVC.removeFromParentViewController()
    }
    
    private func currentViewConstraints() {
        currentView?.snp.remakeConstraints { make in
            make.top.equalTo(tabbar.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
