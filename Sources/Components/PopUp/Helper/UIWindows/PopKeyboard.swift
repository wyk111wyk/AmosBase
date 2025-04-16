//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/4/11.
//

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#elseif canImport(WatchKit)
import WatchKit
#endif

// MARK: - KeyboardHeightHelper

#if os(iOS)

@MainActor
class KeyboardHeightHelper: ObservableObject {

    @Published var keyboardHeight: CGFloat = 0
    @Published var keyboardDisplayed: Bool = false

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHideNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func onKeyboardWillShowNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        DispatchQueue.main.async {
            self.keyboardHeight = keyboardRect.height
            self.keyboardDisplayed = true
        }
    }
    
    @objc private func onKeyboardWillHideNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            self.keyboardHeight = 0
            self.keyboardDisplayed = false
        }
    }
}

#else

class KeyboardHeightHelper: ObservableObject {

    @Published var keyboardHeight: CGFloat = 0
    @Published var keyboardDisplayed: Bool = false
}

#endif


// MARK: - Hide keyboard

extension CGPoint {

    @MainActor
    static var pointFarAwayFromScreen: CGPoint {
        CGPoint(x: 2*CGSize.screenSize.width, y: 2*CGSize.screenSize.height)
    }
}

extension CGSize {

    @MainActor
    static var screenSize: CGSize {
#if os(iOS) || os(tvOS)
        return UIScreen.main.bounds.size
#elseif os(watchOS)
        return WKInterfaceDevice.current().screenBounds.size
#elseif os(macOS)
        return NSScreen.main?.frame.size ?? .zero
#elseif os(visionOS)
        return .zero
#endif
    }
}
