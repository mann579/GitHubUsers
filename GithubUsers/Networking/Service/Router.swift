//
//  Router.swift
//  GithubUsers
//
//  Created by Manpreet on 05/07/2021.
//

import Foundation

public enum HTTPMethod : String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
}

protocol EndPoint {
    var baseURL: URL { get }
    var path: String { get }
    var query: [URLQueryItem] { get }
    var httpMethod: HTTPMethod { get }
}

public typealias HTTPCallerCompletion = (_ data: Data?,_ response: URLResponse?,_ error: Error?)->()

protocol HTTPCaller {
    associatedtype EndPointObj: EndPoint
    func request(_ route: EndPointObj, completion: @escaping HTTPCallerCompletion)
    func cancel()
}

class Router<EndPointObj: EndPoint>: HTTPCaller {
    private var task: URLSessionTask?
    
    func request(_ route: EndPointObj, completion: @escaping HTTPCallerCompletion) {
        let session = URLSession.shared
        do {
            let request = try self.buildRequest(from: route)
            task = session.dataTask(with: request, completionHandler: { data, response, error in
                completion(data, response, error)
            })
        }catch {
            completion(nil, nil, error)
        }
        self.task?.resume()
    }
    
    func cancel() {
        self.task?.cancel()
    }
    
    fileprivate func buildRequest(from route: EndPoint) throws -> URLRequest {
        var url = route.baseURL.appendingPathComponent(route.path)
        if (!route.query.isEmpty) {
            url = url.appending(route.query) ?? url
        }
        print(url)
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 10.0)
        
        request.httpMethod = route.httpMethod.rawValue
        return request
    }
}
