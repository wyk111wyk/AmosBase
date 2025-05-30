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
        #if os(macOS)
        render.scale = NSScreen.main?.backingScaleFactor ?? 1
        #else
        render.scale = UIScreen.main.scale
        #endif
        
        render.proposedSize = .unspecified
        #if os(macOS)
        return render.nsImage
        #else
        return render.uiImage
        #endif
    }
}
