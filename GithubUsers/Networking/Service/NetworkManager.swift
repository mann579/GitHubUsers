//
//  NetworkManager.swift
//  GithubUsers
//
//  Created by Manpreet on 05/07/2021.
//

import Foundation

enum NetworkResponse:String {
    case noInternet
    case success
    case badRequest = "Bad request"
    case outdated = "The url you requested is no longer existing."
    case failed = "Network request failed. Please try again."
    case noData = "The response is empty from API."
    case unableToDecode = "Bad format of data."
}

enum Result<String>{
    case success
    case failure(String)
}

struct NetworkManager {
    let router = Router<UsersApi>()
    let repoRouter = Router<ReposApi>()
    
    func getUsers(since: Int, pageSize: Int, completion: @escaping (_ users: [User]?,_ error: String?)->()) {
        router.request(.top(since, pageSize: pageSize)) { data, response, error in
            
            if error != nil {
                completion(nil, error?.localizedDescription)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode([User].self, from: responseData)
                        completion(apiResponse,nil)
                    }catch {
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let failureError):
                    completion(nil, failureError)
                }
            }
        }
    }
    
    func getRepos(userId: Int, completion: @escaping (_ repos: [Repo]?,_ error: String?)->()) {
        repoRouter.request(.user(userId)) { data, response, error in
            
            if error != nil {
                completion(nil, error?.localizedDescription)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, NetworkResponse.noData.rawValue)
                        return
                    }
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        let apiResponse = try decoder.decode([Repo].self, from: responseData)
                        completion(apiResponse,nil)
                    }catch {
                        completion(nil, NetworkResponse.unableToDecode.rawValue)
                    }
                case .failure(let failureError):
                    completion(nil, failureError)
                }
            }
        }
    }
    
    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String>{
        switch response.statusCode {
        case 200...299: return .success
        case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
}
