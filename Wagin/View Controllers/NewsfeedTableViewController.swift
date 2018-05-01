//
//  NewsfeedTableViewController.swift
//  Wagin
//
//  Created by Lucas Wotton on 4/30/18.
//  Copyright © 2018 Lucas Wotton. All rights reserved.
//

import UIKit

class NewsfeedTableViewController: UITableViewController {

    var posts: [Post]?

    struct Storyboard {
        static let postCell = "PostCell"
        static let postHeaderCell = "PostHeaderCell"
        static let postHeaderHeight: CGFloat = 57.0
        static let postCellDefaultHeight: CGFloat = 610
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchPosts()

        tableView.rowHeight = Storyboard.postCellDefaultHeight
        tableView.separatorColor = UIColor.clear
    }

    private func fetchPosts() {
        posts = Post.fetchPosts()
        tableView.reloadData()
    }
}

extension NewsfeedTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let posts = posts {
            return posts.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if posts != nil {
            return 1
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.postCell, for: indexPath) as! PostTableViewCell
        cell.post = posts?[indexPath.section]
        cell.selectionStyle = .none

        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.postHeaderCell) as! PostHeaderTableViewCell

        cell.post = self.posts?[section]
        cell.backgroundColor = UIColor.white

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Storyboard.postHeaderHeight
    }
}
