//
//  UsersData.swift
//  GithubUsers
//
//  Created by Manpreet on 05/07/2021.
//

import Foundation

class UsersDataModel {
    private(set) var users: [User]?
    private lazy var networkManager = NetworkManager()
    private var pageSize: Int = 10
    private var since: Int32 = 0
    private var offset: Int = 0
    var loaded: ((_: [User]) -> Void)?
    
    func load(since: Int32 = 0) {
        self.since = since
        if NetworkMonitor().isConnectedToNetwork() {
            networkManager.getUsers(since: Int(since), pageSize: pageSize) { usersResponse, error in
                guard let users = usersResponse else { return }
                self.users = users
                for user in users {
                    DispatchQueue.main.async {
                        DatabaseManager.shared.userCreateOrUpdate(from: user)
                    }
                }
                let userIds = users.map({ $0.id ?? 0})
                DispatchQueue.main.async {
                    if let managedUsers = DatabaseManager.shared.getUsersByIds(userIds: userIds) as? [UserCD] {
                        print(managedUsers)
                        let dbUsers = managedUsers.map ({
                            user in User(login: user.login,
                                              id: user.id,
                                              avatarUrl: user.avatarUrl,
                                              reposUrl: user.reposUrl)
                        })
                        self.users = dbUsers
                    }
                }
                self.offset += self.pageSize
                
                self.loaded?(self.users ?? [])
            }
        } else {
            DatabaseManager.shared.getUsers(
                offset: self.offset,
                limit: pageSize,
                completion: { result in
                    switch result {
                    case .success(let managedUsers):
                        if let managedUsers = managedUsers as? [UserCD] {
                            let users = managedUsers.map(
                                { user in User(login: user.login,
                                               id: user.id,
                                               avatarUrl: user.avatarUrl,
                                               reposUrl: user.reposUrl)

                                })
                            self.offset += self.pageSize
                            print("initially \(self.offset) user(s) +++")
                            self.users = users
                            DispatchQueue.main.async {
                                self.loaded?(self.users ?? [])
                            }
                        }
                    case .failure(let error):
                        print(error.description)
                    }
                })
        }
        
    }
    
    func loadNext(since: Int32) {
        load(since: since)
    }
}

public enum UsersApi:EndPoint, CaseIterable {
    
    public static var allCases: [UsersApi] {
        return [.top(0, pageSize: 1)]
    }
    case top(_ since: Int, pageSize: Int)
}

extension UsersApi {
    
    var baseURL: URL {
        guard let url = URL(string: endpoints.baseUrl) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        return endpoints.users
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var query: [URLQueryItem] {
        switch self {
        case .top(let since, let pageSize):
            return [URLQueryItem(name: "since", value: String(since)), URLQueryItem(name: "per_page", value: String(pageSize))]
        }
    }
}

