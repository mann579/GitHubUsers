//
//  URL+URLQueryItems.swift
//  GithubUsers
//
//  Created by Manpreet on 05/07/2021.
//

import Foundation

extension URL {
    func appending(_ queryItems: [URLQueryItem]) -> URL? {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return nil
        }
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + queryItems

        return urlComponents.url
    }
}
