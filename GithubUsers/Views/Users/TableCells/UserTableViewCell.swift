//
//  UserTableViewCell.swift
//  GithubUsers
//
//  Created by Manpreet on 05/07/2021.
//

import UIKit
import Foundation
import Combine

class UserTableViewCell: UITableViewCell {

    private var cancellable: AnyCancellable?
    fileprivate let activityView: UIActivityIndicatorView = .init(style: .large)
    var tableViewHeight: CGFloat = 66.0
    private let imageVw: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    private let titleLbl: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let nameLbl: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryType = .disclosureIndicator
        backgroundColor = UIColor.systemBackground
        activityView.color = UIColor.init(white: 1, alpha: 1)
        contentView.addSubview(imageVw)
        imageVw.addSubview(activityView)
        activityView.hidesWhenStopped = true
        self.imageVw.translatesAutoresizingMaskIntoConstraints = false
        self.imageVw.clipsToBounds = true
        self.imageVw.layer.cornerRadius = 10
        imageVw.snp.makeConstraints({ make in
            make.height.equalTo(50).multipliedBy(1)
            make.width.equalTo(50).multipliedBy(1)
        })
        activityView.center = CGPoint(x: imageVw.center.x + 25,
                                      y: imageVw.center.y + 25)
        contentView.addSubview(titleLbl)
        self.titleLbl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLbl)
        self.nameLbl.translatesAutoresizingMaskIntoConstraints = false
        addConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addConstraints() {
        imageVw.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(8)
        }
        titleLbl.snp.makeConstraints { make in
            make.left.equalTo(imageVw.snp.right).offset(8)
            make.top.equalTo(imageVw.snp.top)
        }
        nameLbl.snp.makeConstraints { make in
            make.left.equalTo(imageVw.snp.right).offset(8)
            make.top.equalTo(titleLbl.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    public func configureWith(_ user: User) {
        imageVw.image = UIImage(named: "No-album-art")
        titleLbl.text = user.login
        nameLbl.text = user.reposUrl
        cancellable = loadImage(for: user).sink { [unowned self] image in
            activityView.stopAnimating()
            imageVw.image = image
        }
    }
    
    func loadImage(for user: User) -> AnyPublisher<UIImage?, Never> {
       return Just(user.avatarUrl)
           .flatMap({ poster -> AnyPublisher<UIImage?, Never> in
               let url = URL(string: user.avatarUrl ?? "")!
               return ImageLoader.shared.loadImage(from: url)
           })
           .eraseToAnyPublisher()
   }
}
