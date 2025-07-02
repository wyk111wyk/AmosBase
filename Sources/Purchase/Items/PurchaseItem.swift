//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/3/13.
//

import SwiftUI

/// 对 IAP 的介绍列表内容
public struct PurchaseItem: Identifiable {
    public let id: UUID = UUID()
    
    let icon: Image
    let title: String
    let regular: String
    let premium: String
    
    public init(
        icon: Image,
        title: String,
        regular: String,
        premium: String
    ) {
        self.icon = icon
        self.title = title
        self.regular = regular
        self.premium = premium
    }
}
