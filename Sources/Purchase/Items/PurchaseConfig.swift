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
    let imageCaption: String?
    let devNote: String?
    let hasFreeTrial: Bool
    
    public init(
        title: String?,
        titleImage_w: Image,
        titleImage_b: Image? = nil,
        imageCaption: String? = nil,
        devNote: String? = nil,
        hasFreeTrial: Bool = false
    ) {
        self.title = title
        self.titleImage_w = titleImage_w
        self.titleImage_b = titleImage_b
        self.imageCaption = imageCaption
        self.devNote = devNote
        self.hasFreeTrial = hasFreeTrial
    }
}
