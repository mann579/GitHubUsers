//
//  RepoViewController.swift
//  GithubUsers
//
//  Created by Manpreet on 05/07/2021.
//

import Foundation
import UIKit
import SnapKit

class RepoViewController: UIViewController {

    private let cellIdentifier = "RepoCell"
    let tableView = UITableView()
    let reposData = ReposDataModel()
    var user: User?
    var repos: [Repo] = []
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = user?.login ?? "User"
        formatter.dateFormat = "dd MMM yy"
        self.view.backgroundColor = .white
        self.tableView.dataSource = self
        self.tableView.delegate = self
        tableView.accessibilityIdentifier = "RepoViewTable"
        tableView.separatorColor = UIColor.systemGray
        tableView.estimatedRowHeight = 108.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorInset = .zero
        tableView.showsVerticalScrollIndicator = false
        tableView.insetsContentViewsToSafeArea = true
        self.tableView.register(RepoTableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.attributedTitle = NSAttributedString(string: NSLocalizedString("Fetching repos...", comment: ""))
        self.tableView.refreshControl?.addTarget(self, action: #selector(loadRepos), for: .valueChanged)
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        loadRepos()
    }
    
    @objc func refreshRepos() {
        repos = []
        loadRepos()
    }
    @objc func loadRepos() {
        tableView.refreshControl?.beginRefreshing()
        reposData.load(userId: Int(user?.id ?? 0))
        reposData.loaded = { [weak self] users in
            self?.repos.append(contentsOf: users)
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.tableView.refreshControl?.endRefreshing()
            }
        }
    }
}

extension RepoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if repos.count == 0 {
            self.tableView.setEmptyMessage(NSLocalizedString("Repos will be shown here soon.", comment: ""))
        } else {
            self.tableView.restore()
        }
        return repos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: self.cellIdentifier,
            for: indexPath
        ) as? RepoTableViewCell else {
            return UITableViewCell()
        }
        let repo = repos[indexPath.row]
        cell.configureWith(repo, formatter: formatter)
        return cell
    }
}

extension RepoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let url = URL(string: self.repos[indexPath.row].repoUrl ?? "") {
            UIApplication.shared.open(url)
        }
    }
}
