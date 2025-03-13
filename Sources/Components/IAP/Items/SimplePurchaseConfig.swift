//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/3/13.
//

import SwiftUI

public struct SimplePurchaseConfig {
    let title: String?
    let titleImage_w: Image
    let titleImage_b: Image?
    let imageCaption: String?
    let devNote: String?
    let allProductId: [String]
    
    public init(
        title: String?,
        titleImage_w: Image,
        titleImage_b: Image? = nil,
        imageCaption: String? = nil,
        devNote: String? = nil,
        allProductId: [String] = []
    ) {
        self.title = title
        self.titleImage_w = titleImage_w
        self.titleImage_b = titleImage_b
        self.imageCaption = imageCaption
        self.devNote = devNote
        self.allProductId = allProductId
    }
}
