//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/3/13.
//

import SwiftUI

public struct SimplePurchaseItem: Identifiable {
    public let id: UUID = UUID()
    
    let icon: Image
    let title: String
    let regular: String
    let premium: String
    
    public init(icon: Image, title: String, regular: String, premium: String) {
        self.icon = icon
        self.title = title
        self.regular = regular
        self.premium = premium
    }
}
