//
//  File.swift
//  
//
//  Created by AmosFitness on 2023/11/9.
//

import SwiftUI

struct ButtonTestView: View {
    @State private var showAlert01 = false
    
    var body: some View {
        List {
            SimpleCell("Title Title Title",
                       iconName: nil, 
                       systemImage: "pencil.and.outline", 
                       contentSystemImage: "scribble",
                       content: "Content Content Content Content Content Content",
                       stateText: nil) {
                Spacer()
                Text("1234567")
            }
            SimpleCell("Title Title Title",
                       iconName: nil, 
                       systemImage: "pencil.and.outline",
                       content: "Content Content Content Content Content Content",
                       stateText: "0987654")
            Section {
                SimpleMiddleButton("Middle button", role: .destructive) {}
            }
        }
        #if !os(watchOS) && !os(macOS)
        .listStyle(.insetGrouped)
        #endif
    }
}

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
                Text(title)
                Spacer()
            }
        }
    #if !os(watchOS)
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
    /// 可自定义图标颜色
    public func buttonCircleNavi(role: ButtonRole? = nil,
                                 labelColor: Color? = nil,
                                 isPresent: Bool = true,
                                 callback: @escaping () -> Void = {}) -> some View {
        modifier(CircleButtonNavi(role: role,
                                  labelColor: labelColor,
                                  isPresent: isPresent,
                                  callback: callback))
    }
    
    /// 普通页面角落的圆形按钮 - 例如Sheet页面
    ///
    /// 类型分为nil, cancel, destructive 三种，影响按钮行为和颜色
    ///
    /// 可自定义图标颜色
    public func buttonCirclePage(role: ButtonRole? = nil,
                                 labelColor: Color? = nil,
                                 isPresent: Bool = true,
                                 callback: @escaping () -> Void = {}) -> some View {
        modifier(CircleButtonPage(role: role,
                                  labelColor: labelColor,
                                  isPresent: isPresent,
                                  callback: callback))
    }
}

// MARK: - 基础的按钮组件

struct CircleButton: View {
    let role: ButtonRole?
    let labelColor: Color?
    let callback: () -> Void
    
    let title: LocalizedStringKey
    let imageName: String
    
    init(role: ButtonRole? = nil,
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
            self.labelColor = .red
        }else {
            self.title = LocalizedStringKey("Confirm")
            self.imageName = "checkmark"
            self.labelColor = labelColor
        }
        
        self.callback = callback
    }
    
    var body: some View {
        Button(title,
               systemImage: imageName,
               role: role,
               action: callback)
        .modifier(ButtonCircleBackground(labelColor))
    }
}

struct CircleButtonPage: ViewModifier {
    let role: ButtonRole?
    let labelColor: Color?
    let isPresent: Bool
    let callback: () -> Void
    
    let alignment: Alignment
    
    init(role: ButtonRole? = nil,
         labelColor: Color? = nil,
         isPresent: Bool = true,
         callback: @escaping () -> Void = {}) {
        self.role = role
        self.labelColor = labelColor
        self.isPresent = isPresent
        self.callback = callback
        if role == .cancel {
            alignment = .topLeading
        }else {
            alignment = .topTrailing
        }
    }
    
    func body(content: Content) -> some View {
        if isPresent {
            content.overlay(alignment: alignment) {
                CircleButton(role: role,
                             labelColor: labelColor,
                             callback: callback)
                .padding()
            }
        }else {
            content
        }
    }
}

struct CircleButtonNavi: ViewModifier {
    let role: ButtonRole?
    let labelColor: Color?
    let isPresent: Bool
    let callback: () -> Void
    
    let placement: ToolbarItemPlacement
    
    init(role: ButtonRole? = nil,
         labelColor: Color? = nil,
         isPresent: Bool = true,
         callback: @escaping () -> Void = {}) {
        self.role = role
        self.labelColor = labelColor
        self.isPresent = isPresent
        self.callback = callback
        if role == .cancel {
            placement = .cancellationAction
        }else {
            placement = .confirmationAction
        }
    }
    
    func body(content: Content) -> some View {
        if isPresent {
            content.toolbar {
                ToolbarItem(placement: placement) {
                    CircleButton(role: role,
                                 labelColor: labelColor,
                                 callback: callback)
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
                .foregroundStyle(labelColor ?? Color.accentColor)
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

#Preview("Navi") {
    NavigationStack {
        ButtonTestView()
            .buttonCircleNavi(role: .cancel)
            .buttonCircleNavi(role: .destructive)
    }
}
