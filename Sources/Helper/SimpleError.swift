//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/5/15.
//

import Foundation

public enum SimpleError: Error, Equatable, LocalizedError, Sendable {
    case customError(title: String = "", msg: String)
    case networkError(title: String = "[Network Error]", msg: String)
    
    public var message: String {
        switch self {
        case .customError(let title, let msg):
            title + ": " + msg
        case .networkError(let title, let msg):
            title + ": " + msg
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .customError(_, let msg):
            return msg.localized()
        case .networkError(_, let msg):
            return msg.lowercased()
        }
    }
}
