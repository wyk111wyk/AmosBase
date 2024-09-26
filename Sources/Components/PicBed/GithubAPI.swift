//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/5/14.
//

import Foundation

public class GithubAPI {
    var authentication: GithubAuth?
    var session: URLSession
    
    public init(authentication: GithubAuth? = nil) {
        self.authentication = authentication
        self.session = URLSession(configuration: URLSessionConfiguration.default)
    }
    
    func fullUrl(_ path: String) -> String {
        let baseUrl = "https://api.github.com"
        let final = baseUrl + path
        debugPrint("URL: \(final)")
        return final
    }
    
    var headers: [String: String] {
        var h = ["Accept": "application/vnd.github+json",
                 "X-GitHub-Api-Version": "2022-11-28"]
        if let authentication {
            h[authentication.key] = authentication.value
        }
        debugPrint("Headers")
        debugPrint(h)
        return h
    }
}

public typealias BaseAPICompletion = (Data?, URLResponse?, Error?) -> Swift.Void
// Get
extension GithubAPI {
    public func gh_get<T: Codable>(
        path: String,
        parameters: [String : String]? = nil) async throws -> T?
    {
        let result = try await SimpleWeb().request(
            method: .GET,
            url: fullUrl(path),
            parameters: parameters
        )
        
        if let httpResponse = result.response as? HTTPURLResponse {
            // 获取状态码
            let statusCode = httpResponse.statusCode
            debugPrint("GET HTTP 状态码: \(statusCode)")
            
            if statusCode == 200,
               let model = result.data?.decode(type: T.self) {
                return model
            }else {
                let error = GithubError.error(from: statusCode)
                throw error
            }
        }
        
        return nil
    }
    
    // Put
    public func gh_put(path: String, parameters: [String : String]? = nil, body: Data?) async throws -> Data? {
        let result = try await SimpleWeb().request(
            method: .PUT,
            url: fullUrl(path),
            parameters: parameters,
            body: body
        )
        
        if let httpResponse = result.response as? HTTPURLResponse {
            // 获取状态码
            let statusCode = httpResponse.statusCode
            debugPrint("PUT HTTP 状态码: \(statusCode)")
            
            if statusCode == 200 || statusCode == 201 {
                return result.data
            }else {
                let error = GithubError.error(from: statusCode)
                throw error
            }
        }
        
        return nil
    }
    
    // Delete
    public func delete(path: String, parameters: [String : String]? = nil, body: Data?) async throws -> Bool {
        let result = try await SimpleWeb().request(
            method: .DELETE,
            url: fullUrl(path),
            parameters: parameters,
            headers: headers,
            body: body
        )
        
        if let httpResponse = result.response as? HTTPURLResponse {
            // 获取状态码
            let statusCode = httpResponse.statusCode
            debugPrint("DELETE HTTP 状态码: \(statusCode)")
            
            if statusCode == 200 || statusCode == 201 {
                return true
            }else {
                let error = GithubError.error(from: statusCode)
                throw error
            }
        }
        
        return false
    }
}
