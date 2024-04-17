//
//  File.swift
//
//
//  Created by AmosFitness on 2023/11/9.
//

import SwiftUI

/// 简单UI组件 -  文字居中的按钮
///
/// 可定制按钮类型，文字颜色为app主要色
@available(iOS 16, macOS 13, *)
public struct SimpleMiddleButton: View {
    let title: String
    let systemImageName: String?
    let role: ButtonRole?
    let rowVisibility: Visibility
    
    let buttonTap: () -> Void
    
    #if os(watchOS)
    public init(_ title: String,
                systemImageName: String? = nil,
                role: ButtonRole? = nil,
                rowVisibility: Visibility = .hidden,
                buttonTap: @escaping () -> Void) {
        self.title = title
        self.systemImageName = systemImageName
        self.role = role
        
        self.rowVisibility = rowVisibility
        self.buttonTap = buttonTap
    }
    #else
    let key: KeyEquivalent?
    let modifiers: EventModifiers?
    public init(_ title: String,
                systemImageName: String? = nil,
                role: ButtonRole? = nil,
                rowVisibility: Visibility = .hidden,
                key: KeyEquivalent? = nil,
                modifiers: EventModifiers? = nil,
                buttonTap: @escaping () -> Void) {
        self.title = title
        self.systemImageName = systemImageName
        self.role = role
        
        self.rowVisibility = rowVisibility
        self.key = key
        self.modifiers = modifiers
        self.buttonTap = buttonTap
    }
    #endif
    
    public var body: some View {
        Button(role: role, action: buttonTap) {
            HStack(spacing: 8) {
                Spacer()
                if let systemImageName {
                    Image(systemName: systemImageName)
                }
                Text(title.localized())
                Spacer()
            }
        }
        #if !os(watchOS)
        .listRowSeparator(rowVisibility)
        .modifier(ButtonShortkey(role: role,
                                 key: key,
                                 modifiers: modifiers))
        #endif
    }
}

public struct SimpleConfirmButton<V: View>: View {
    let title: String?
    let systemImage: String?
    let role: ButtonRole?
    
    @ViewBuilder var labelView: () -> V
    let tapAction: () -> Void
    
    init(
        title: String? = "Confirm",
        systemImage: String? = nil,
        role: ButtonRole? = nil,
        labelView: @escaping () -> V = { EmptyView() },
        tapAction: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.role = role
        self.labelView = labelView
        self.tapAction = tapAction
    }
    
    public var body: some View {
        Button(role: role, action: tapAction, label: {
            if title != nil || systemImage != nil {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                if let title {
                    Text(title.localized())
                }
            }else {
                labelView()
            }
        })
    }
}

// MARK: - Button相关的UI修饰
extension View {
    #if os(watchOS)
    /// Navi角落的圆形按钮 - 不可用于普通页面
    ///
    /// 类型分为nil, cancel, destructive 三种，影响按钮行为和颜色
    ///
    /// 可自定义图标颜色，不设置role可自定义图标
    public func buttonCircleNavi(role: ButtonRole? = nil,
                                 imageName: String? = nil,
                                 labelColor: Color? = nil,
                                 isDisable: Bool = false,
                                 isPresent: Bool = true,
                                 isLoading: Bool = false,
                                 placement: ToolbarItemPlacement? = nil,
                                 callback: @escaping () -> Void = {}) -> some View {
        modifier(CircleButtonNavi(role: role,
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
                                 imageName: String? = nil,
                                 labelColor: Color? = nil,
                                 isDisable: Bool = false,
                                 isPresent: Bool = true,
                                 isLoading: Bool = false,
                                 alignment: Alignment? = nil,
                                 callback: @escaping () -> Void = {}) -> some View {
        modifier(CircleButtonPage(role: role,
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
    public func buttonCircleNavi(role: ButtonRole? = nil,
                                 imageName: String? = nil,
                                 labelColor: Color? = nil,
                                 isDisable: Bool = false,
                                 isPresent: Bool = true,
                                 isLoading: Bool = false,
                                 key: KeyEquivalent? = nil,
                                 modifiers: EventModifiers? = nil,
                                 placement: ToolbarItemPlacement? = nil,
                                 callback: @escaping () -> Void = {}) -> some View {
        modifier(CircleButtonNavi(role: role,
                                  imageName: imageName,
                                  labelColor: labelColor,
                                  isDisable: isDisable,
                                  isPresent: isPresent,
                                  isLoading: isLoading,
                                  key: key,
                                  modifiers: modifiers,
                                  placement: placement,
                                  callback: callback))
    }
    
    /// 普通页面角落的圆形按钮 - 例如Sheet页面
    ///
    /// 类型分为nil, cancel, destructive 三种，影响按钮行为和颜色
    ///
    /// 可自定义图标颜色，不设置role可自定义图标
    public func buttonCirclePage(role: ButtonRole? = nil,
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
    
    let title: LocalizedStringKey
    let imageName: String
    let isLoading: Bool
    
    #if !os(watchOS)
    let key: KeyEquivalent?
    let modifiers: EventModifiers?
    public init(role: ButtonRole? = nil,
                imageName: String? = nil,
                labelColor: Color? = nil,
                isLoading: Bool = false,
                key: KeyEquivalent? = nil,
                modifiers: EventModifiers? = nil,
                callback: @escaping () -> Void = {}) {
        self.role = role
        if role == .cancel {
            self.title = LocalizedStringKey("Cancel")
            self.imageName = "xmark"
            if labelColor != nil {
                self.labelColor = labelColor
            }else {
                self.labelColor = .primary
            }
        }else if role == .destructive {
            self.title = LocalizedStringKey("Confirm")
            self.imageName = "checkmark"
            self.labelColor = labelColor
        }else {
            self.title = LocalizedStringKey("Confirm")
            self.imageName = imageName ?? "checkmark"
            self.labelColor = labelColor
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
            }
//            .modifier(ButtonCircleBackground(labelColor))
            .disabled(true)
        }else {
            Button(title,
                   systemImage: imageName,
                   role: role,
                   action: callback)
            .modifier(ButtonCircleBackground(labelColor))
            .modifier(ButtonShortkey(role: role,
                                     key: key,
                                     modifiers: modifiers))
        }
    }
    #else
    public init(role: ButtonRole? = nil,
                imageName: String? = nil,
                labelColor: Color? = nil,
                isLoading: Bool = false,
                callback: @escaping () -> Void = {}) {
        self.role = role
        if role == .cancel {
            self.title = LocalizedStringKey("Cancel")
            self.imageName = "xmark"
            if labelColor != nil {
                self.labelColor = labelColor
            }else {
                self.labelColor = .primary
            }
        }else if role == .destructive {
            self.title = LocalizedStringKey("Confirm")
            self.imageName = "checkmark"
            self.labelColor = labelColor
        }else {
            self.title = LocalizedStringKey("Confirm")
            self.imageName = imageName ?? "checkmark"
            self.labelColor = labelColor
        }
        
        self.isLoading = isLoading
        self.callback = callback
    }
    
    public var body: some View {
        Button(title,
               systemImage: imageName,
               role: role,
               action: callback)
        .modifier(ButtonCircleBackground(labelColor))
    }
    #endif
}

struct CircleButtonPage: ViewModifier {
    let role: ButtonRole?
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
                CircleButton(role: role,
                             imageName: imageName,
                             labelColor: labelColor,
                             isLoading: isLoading,
                             key: key,
                             modifiers: modifiers,
                             callback: callback)
                .disabled(isDisable)
                .padding()
            }
        }else {
            content
        }
    }
    #else
    init(role: ButtonRole? = nil,
         imageName: String? = nil,
         labelColor: Color? = nil,
         isDisable: Bool = false,
         isPresent: Bool = true,
         isLoading: Bool = false,
         alignment: Alignment? = nil,
         callback: @escaping () -> Void = {}) {
        self.role = role
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
                CircleButton(role: role,
                             imageName: imageName,
                             labelColor: labelColor,
                             isLoading: isLoading,
                             callback: callback)
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
    init(role: ButtonRole? = nil,
         imageName: String? = nil,
         labelColor: Color? = nil,
         isDisable: Bool = false,
         isPresent: Bool = true,
         isLoading: Bool = false,
         key: KeyEquivalent? = nil,
         modifiers: EventModifiers? = nil,
         placement: ToolbarItemPlacement? = nil,
         callback: @escaping () -> Void = {}) {
        self.role = role
        self.imageName = imageName
        self.labelColor = labelColor
        self.isDisable = isDisable
        self.isPresent = isPresent
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
    }
    
    func body(content: Content) -> some View {
        if isPresent {
            content.toolbar {
                ToolbarItem(placement: placement) {
                    CircleButton(role: role,
                                 imageName: imageName,
                                 labelColor: labelColor,
                                 isLoading: isLoading,
                                 key: key,
                                 modifiers: modifiers,
                                 callback: callback)
                    .disabled(isDisable)
                }
            }
        }else {
            content
        }
    }
    #else
    init(role: ButtonRole? = nil,
         imageName: String? = nil,
         labelColor: Color? = nil,
         isDisable: Bool = false,
         isPresent: Bool = true,
         isLoading: Bool = false,
         placement: ToolbarItemPlacement? = nil,
         callback: @escaping () -> Void = {}) {
        self.role = role
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
                    CircleButton(role: role,
                                 imageName: imageName,
                                 labelColor: labelColor,
                                 isLoading: isLoading,
                                 callback: callback)
                    .disabled(isDisable)
                }
            }
        }else {
            content
        }
    }
    #endif
}

#if !os(watchOS)
struct ButtonShortkey: ViewModifier {
    let role: ButtonRole?
    let key: KeyEquivalent?
    let modifiers: EventModifiers?
    
    func body(content: Content) -> some View {
        if role == .cancel {
            content
                .keyboardShortcut(.escape, modifiers: .command)
        }else if let key, let modifiers {
            content
                .keyboardShortcut(key, modifiers: modifiers)
        }else {
            content
        }
    }
}
#endif

struct ButtonCircleBackground: ViewModifier {
    let labelColor: Color?
    
    init(_ labelColor: Color? = nil) {
        self.labelColor = labelColor
    }
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, watchOS 10.0, macOS 14.0, *) {
#if os(iOS)
            content
                .foregroundStyle(labelColor ?? Color.accentColor)
                .fontWeight(.medium)
                .buttonBorderShape(.circle)
                .buttonStyle(.bordered)
#elseif os(watchOS)
            content
                .foregroundStyle(labelColor ?? Color.accentColor)
#endif
        }
        else {
            content
                .labelStyle(.iconOnly)
                .padding(6)
                .background {
                    if #available(watchOS 10.0, *) {
                        Circle().foregroundStyle(.regularMaterial)
                    }else {
                        Circle().foregroundStyle(.gray.opacity(0.7))
                    }
                }
        }
    }
}
