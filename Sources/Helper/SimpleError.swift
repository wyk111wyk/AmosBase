//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/5/15.
//

import Foundation

public enum SimpleError: Error, Equatable, LocalizedError {
    case customError(msg: String)
    
    public var errorDescription: String? {
        switch self {
        case .customError(let msg):
            return msg.localized()
        }
    }
}
