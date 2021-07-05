//
//  RepoTableViewCell.swift
//  GithubUsers
//
//  Created by Manpreet on 05/07/2021.
//

import UIKit
import Foundation
import Combine

class RepoTableViewCell: UITableViewCell {

    var tableViewHeight: CGFloat = 66.0
    
    private let titleLbl: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let createdLbl: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private let updatedLbl: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryType = .disclosureIndicator
        backgroundColor = UIColor.systemBackground
        contentView.addSubview(titleLbl)
        self.titleLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(createdLbl)
        self.createdLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(updatedLbl)
        self.updatedLbl.translatesAutoresizingMaskIntoConstraints = false
        addConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addConstraints() {

        titleLbl.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
        }
        createdLbl.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(titleLbl.snp.bottom).offset(8)
        }
        
        updatedLbl.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(createdLbl.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    public func configureWith(_ repo: Repo, formatter: DateFormatter) {
        titleLbl.text = repo.fullName
        createdLbl.text = NSLocalizedString("Created:", comment: "")
            + " "
            + formatter.string(from: repo.createdDate ?? Date())
        updatedLbl.text = NSLocalizedString("Updated:", comment: "")
            + " "
            + formatter.string(from: repo.updatedDate ?? Date())
    }
}
