//
//  Constants.swift
//  GithubUsers
//
//  Created by Manpreet on 05/07/2021.
//

import Foundation
import UIKit

struct endpoints {
    static let baseUrl = "https://api.github.com/"
    static let users = "users"
    static let repos = "users/%d/repos"
}

struct Reference {
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    static let usersURL = Bundle.main.object(forInfoDictionaryKey: "UsersURL") as! String
}

extension Notification.Name {
    static var networkConnectionChanged: Notification.Name {
        return .init(rawValue: "NetworkMonitor.connectionChanged")
    }
}

