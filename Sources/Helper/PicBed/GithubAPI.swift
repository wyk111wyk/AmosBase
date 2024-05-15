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
    
    var defaultHeaders = [
        "Accept" : "application/vnd.github.v3+json",
        RequestHeaderFields.acceptEncoding.rawValue : "gzip",
        "Content-Type" : "application/json; charset=utf-8"
    ]
    
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
        return try await withCheckedThrowingContinuation({ contionuation in
            self.get(
                url: fullUrl(path),
                parameters: parameters
            ) {(data, response, error) in
                if let error {
                    contionuation.resume(throwing: error)
                }else {
                    if let httpResponse = response as? HTTPURLResponse {
                        // 获取状态码
                        let statusCode = httpResponse.statusCode
                        debugPrint("HTTP 状态码: \(statusCode)")
                        
                        if statusCode == 200,
                           let model = data?.decode(type: T.self) {
                            contionuation.resume(returning: model)
                        }else {
                            let error = SimpleError.customError(msg: "错误码：\(statusCode)")
                            contionuation.resume(throwing: error)
                        }
                    }
                }
            }
        })
    }
    
    private func get(
        url: String,
        parameters: [String: String]? = nil,
        body: Data? = nil,
        callbackQueue: DispatchQueue = .main,
        completion: @escaping BaseAPICompletion
    ) {
        let request = BaseRequest(
            url: url,
            method: .GET,
            parameters: parameters,
            headers: headers,
            body: body
        )
        let buildRequest = request.request()
        if let urlRequest = buildRequest.request {
            let task = session.dataTask(with: urlRequest) { (data, response, error) in
                callbackQueue.async { completion(data, response, error) }
            }
            task.resume()
        } else {
            callbackQueue.async { completion(nil, nil, buildRequest.error) }
        }
    }
}

// Put
extension GithubAPI {
    public func gh_put(path: String, parameters: [String : String]? = nil, body: Data?) async throws -> Data? {
        return try await withCheckedThrowingContinuation({ contionuation in
            self.put(
                url: fullUrl(path),
                parameters: parameters,
                body: body
            ) {(data, response, error) in
                if let error {
                    contionuation.resume(throwing: error)
                }else {
                    if let httpResponse = response as? HTTPURLResponse {
                        // 获取状态码
                        let statusCode = httpResponse.statusCode
                        debugPrint("HTTP 状态码: \(statusCode)")
                        
                        if statusCode == 200 || statusCode == 201 {
                            contionuation.resume(returning: data)
                        }else {
                            let error = SimpleError.customError(msg: "错误码：\(statusCode)")
                            contionuation.resume(throwing: error)
                        }
                    }
                }
            }
        })
    }
    
    private func put(url: String, parameters: [String: String]? = nil, body: Data?, callbackQueue: DispatchQueue = .main, completion: @escaping BaseAPICompletion) {
        let request = BaseRequest(
            url: url,
            method: .PUT,
            parameters: parameters,
            headers: headers,
            body: body
        )
        let buildRequest = request.request()
        if let urlRequest = buildRequest.request {
            let task = session.dataTask(with: urlRequest) { (data, response, error) in
                callbackQueue.async { completion(data, response, error) }
            }
            task.resume()
        } else {
            callbackQueue.async { completion(nil, nil, buildRequest.error) }
        }
    }
}

// Delete
extension GithubAPI {
    public func delete(path: String, parameters: [String : String]? = nil, body: Data?) async throws -> Bool {
        return try await withCheckedThrowingContinuation({ contionuation in
            self.delete(
                url: fullUrl(path),
                parameters: parameters,
                headers: headers,
                body: body
            ) {(data, response, error) in
                if let error {
                    contionuation.resume(throwing: error)
                }else {
                    if let httpResponse = response as? HTTPURLResponse {
                        // 获取状态码
                        let statusCode = httpResponse.statusCode
                        debugPrint("HTTP 状态码: \(statusCode)")
                        
                        if statusCode == 200 {
                            contionuation.resume(returning: true)
                        }else {
                            let error = SimpleError.customError(msg: "错误码：\(statusCode)")
                            contionuation.resume(throwing: error)
                        }
                    }else {
                        contionuation.resume(returning: false)
                    }
                }
            }
        })
    }
    
    private func delete(url: String, parameters: [String: String]? = nil, headers: [String: String]? = nil, body: Data?, callbackQueue: DispatchQueue = .main, completion: @escaping BaseAPICompletion) {
        let request = BaseRequest(
            url: url,
            method: .DELETE,
            parameters: parameters,
            headers: headers,
            body: body
        )
        let buildRequest = request.request()
        if let urlRequest = buildRequest.request {
            let task = session.dataTask(with: urlRequest) { (data, response, error) in
                callbackQueue.async { completion(data, response, error) }
            }
            task.resume()
        } else {
            callbackQueue.async { completion(nil, nil, buildRequest.error) }
        }
    }
}

extension GithubAPI {
    public static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
            if let date = formatter.date(from: dateStr) {
                return date
            }
            throw DecodingError.typeMismatch(Date.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not decode date"))
        })
        return decoder
    }
    
    public static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        encoder.dateEncodingStrategy = .formatted(formatter)
        return encoder
    }
}
