//
//  RepoData.swift
//  GithubUsers
//
//  Created by Manpreet on 05/07/2021.
//

import Foundation

class ReposDataModel {
    private(set) var repos: [Repo]?
    private lazy var networkManager = NetworkManager()
    var loaded: ((_: [Repo]) -> Void)?
    
    func load(userId: Int) {
        if NetworkMonitor().isConnectedToNetwork() {
            networkManager.getRepos(userId: userId) { reposResponse, error in
                guard let repos = reposResponse else { return }
                self.repos = repos
                self.loaded?(self.repos ?? [])
            }
        }
    }
}

public enum ReposApi:EndPoint, CaseIterable {
    
    public static var allCases: [ReposApi] {
        return [.user(0)]
    }
    case user(_ userId: Int)
}

extension ReposApi {
    
    var baseURL: URL {
        guard let url = URL(string: endpoints.baseUrl) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .user(let userId):
            return String(format: endpoints.repos, userId)
        }
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var query: [URLQueryItem] {
        switch self {
        case .user(_):
            return []
        }
    }
}

