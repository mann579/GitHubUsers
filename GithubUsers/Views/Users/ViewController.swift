//
//  ViewController.swift
//  GithubUsers
//
//  Created by Manpreet on 04/07/2021.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    private let cellIdentifier = "UserCell"
    let tableView = UITableView()
    let usersData = UsersDataModel()
    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Github Users", comment: "")
        self.view.backgroundColor = .white
        self.tableView.dataSource = self
        self.tableView.delegate = self
        tableView.accessibilityIdentifier = "UsersViewTable"
        tableView.separatorColor = UIColor.systemGray
        tableView.estimatedRowHeight = 108.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorInset = .zero
        tableView.showsVerticalScrollIndicator = false
        tableView.insetsContentViewsToSafeArea = true
        self.tableView.register(UserTableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.attributedTitle = NSAttributedString(string: NSLocalizedString("Fetching Users...", comment: ""))
        self.tableView.refreshControl?.addTarget(self, action: #selector(loadUsers), for: .valueChanged)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        loadUsers()
    }
    
    @objc func refreshUsers() {
        users = []
        loadUsers()
    }
    @objc func loadUsers() {
        tableView.refreshControl?.beginRefreshing()
        usersData.load(since: 0)
        usersData.loaded = { [weak self] users in
            self?.users.append(contentsOf: users)
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.tableView.refreshControl?.endRefreshing()
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if users.count == 0 {
            self.tableView.setEmptyMessage(NSLocalizedString("Users will be shown here soon.", comment: ""))
        } else {
            self.tableView.restore()
        }
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: self.cellIdentifier,
            for: indexPath
        ) as? UserTableViewCell else {
            return UITableViewCell()
        }
        let user = users[indexPath.row]
        cell.configureWith(user)
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedUser = self.users[indexPath.row]
        let repoController = RepoViewController()
        repoController.user = selectedUser
        self.navigationController?.pushViewController(repoController, animated: true)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // pull-up
        if (tableView.contentOffset.y + tableView.frame.size.height) >= tableView.contentSize.height {
             DispatchQueue.main.async {
                if self.users.count % 10 == 0 {
                    self.usersData.loadNext(since: self.users.last?.id ?? 0)
                }
             }
        }
    }
}
