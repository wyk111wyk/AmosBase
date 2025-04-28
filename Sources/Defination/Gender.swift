//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/4/26.
//

import SwiftUI

public enum Gender: String, Codable, CaseIterable, Identifiable, Sendable {
    case male, female
    public var id: String { rawValue }
    
    public var title: LocalizedStringResource {
        switch self {
        case .male: "Male"
        case .female: "Female"
        }
    }
    
    public var avatarUrl: URL {
        switch self {
        case .male: URL(string: "https://www.amosstudio.com.cn/avatar/avatar_m.png")!
        case .female: URL(string: "https://www.amosstudio.com.cn/avatar/avatar_f.png")!
        }
    }
}

public extension Optional where Wrapped == Gender {
    var avatarUrl: URL? {
        switch self {
        case .none:
            URL(string: "https://txc.qq.com/static/desktop/img/products/def-product-logo.png")!
        case .some(let wrapped):
            wrapped.avatarUrl
        }
    }
}
