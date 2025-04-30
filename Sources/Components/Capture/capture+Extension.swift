//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/4/29.
//

import Foundation
import SwiftUI

public extension View {
    /// 对传入的 View 进行截图
    func capture() -> SFImage? {
        let render = ImageRenderer(
            content: self
        )
        render.scale = 2
        #if canImport(AppKit)
        return render.nsImage
        #else
        return render.uiImage
        #endif
    }
}
