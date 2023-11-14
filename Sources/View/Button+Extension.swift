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
        .listStyle(.insetGrouped)
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
        .listRowSeparator(.hidden)
    }
}

/// 简单UI组件 -  多样的表格Cell
///
/// 使用自定义的State内容，需要添加Spacer()
public struct SimpleCell<V: View>: View {
    let title: String
    let iconName: String?
    let systemImage: String?
    
    let contentSystemImage: String?
    let content: String?
    
    let imageSize: Double
    let contentSpace: Double
    
    let stateText: String?
    @ViewBuilder let stateView: () -> V
    let stateWidth: CGFloat
    
    public init(_ title: String,
                iconName: String? = nil,
                systemImage: String? = nil,
                imageSize: Double = 22,
                contentSystemImage: String? = nil,
                content: String? = nil,
                contentSpace: Double = 12,
                stateText: String? = nil,
                stateWidth: CGFloat = 100,
                @ViewBuilder stateView: @escaping () -> V = { EmptyView() }) {
        self.title = title
        self.contentSystemImage = contentSystemImage
        self.content = content
        self.iconName = iconName
        self.systemImage = systemImage
        self.imageSize = imageSize
        self.contentSpace = contentSpace
        self.stateText = stateText
        self.stateWidth = stateWidth
        self.stateView = stateView
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: contentSpace) {
            // 图标 icon
            if let iconName = iconName {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageSize, height: imageSize)
            }else if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .foregroundColor(.accentColor)
                    .frame(width: imageSize, height: imageSize)
            }
            // Title 和 Content
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                Group {
                    if let content = content, !content.isEmpty,
                       let contentSystemImage = contentSystemImage, contentSystemImage.count > 0 {
                        Text("\(Image(systemName: contentSystemImage))\(content)")
                    } else if let content = content, content.count > 0 {
                        Text(content)
                    }
                }
                .foregroundColor(.secondary)
                .font(.caption)
            }
            
            Spacer(minLength: 0)
            Group {
                if let stateText = stateText {
                    Text(stateText)
                        .foregroundColor(.secondary)
                }else {
                    stateView()
                }
            }
//            .frame(maxWidth: stateWidth, alignment: .trailing)
//            .padding(.leading, 8)
            .textSelection(.enabled)
        }
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
        if #available(iOS 17.0, *) {
            content
                .foregroundStyle(labelColor ?? Color.accentColor)
                .buttonBorderShape(.circle)
                .buttonStyle(.bordered)
        } else {
            content
                .labelStyle(.iconOnly)
                .padding(6)
                .background {
                    Circle().foregroundStyle(.regularMaterial)
                }
        }
    }
}

#Preview("Navi") {
    NavigationView {
        ButtonTestView()
            .buttonCircleNavi(role: .cancel)
            .buttonCircleNavi(role: .destructive)
    }
}
