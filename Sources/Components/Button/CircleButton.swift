//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/3/14.
//

import SwiftUI

// MARK: - Button相关的UI修饰
extension View {
    #if os(watchOS)
    /// Navi角落的圆形按钮 - 不可用于普通页面
    ///
    /// 类型分为nil, cancel, destructive 三种，影响按钮行为和颜色
    ///
    /// 可自定义图标颜色，不设置role可自定义图标
    public func buttonCircleNavi(role: ButtonRole? = nil,
                                 title: String? = nil,
                                 imageName: String? = nil,
                                 labelColor: Color? = nil,
                                 isDisable: Bool = false,
                                 isPresent: Bool = true,
                                 isLoading: Bool = false,
                                 placement: ToolbarItemPlacement? = nil,
                                 callback: @escaping () -> Void = {}) -> some View {
        modifier(CircleButtonNavi(role: role,
                                  title: title,
                                  imageName: imageName,
                                  labelColor: labelColor,
                                  isDisable: isDisable,
                                  isPresent: isPresent,
                                  isLoading: isLoading,
                                  placement: placement,
                                  callback: callback))
    }
    
    /// 普通页面角落的圆形按钮 - 例如Sheet页面
    ///
    /// 类型分为nil, cancel, destructive 三种，影响按钮行为和颜色
    ///
    /// 可自定义图标颜色，不设置role可自定义图标
    public func buttonCirclePage(role: ButtonRole? = nil,
                                 title: String? = nil,
                                 imageName: String? = nil,
                                 labelColor: Color? = nil,
                                 isDisable: Bool = false,
                                 isPresent: Bool = true,
                                 isLoading: Bool = false,
                                 alignment: Alignment? = nil,
                                 callback: @escaping () -> Void = {}) -> some View {
        modifier(CircleButtonPage(role: role,
                                  title: title,
                                  imageName: imageName,
                                  labelColor: labelColor,
                                  isDisable: isDisable,
                                  isPresent: isPresent,
                                  isLoading: isLoading,
                                  alignment: alignment,
                                  callback: callback))
    }
    #else
    /// Navi角落的圆形按钮 - 不可用于普通页面
    ///
    /// 类型分为nil, cancel, destructive 三种，影响按钮行为和颜色
    ///
    /// 可自定义图标颜色，不设置role可自定义图标
    public func buttonCircleNavi(
        role: ButtonRole? = nil,
        title: String? = nil,
        imageName: String? = nil,
        labelColor: Color? = nil,
        isDisable: Bool = false,
        isPresent: Bool = true,
        isLoading: Bool = false,
        key: KeyEquivalent? = nil,
        modifiers: EventModifiers? = nil,
        placement: ToolbarItemPlacement? = nil,
        callback: @escaping () -> Void = {}
    ) -> some View {
        
        #if os(macOS)
        let isPresent = false
        #else
        let isPresent = isPresent
        #endif
        return modifier(
            CircleButtonNavi(
                role: role,
                title: title,
                imageName: imageName,
                labelColor: labelColor,
                isDisable: isDisable,
                isPresent: isPresent,
                isLoading: isLoading,
                key: key,
                modifiers: modifiers,
                placement: placement,
                callback: callback
            )
        )
    }
    
    /// 普通页面角落的圆形按钮 - 例如Sheet页面
    ///
    /// 类型分为nil, cancel, destructive 三种，影响按钮行为和颜色
    ///
    /// 可自定义图标颜色，不设置role可自定义图标
    public func buttonCirclePage(role: ButtonRole? = nil,
                                 title: String? = nil,
                                 imageName: String? = nil,
                                 labelColor: Color? = nil,
                                 isDisable: Bool = false,
                                 isPresent: Bool = true,
                                 isLoading: Bool = false,
                                 key: KeyEquivalent? = nil,
                                 modifiers: EventModifiers? = nil,
                                 alignment: Alignment? = nil,
                                 callback: @escaping () -> Void = {}) -> some View {
        modifier(CircleButtonPage(role: role,
                                  title: title,
                                  imageName: imageName,
                                  labelColor: labelColor,
                                  isDisable: isDisable,
                                  isPresent: isPresent,
                                  isLoading: isLoading,
                                  key: key,
                                  modifiers: modifiers,
                                  alignment: alignment,
                                  callback: callback))
    }
    #endif
}

// MARK: - 基础的按钮组件

public struct CircleButton: View {
    let role: ButtonRole?
    let labelColor: Color?
    let callback: () -> Void
    
    var title: LocalizedStringKey
    let imageName: String
    let isLoading: Bool
    
    #if !os(watchOS)
    let key: KeyEquivalent?
    let modifiers: EventModifiers?
    public init(
        role: ButtonRole? = nil,
        title: String? = nil,
        imageName: String? = nil,
        labelColor: Color? = nil,
        isLoading: Bool = false,
        key: KeyEquivalent? = nil,
        modifiers: EventModifiers? = nil,
        callback: @escaping () -> Void = {}
    ) {
        self.role = role
        if role == .cancel {
            self.title = .cancel
            self.imageName = "xmark"
            if labelColor != nil {
                self.labelColor = labelColor
            }else {
                self.labelColor = .primary
            }
        }else if role == .destructive {
            self.title = .confirm
            self.imageName = "checkmark"
            self.labelColor = labelColor
        }else {
            self.title = .confirm
            self.imageName = imageName ?? "checkmark"
            self.labelColor = labelColor
        }
        
        if let title {
            self.title = LocalizedStringKey(title)
        }
        
        self.isLoading = isLoading
        self.key = key
        self.modifiers = modifiers
        self.callback = callback
    }
    
    public var body: some View {
        if isLoading {
            Button {} label: {
                ProgressView()
                    .tint(labelColor)
                    #if os(macOS)
                    .scaleEffect(0.56)
                    #endif
            }
            .disabled(true)
        }else {
            Button(
                title,
                systemImage: imageName,
                role: role,
                action: callback
            )
            .modifier(
                ButtonShortkey(
                    role: role,
                    key: key,
                    modifiers: modifiers
                )
            )
            .modifier(ButtonCircleBackground(labelColor))
        }
    }
    #else
    public init(
        role: ButtonRole? = nil,
        title: String? = nil,
        imageName: String? = nil,
        labelColor: Color? = nil,
        isLoading: Bool = false,
        callback: @escaping () -> Void = {}
    ) {
        self.role = role
        if role == .cancel {
            self.title = .cancel
            self.imageName = "xmark"
            if labelColor != nil {
                self.labelColor = labelColor
            }else {
                self.labelColor = .primary
            }
        }else if role == .destructive {
            self.title = .confirm
            self.imageName = "checkmark"
            self.labelColor = labelColor
        }else {
            self.title = .confirm
            self.imageName = imageName ?? "checkmark"
            self.labelColor = labelColor
        }
        
        if let title {
            self.title = LocalizedStringKey(title)
        }
        
        self.isLoading = isLoading
        self.callback = callback
    }
    
    public var body: some View {
        Button(
            title,
            systemImage: imageName,
            role: role,
            action: callback
        )
        .modifier(ButtonCircleBackground(labelColor))
    }
    #endif
}

struct CircleButtonPage: ViewModifier {
    let role: ButtonRole?
    let title: String?
    let imageName: String?
    let labelColor: Color?
    let isDisable: Bool
    let isPresent: Bool
    let isLoading: Bool
    
    let alignment: Alignment
    
    let callback: () -> Void
    
    #if !os(watchOS)
    let key: KeyEquivalent?
    let modifiers: EventModifiers?
    init(role: ButtonRole? = nil,
         title: String? = nil,
         imageName: String? = nil,
         labelColor: Color? = nil,
         isDisable: Bool = false,
         isPresent: Bool = true,
         isLoading: Bool = false,
         key: KeyEquivalent? = nil,
         modifiers: EventModifiers? = nil,
         alignment: Alignment? = nil,
         callback: @escaping () -> Void = {}) {
        self.role = role
        self.title = title
        self.imageName = imageName
        self.labelColor = labelColor
        self.isDisable = isDisable
        self.isPresent = isPresent
        self.isLoading = isLoading
        self.callback = callback
        self.key = key
        self.modifiers = modifiers
        if let alignment {
            self.alignment = alignment
        }else {
            if role == .cancel {
                self.alignment = .topLeading
            }else {
                self.alignment = .topTrailing
            }
        }
    }
    
    func body(content: Content) -> some View {
        if isPresent {
            content.overlay(alignment: alignment) {
                CircleButton(
                    role: role,
                    title: title,
                    imageName: imageName,
                    labelColor: labelColor,
                    isLoading: isLoading,
                    key: key,
                    modifiers: modifiers,
                    callback: callback
                )
                .disabled(isDisable)
                .padding()
            }
        }else {
            content
        }
    }
    #else
    init(role: ButtonRole? = nil,
         title: String? = nil,
         imageName: String? = nil,
         labelColor: Color? = nil,
         isDisable: Bool = false,
         isPresent: Bool = true,
         isLoading: Bool = false,
         alignment: Alignment? = nil,
         callback: @escaping () -> Void = {}) {
        self.role = role
        self.title = title
        self.imageName = imageName
        self.labelColor = labelColor
        self.isDisable = isDisable
        self.isPresent = isPresent
        self.isLoading = isLoading
        self.callback = callback
        if let alignment {
            self.alignment = alignment
        }else {
            if role == .cancel {
                self.alignment = .topLeading
            }else {
                self.alignment = .topTrailing
            }
        }
    }
    
    func body(content: Content) -> some View {
        if isPresent {
            content.overlay(alignment: alignment) {
                CircleButton(
                    role: role,
                    title: title,
                    imageName: imageName,
                    labelColor: labelColor,
                    isLoading: isLoading,
                    callback: callback
                )
                .disabled(isDisable)
                .padding()
            }
        }else {
            content
        }
    }
    #endif
}

struct CircleButtonNavi: ViewModifier {
    let role: ButtonRole?
    let title: String?
    let imageName: String?
    let labelColor: Color?
    let isDisable: Bool
    let isPresent: Bool
    let isLoading: Bool
    let placement: ToolbarItemPlacement
    
    let callback: () -> Void
    
    #if !os(watchOS)
    let key: KeyEquivalent?
    let modifiers: EventModifiers?
    init(
        role: ButtonRole? = nil,
        title: String? = nil,
        imageName: String? = nil,
        labelColor: Color? = nil,
        isDisable: Bool = false,
        isPresent: Bool = true,
        isLoading: Bool = false,
        key: KeyEquivalent? = nil,
        modifiers: EventModifiers? = nil,
        placement: ToolbarItemPlacement? = nil,
        callback: @escaping () -> Void = {}
    ) {
        self.role = role
        self.title = title
        self.imageName = imageName
        self.labelColor = labelColor
        self.isDisable = isDisable
        self.isLoading = isLoading
        self.callback = callback
        self.key = key
        self.modifiers = modifiers
        if let placement {
            self.placement = placement
        }else {
            if role == .cancel {
                self.placement = .cancellationAction
            }else {
                self.placement = .confirmationAction
            }
        }
        self.isPresent = isPresent
    }
    
    func body(content: Content) -> some View {
        if isPresent {
            content.toolbar {
                ToolbarItem(placement: placement) {
                    CircleButton(
                        role: role,
                        title: title,
                        imageName: imageName,
                        labelColor: labelColor,
                        isLoading: isLoading,
                        key: key,
                        modifiers: modifiers,
                        callback: callback
                    )
                    .disabled(isDisable)
                }
            }
        }else {
            content
        }
    }
    #else
    init(
        role: ButtonRole? = nil,
        title: String? = nil,
        imageName: String? = nil,
        labelColor: Color? = nil,
        isDisable: Bool = false,
        isPresent: Bool = true,
        isLoading: Bool = false,
        placement: ToolbarItemPlacement? = nil,
        callback: @escaping () -> Void = {}
    ) {
        self.role = role
        self.title = title
        self.imageName = imageName
        self.labelColor = labelColor
        self.isDisable = isDisable
        self.isPresent = isPresent
        self.isLoading = isLoading
        self.callback = callback
        if let placement {
            self.placement = placement
        }else {
            if role == .cancel {
                self.placement = .cancellationAction
            }else {
                self.placement = .confirmationAction
            }
        }
    }
    
    func body(content: Content) -> some View {
        if isPresent {
            content.toolbar {
                ToolbarItem(placement: placement) {
                    CircleButton(
                        role: role,
                        title: title,
                        imageName: imageName,
                        labelColor: labelColor,
                        isLoading: isLoading,
                        callback: callback
                    )
                    .disabled(isDisable)
                }
            }
        }else {
            content
        }
    }
    #endif
}

struct ButtonCircleBackground: ViewModifier {
    let labelColor: Color?
    
    init(_ labelColor: Color? = nil) {
        self.labelColor = labelColor
    }
    
    func body(content: Content) -> some View {
        #if os(iOS)
        content
            .foregroundStyle(labelColor ?? Color.accentColor)
            .fontWeight(.medium)
            .buttonBorderShape(.circle)
            .buttonStyle(.bordered)
        #elseif os(watchOS)
        content
            .foregroundStyle(labelColor ?? Color.accentColor)
        #elseif os(macOS)
        content
            .buttonStyle(.bordered)
        #endif
    }
}
