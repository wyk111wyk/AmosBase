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
public struct SimpleMiddleButton: View {
    let title: String
    let systemImageName: String?
    let role: ButtonRole?
    let buttonTap: () -> Void
    
    public init(_ title: String,
                systemImageName: String? = nil,
                role: ButtonRole? = nil,
                buttonTap: @escaping () -> Void) {
        self.title = title
        self.systemImageName = systemImageName
        self.role = role
        self.buttonTap = buttonTap
    }
    
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
        #if os(iOS)
        .listRowSeparator(.hidden)
        #endif
    }
}

// MARK: - Button相关的UI修饰
extension View {
    
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
                                 placement: ToolbarItemPlacement? = nil,
                                 callback: @escaping () -> Void = {}) -> some View {
        modifier(CircleButtonNavi(role: role,
                                  imageName: imageName,
                                  labelColor: labelColor,
                                  isDisable: isDisable,
                                  isPresent: isPresent,
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
                                 alignment: Alignment? = nil,
                                 callback: @escaping () -> Void = {}) -> some View {
        modifier(CircleButtonPage(role: role,
                                  imageName: imageName,
                                  labelColor: labelColor,
                                  isDisable: isDisable,
                                  isPresent: isPresent,
                                  alignment: alignment,
                                  callback: callback))
    }
}

// MARK: - 基础的按钮组件

public struct CircleButton: View {
    let role: ButtonRole?
    let labelColor: Color?
    let callback: () -> Void
    
    let title: LocalizedStringKey
    let imageName: String
    
    public init(role: ButtonRole? = nil,
         imageName: String? = nil,
         labelColor: Color? = nil,
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
        
        self.callback = callback
    }
    
    public var body: some View {
//        Button(role: role, action: callback) {
//            Label(title, systemImage: imageName)
//                .modifier(ButtonCircleBackground(labelColor))
//        }
        Button(title,
               systemImage: imageName,
               role: role,
               action: callback)
        .modifier(ButtonCircleBackground(labelColor))
    }
}

struct CircleButtonPage: ViewModifier {
    let role: ButtonRole?
    let imageName: String?
    let labelColor: Color?
    let isDisable: Bool
    let isPresent: Bool
    let callback: () -> Void
    
    let alignment: Alignment
    
    init(role: ButtonRole? = nil,
         imageName: String? = nil,
         labelColor: Color? = nil,
         isDisable: Bool = false,
         isPresent: Bool = true,
         alignment: Alignment? = nil,
         callback: @escaping () -> Void = {}) {
        self.role = role
        self.imageName = imageName
        self.labelColor = labelColor
        self.isDisable = isDisable
        self.isPresent = isPresent
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
                             callback: callback)
                .disabled(isDisable)
                .padding()
            }
        }else {
            content
        }
    }
}

struct CircleButtonNavi: ViewModifier {
    let role: ButtonRole?
    let imageName: String?
    let labelColor: Color?
    let isDisable: Bool
    let isPresent: Bool
    let callback: () -> Void
    
    let placement: ToolbarItemPlacement
    
    init(role: ButtonRole? = nil,
         imageName: String? = nil,
         labelColor: Color? = nil,
         isDisable: Bool = false,
         isPresent: Bool = true,
         placement: ToolbarItemPlacement? = nil,
         callback: @escaping () -> Void = {}) {
        self.role = role
        self.imageName = imageName
        self.labelColor = labelColor
        self.isDisable = isDisable
        self.isPresent = isPresent
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
                                 callback: callback)
                    .disabled(isDisable)
                }
            }
        }else {
            content
        }
    }
}

struct ButtonCircleBackground: ViewModifier {
    let labelColor: Color?
    
    init(_ labelColor: Color? = nil) {
        self.labelColor = labelColor
    }
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, watchOS 10.0, macOS 14.0, *) {
            #if os(iOS)
            content
//                .imageScale(.medium)
//                .symbolVariant(.circle .fill)
//                .foregroundStyle(.regularMaterial)
//                .opacity(0.8)
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
