//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/3/13.
//

import SwiftUI

/// IAP 配置
public struct PurchaseConfig {
    let title: String?
    let titleImage_w: Image
    let titleImage_b: Image?
    let devNote: String?
    let productDescription: [String: [String]]
    
    public init(
        title: String?,
        titleImage_w: Image,
        titleImage_b: Image? = nil,
        devNote: String? = nil,
        productDescription: [String: [String]] = [:]
    ) {
        self.title = title
        self.titleImage_w = titleImage_w
        self.titleImage_b = titleImage_b
        self.devNote = devNote
        self.productDescription = productDescription
    }
}
