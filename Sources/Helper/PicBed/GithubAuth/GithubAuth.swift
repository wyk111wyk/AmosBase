//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/5/14.
//

import Foundation

public enum GithubAuthType {
    case none
    case headers
    case parameters
}

public class GithubAuth {
    public var type: GithubAuthType {
        return .none
    }
    public init() {
        
    }
    
    public var key: String {
        return ""
    }
    
    public var value: String {
        return ""
    }
    
    public func headers() -> [String : String] {
        return [key : value]
    }
}

public class BasicGithubAuth: GithubAuth {
    override public var type: GithubAuthType {
        return .headers
    }
    public var username: String
    public var password: String
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    override public var key: String {
        return "Authorization"
    }
    
    override public var value: String {
        let authorization = self.username + ":" + self.password
        return "Basic \(authorization.base64Encoded() ?? "")"
    }
    
    override public func headers() -> [String : String] {
        let authorization = self.username + ":" + self.password
        return ["Authorization": "Basic \(authorization.base64Encoded() ?? "")"]
    }
}

public class TokenGithubAuth: GithubAuth {
    override public var type: GithubAuthType {
        return .headers
    }
    public var token: String
    
    public init(token: String) {
        self.token = token
    }
    
    override public var key: String {
        return "Authorization"
    }
    
    override public var value: String {
        return "Bearer \(self.token)"
    }
}
