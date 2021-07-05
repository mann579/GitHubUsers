//
//  Repo.swift
//  GithubUsers
//
//  Created by Manpreet on 05/07/2021.
//

import Foundation

struct Repo : Codable {

    let id: Int32?
    let fullName: String?
    let repoUrl: String?
    let createdDate: Date?
    let updatedDate: Date?


    enum CodingKeys: String, CodingKey {

        case id = "id"
        case fullName = "full_name"
        case repoUrl = "html_url"
        case createdDate = "created_at"
        case updatedDate = "updated_at"

    }
    
    init(from decoder: Decoder) throws {
        let keyedValues = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try keyedValues.decodeIfPresent(Int32.self, forKey: .id)
        self.fullName = try keyedValues.decodeIfPresent(String.self, forKey: .fullName)
        self.createdDate = try keyedValues.decodeIfPresent(Date.self, forKey: .createdDate)
        self.updatedDate = try keyedValues.decodeIfPresent(Date.self, forKey: .updatedDate)
        self.repoUrl = try keyedValues.decodeIfPresent(String.self, forKey: .repoUrl)
    }
}
