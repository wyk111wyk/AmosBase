//
//  File.swift
//
//
//  Created by AmosFitness on 2023/11/10.
//

import SwiftUI
import Translation
import Foundation

// MARK: - 全平台使用的方法

/// 判断是否处于 Preview 环境
public let isPreviewCondition: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

public extension Binding {
    static func isPresented<V>(_ value: Binding<V?>) -> Binding<Bool> {
        Binding<Bool>(
            get: { value.wrappedValue != nil },
            set: { if !$0 { value.wrappedValue = nil } }
        )
    }
    
    static func isOptionalPresented<V>(_ value: Binding<V?>) -> Binding<Bool?> {
        Binding<Bool?>(
            get: { value.wrappedValue != nil },
            set: { if $0 == false || $0 == nil { value.wrappedValue = nil } }
        )
    }
}

extension GeometryProxy: @unchecked @retroactive Sendable {}

public extension View {
    /// SF Symbol的跳跃动画
    func bounceEffect(
        byLayer: Bool = true,
        isActive: Bool? = nil
    ) -> some View {
        #if os(watchOS)
        return AnyView(self)
        #else
        if #available(iOS 18.0, macOS 15.0, *) {
            if let isActive {
                return AnyView(self.symbolEffect(
                    byLayer ? .bounce.byLayer : .bounce.wholeSymbol,
                    isActive: isActive
                ))
            }else {
                return AnyView(self.symbolEffect(
                    byLayer ? .bounce.byLayer : .bounce.wholeSymbol
                ))
            }
        } else {
            return AnyView(self)
        }
        #endif
    }
    
    /// 设置 View 的颜色
    func viewColor(_ color: Color? = nil) -> some View {
        if let color {
            return AnyView(self.foregroundStyle(color))
        }else {
            return AnyView(self)
        }
    }
    
    /// 设置 List 的 Section 间距
    func sectionSpacing(_ spacing: CGFloat = 15) -> some View {
#if os(iOS)
        self.listSectionSpacing(spacing)
#else
        self
#endif
    }
    
    /// 设置标题类型为 inline
    func inlineTitleForNavigationBar() -> some View {
#if os(iOS)
        self.navigationBarTitleDisplayMode(.inline)
#else
        self
#endif
    }
    
    /// 设置标题类型为 large
    func largeTitleForNavigationBar() -> some View {
#if os(iOS)
        self.navigationBarTitleDisplayMode(.large)
#else
        self
#endif
    }
}

// MARK: - 除 watch 外的平台
#if !os(watchOS)
public extension View {
    func simpleSearch(
        text: Binding<String>,
        prompt: String? = nil,
        isAlwaysShow: Bool = true
    ) -> some View {
        let promptText: Text? =
        if let prompt { Text(prompt) } else { nil }
#if os(iOS)
        return self.searchable(
            text: text,
            placement: .navigationBarDrawer(displayMode: isAlwaysShow ? .always : .automatic),
            prompt: promptText
        )
        .searchDictationBehavior(.inline(activation: .onLook))
#elseif os(macOS)
        return self.searchable(
            text: text,
            placement: .toolbar,
            prompt: promptText
        )
#endif
    }
    
    func translation(isPresented: Binding<Bool>, text: String) -> some View {
#if targetEnvironment(macCatalyst)
        return self
#else
        if #available(iOS 17.4, macOS 14.4, *) {
            return self.translationPresentation(isPresented: isPresented, text: text)
        } else {
            return self
        }
#endif
    }
}
#endif

// MARK: - Mac 平台
#if os(macOS)

/// Reimplemenation of [EditMode](https://developer.apple.com/documentation/swiftui/editmode) for macOS.
public enum EditMode {
    
    /// The user can edit the view content.
    case active
    
    /// The user can’t edit the view content.
    case inactive
    
    /// The view is in a temporary edit mode.
    case transient
}

extension EditMode: Equatable {}
extension EditMode: Hashable {}

extension EditMode {
    
    /// Indicates whether a view is being edited.
    ///
    /// This property returns `true` if the mode is something other than inactive.
    public var isEditing: Bool {
        self != .inactive
    }
    
    /// Toggles the edit mode between `.inactive` and `.active`.
    public mutating func toggle() {
        switch self {
        case .inactive: self = .active
        case .active: self = .inactive
        case .transient: break
#if os(iOS)
        @unknown default: break
#endif
        }
    }
}

private struct EditModeEnvironmentKey: EnvironmentKey {
    static var defaultValue: Binding<EditMode>?
}

extension EnvironmentValues {
    
    /// An indication of whether the user can edit the contents of a view associated with this environment.
    public var editMode: Binding<EditMode>? {
        get {
            self[EditModeEnvironmentKey.self]
        }
        set {
            self[EditModeEnvironmentKey.self] = newValue
        }
    }
}

extension Optional where Wrapped == Binding<EditMode> {
    
    /// Convenience property so call sites can use a clean `editMode.isEditing` instead of the
    /// ugly boilerplate `editMode?.wrappedValue.isEditing == true`.
    public var isEditing: Bool {
        self?.wrappedValue.isEditing == true
    }
}

#endif
