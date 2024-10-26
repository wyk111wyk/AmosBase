//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/5/15.
//

import Foundation

public enum GithubError: Error, Equatable, LocalizedError {
    case forbidden
    case resourceNotFound
    case conflict
    case validationFailed
    case serviceUnavailable
    case tokenRevoked
    case customError(msg: String)
    
    public var errorDescription: String? {
        switch self {
        case .forbidden:
            "403被禁止使用 Forbidden"
        case .resourceNotFound:
            "404找不到资源 Resource Not Found"
        case .conflict:
            "409指令冲突(新建和删除) Conflict"
        case .validationFailed:
            "422验证失败(检查URL和Para) Validation Failed"
        case .serviceUnavailable:
            "503服务不可用 Service Unavailable"
        case .tokenRevoked:
            "401令牌被撤销 Token Revoked"
        case .customError(let msg):
            msg.localized()
        }
    }
    
    public static func error(from status: Int) -> Self {
        switch status {
        case 403:
            return .forbidden
        case 404:
            return .resourceNotFound
        case 409:
            return .conflict
        case 422:
            return .validationFailed
        case 503:
            return .serviceUnavailable
        case 401:
            return .tokenRevoked
        default:
            return .customError(msg: "错误码：\(status)")
        }
    }
}
