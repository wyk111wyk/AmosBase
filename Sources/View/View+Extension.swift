//
//  File.swift
//
//
//  Created by AmosFitness on 2023/11/10.
//

import SwiftUI

public enum AmosError: Error, Equatable, LocalizedError {
    case customError(msg: String)
    
    public var errorDescription: String? {
        switch self {
        case .customError(let msg):
            return msg
        }
    }
}

/// 判断是否处于 Preview 环境
public let isPreviewCondition: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

public extension Binding {
    static func isPresented<V>(_ value: Binding<V?>) -> Binding<Bool> {
        Binding<Bool>(
            get: { value.wrappedValue != nil },
            set: { if !$0 { value.wrappedValue = nil } }
        )
    }
    
    static func isOptionalPresented<V>(_ value: Binding<V?>) -> Binding<Bool?> {
        Binding<Bool?>(
            get: { value.wrappedValue != nil },
            set: { if $0 == false || $0 == nil { value.wrappedValue = nil } }
        )
    }
}
        
