//
//  User.swift
//  GithubUsers
//
//  Created by Manpreet on 05/07/2021.
//

import Foundation

struct User : Codable {
    let login : String?
    let id : Int32?
    let avatarUrl : String?
    let reposUrl : String?

    enum CodingKeys: String, CodingKey {

        case login = "login"
        case id = "id"
        case avatarUrl = "avatar_url"
        case reposUrl = "repos_url"
    }
    
    init(from decoder: Decoder) throws {
        let keyedValues = try decoder.container(keyedBy: CodingKeys.self)
        
        self.login = try keyedValues.decodeIfPresent(String.self, forKey: .login)
        self.id = try keyedValues.decodeIfPresent(Int32.self, forKey: .id)
        self.avatarUrl = try keyedValues.decodeIfPresent(String.self, forKey: .avatarUrl)
        self.reposUrl = try keyedValues.decodeIfPresent(String.self, forKey: .reposUrl)
    }
    
    init(login: String?, id: Int32?, avatarUrl: String?, reposUrl: String?) {
        self.login = login
        self.id = id
        self.avatarUrl = avatarUrl
        self.reposUrl = reposUrl
    }
}
