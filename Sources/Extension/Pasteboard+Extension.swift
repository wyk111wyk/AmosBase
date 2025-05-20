//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/5/19.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

public extension String {
    /// SwifterSwift: Copy string to global pasteboard.
    ///
    ///        "SomeText".copyToPasteboard() // copies "SomeText" to pasteboard
    ///
    func copyToPasteboard() {
        #if canImport(UIKit)
        UIPasteboard.general.string = self
        #elseif canImport(AppKit) && !targetEnvironment(macCatalyst)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(self, forType: .string)
        #endif
    }
}

extension SimpleDevice {
    public static func getPasteboardText() -> String? {
        #if canImport(UIKit)
        let pasteboard = UIPasteboard.general
        if pasteboard.hasStrings {
            return pasteboard.string
        }else {
            return nil
        }
        #elseif canImport(AppKit) && !targetEnvironment(macCatalyst)
        let pasteboard = NSPasteboard.general
        return pasteboard.string(forType: .string)
        #endif
    }
}
