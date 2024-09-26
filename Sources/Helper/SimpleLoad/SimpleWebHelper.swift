//
//  File.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/9/25.
//

import Foundation

public enum SimpleRequestMethod: String {
    case OPTIONS
    case GET
    case HEAD
    case POST
    case PATCH
    case PUT
    case DELETE
    case TRACE
    case CONNECT
}

extension CharacterSet {
    static func ba_URLQueryAllowedCharacterSet() -> CharacterSet {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)
        return allowedCharacterSet
    }
}

/// Types adopting the `URLConvertible` protocol can be used to construct `URL`s, which can then be used to construct
/// `URLRequests`.
public protocol URLConvertible {
    /// Returns a `URL` from the conforming instance or throws.
    ///
    /// - Returns: The `URL` created from the instance.
    /// - Throws:  Any error thrown while creating the `URL`.
    func asURL() throws -> URL
    
    var urlString: String { get }
}

extension String: URLConvertible {
    public var urlString: String {
        self
    }
    
    public func asURL() throws -> URL {
        guard let url = URL(string: self) else {
            throw SimpleError.customError(msg: "invalidURL: \(self)")
        }

        return url
    }
}

extension URL: URLConvertible {
    public var urlString: String {
        self.absoluteString
    }
    
    /// Returns `self`.
    public func asURL() throws -> URL { self }
}

extension URLComponents: URLConvertible {
    public var urlString: String {
        url?.absoluteString ?? "invalidURL"
    }
    
    /// Returns a `URL` if the `self`'s `url` is not nil, otherwise throws.
    ///
    /// - Returns: The `URL` from the `url` property.
    /// - Throws:  An `AFError.invalidURL` instance.
    public func asURL() throws -> URL {
        guard let url = url else {
            throw SimpleError.customError(msg: "invalidURL: \(self)")
        }

        return url
    }
}
