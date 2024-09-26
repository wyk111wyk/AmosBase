//
//  File.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/9/25.
//

import Foundation

internal class SimpleWebRequest {
    
    public let url: URLConvertible
    public let method: SimpleRequestMethod
    public let parameters: [String : String]?
    public let headers: [String : String]?
    public let body: Data?
    
    public init(
        url: URLConvertible,
        method: SimpleRequestMethod,
        parameters: [String : String]? = nil,
        headers: [String : String]? = nil,
        body: Data? = nil
    ) {
        self.url = url
        self.method = method
        self.parameters = parameters
        self.headers = headers
        self.body = body
    }
    
    public func request() throws -> URLRequest? {
        let stringUrl = self.urlWithParameters()
        if let encodedUrlString = stringUrl.addingPercentEncoding(
            withAllowedCharacters: .urlFragmentAllowed
        ), let url = URL(string: encodedUrlString) {
            debugPrint("进行网络请求的url：\(encodedUrlString)")
            var request = URLRequest(url: url)
            if let headers = headers {
                for (key, value) in headers {
                    request.addValue(value, forHTTPHeaderField: key)
                }
            }
            request.httpMethod = method.rawValue
            request.httpBody = body
            return request
        } else {
            throw NSError(
                domain:"Unable to create URL from string \(stringUrl)",
                code:9999,
                userInfo:nil
            )
        }
    }
    
    private func urlWithParameters() -> String {
        var retUrl = url.urlString
        if let parameters = parameters {
            if parameters.count > 0 {
                retUrl.append("?")
                parameters.keys.forEach {
                    guard let value = parameters[$0] else { return }
                    let escapedValue = value.addingPercentEncoding(
                        withAllowedCharacters: CharacterSet.ba_URLQueryAllowedCharacterSet()
                    )
                    if let escapedValue = escapedValue {
                        retUrl.append("\($0)=\(escapedValue)&")
                    }
                }
                retUrl.removeLast()
            }
        }
        return retUrl
    }
}
