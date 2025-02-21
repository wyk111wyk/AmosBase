//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/5/15.
//

import Foundation

public enum SimpleError: Error, Equatable, LocalizedError, Sendable {
    case customError(title: String = "", msg: String, statusCode: Int? = nil)
    case networkError(title: String = "[Network Error]", msg: String, statusCode: Int? = nil)
    
    public var message: String {
        switch self {
        case .customError(let title, let msg, let statusCode):
            "[\(statusCode ?? 0)]" + title + ": " + msg
        case .networkError(let title, let msg, let statusCode):
            "[\(statusCode ?? 0)]" + title + ": " + msg
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .customError(_, let msg, _):
            return msg.localized()
        case .networkError(_, let msg, _):
            return msg.lowercased()
        }
    }
}
