//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/4/13.
//

import Foundation
import SwiftUI

typealias popup = Popup<_ConditionalContent<_ConditionalContent<PopBanner, PopToast>, PopHud>>

struct PopDemoConfig {
    var displayMode: popup.DisplayMode = .window
    var position: popup.Position = .top
    
    var appearFrom: popup.AppearAnimation? = nil
    var disappearTo: popup.AppearAnimation? = nil
    
    var animation: Animation = .easeOut(duration: 0.3)
    
    var autohideIn: Double = 0 // 0 代表不会自动消失
    var dragToDismiss: Bool = true
    var closeOnTap: Bool = true
    
    var showBackground: Bool = false
    var closeOnTapOutside: Bool = false
    
    var useKeyboardSafeArea: Bool = false
    var hasHaptic: Bool = true
}

extension popup.PopupParameters {
    mutating func update(_ config: PopDemoConfig, mode: SimplePopupMode) {
        displayMode = config.displayMode
        position = config.position
        if let appearAnima = config.appearFrom {
            appearFrom = appearAnima
            disappearTo = appearAnima
        }else if config.position.isTop {
            appearFrom = .topSlide
            disappearTo = .topSlide
        }else if config.position.isBottom {
            appearFrom = .bottomSlide
            disappearTo = .bottomSlide
        }
        if let disAnima = config.disappearTo {
            disappearTo = disAnima
        }
        animation = config.animation
        if config.autohideIn > 0 {
            autohideIn = config.autohideIn
        }
        dragToDismiss = config.dragToDismiss
        closeOnTap = config.closeOnTap
        if config.showBackground {
            backgroundView = AnyView(PopBackgroundView())
        }
        closeOnTapOutside = config.closeOnTapOutside
        useKeyboardSafeArea = config.useKeyboardSafeArea
        if config.hasHaptic {
            if mode == .success {
                haptic = .success
            }else if mode == .error {
                haptic = .failure
            }
        }
    }
}

extension popup.PopupType {
    var title: String {
        switch self {
        case .default: "HUD"
        case .toast: "等宽Toast"
        case .floater: "浮空Banner"
        }
    }
    
}

extension popup.DisplayMode: Hashable, Identifiable {
    static var allCases: [popup.DisplayMode] {
        [.window, .overlay, .sheet]
    }
    var title: String {
        switch self {
        case .window: "UIWindow" // UIWindow
        case .overlay: "ZStack(Overlay)" // ZStack
        case .sheet: "FullScreenSheet" // FullScreenSheet
        }
    }
    public var id: String { title }
}

extension popup.AppearAnimation: Hashable, Identifiable {
    static var allCases: [popup.AppearAnimation] {
        [.topSlide, .bottomSlide, .leftSlide, .rightSlide, .centerScale, .none]
    }
    var title: String {
        switch self {
        case .topSlide: "从上滑入"
        case .bottomSlide: "从下滑入"
        case .leftSlide: "左滑"
        case .rightSlide: "右滑"
        case .centerScale: "缩放"
        case .none: "无"
        }
    }
    public var id: String { title }
}

extension popup.Position: Hashable, Identifiable {
    #if os(macOS)
    static var allCases: [popup.Position] {
        [.topLeading, .top, .topTrailing, .leading, .center, .trailing, .bottomLeading, .bottom, .bottomTrailing]
    }
    #else
    static var allCases: [popup.Position] {
        if SimpleDevice.getDevice() == .phone {
            return [.top, .center, .bottom]
        }else {
            return [.topLeading, .top, .topTrailing, .leading, .center, .trailing, .bottomLeading, .bottom, .bottomTrailing]
        }
    }
    #endif
    var title: String {
        switch self {
        case .topLeading: "左上"
        case .top: "上"
        case .topTrailing: "右上"
        case .leading: "左"
        case .center: "中"
        case .trailing: "右"
        case .bottomLeading: "左下"
        case .bottom: "下"
        case .bottomTrailing: "右下"
        }
    }
    public var id: String { title }
}
