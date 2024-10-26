//
//  File.swift
//
//
//  Created by AmosFitness on 2023/11/9.
//

import SwiftUI

/*
 使用方式：在任何页面添加：
 typealias PlainButton = _PlainButton
 */
public typealias _PlainButton = PlainButton

public struct PlainButton<V: View>: View {
    let label: () -> V
    let tapAction: () -> Void
    
    public init(
        tapAction: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> V
    ) {
        self.label = label
        self.tapAction = tapAction
    }
    
    public var body: some View {
        Button(action: tapAction, label: label)
            .buttonStyle(.plain)
    }
}

public struct SimpleStageButton<V: View>: View {
    let label: () -> V
    let holdAction: (Bool) -> Void
    let tapAction: () -> Void
    
    public init(
        tapAction: @escaping () -> Void,
        holdAction: @escaping (Bool) -> Void,
        @ViewBuilder label: @escaping () -> V
    ) {
        self.label = label
        self.tapAction = tapAction
        self.holdAction = holdAction
    }
    
    public var body: some View {
        Button(action: tapAction, label: label)
            .buttonStyle(StageButtonModifier(holdAction: holdAction))
    }
}

private struct StageButtonModifier: ButtonStyle {
    let holdAction: (Bool) -> Void
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.8 : 1)
            .onChange(of: configuration.isPressed) {
                holdAction(configuration.isPressed)
            }
    }
}

/// 简单UI组件 -  文字居中的按钮
///
/// 可定制按钮类型，文字颜色为app主要色
public struct SimpleMiddleButton: View {
    let title: LocalizedStringKey
    let systemImageName: String?
    let role: ButtonRole?
    let rowVisibility: Visibility
    let bundle: Bundle
    
    let action: () -> Void
    
    #if os(watchOS)
    public init(
        _ title: LocalizedStringKey,
        systemImageName: String? = nil,
        role: ButtonRole? = nil,
        rowVisibility: Visibility = .hidden,
        bundle: Bundle = .main,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImageName = systemImageName
        self.role = role
        
        self.rowVisibility = rowVisibility
        self.bundle = bundle
        self.action = action
    }
    #else
    let key: KeyEquivalent?
    let modifiers: EventModifiers?
    public init(
        _ title: LocalizedStringKey,
        systemImageName: String? = nil,
        role: ButtonRole? = nil,
        rowVisibility: Visibility = .visible,
        bundle: Bundle = .main,
        key: KeyEquivalent? = nil,
        modifiers: EventModifiers? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImageName = systemImageName
        self.role = role
        
        self.bundle = bundle
        self.rowVisibility = rowVisibility
        self.key = key
        self.modifiers = modifiers
        self.action = action
    }
    #endif
    
    public var body: some View {
        Button(role: role, action: action) {
            HStack(spacing: 8) {
                Spacer()
                if let systemImageName {
                    Image(systemName: systemImageName)
                }
                Text(title, bundle: bundle)
                Spacer()
            }
        }
        #if !os(watchOS)
        .buttonStyle(.borderless)
        .listRowSeparator(rowVisibility)
        .modifier(
            ButtonShortkey(
                role: role,
                key: key,
                modifiers: modifiers
            )
        )
        #endif
    }
}

/// 简单的用来进行多线程任务的按钮
public struct SimpleAsyncButton<V: View>: View {
    let title: String?
    let systemImage: String?
    let role: ButtonRole?
    
    let action: () async throws -> Void
    @ViewBuilder var label: () -> V
    
    public init(
        title: String? = nil,
        systemImage: String? = nil,
        role: ButtonRole? = nil,
        action: @escaping () async throws -> Void,
        label: @escaping () -> V = { EmptyView() }
    ) {
        self.title = title
        self.systemImage = systemImage
        self.role = role
        self.action = action
        self.label = label
    }
    
    public var body: some View {
        Button(role: role) {
            Task { try await action() }
        } label: {
            if V.self != EmptyView.self {
                label()
            } else {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                if let title {
                    Text(title.localized())
                }
            }
        }
        .buttonStyle(.borderless)
    }
}

/// 简单的确认用的按钮（默认Title是确认）
public struct SimpleConfirmButton<V: View>: View {
    let title: String?
    let systemImage: String?
    let role: ButtonRole?
    
    @ViewBuilder var label: () -> V
    let action: () -> Void
    
    public init(
        title: String? = "Confirm",
        systemImage: String? = nil,
        role: ButtonRole? = nil,
        action: @escaping () -> Void,
        label: @escaping () -> V = { EmptyView() }
    ) {
        self.title = title
        self.systemImage = systemImage
        self.role = role
        self.label = label
        self.action = action
    }
    
    public var body: some View {
        Button(role: role, action: action, label: {
            if V.self != EmptyView.self {
                label()
            } else {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                if let title {
                    Text(title.localized())
                }
            }
        })
        .buttonStyle(.borderless)
    }
}

/// 简单的开关，点击后切换 isPresented 的值
public struct SimpleTriggerButton<V: View>: View {
    let title: String?
    let systemImage: String?
    
    @ViewBuilder var label: () -> V
    @Binding var isPresented: Bool
    
    public init(
        title: String? = "Trigger",
        systemImage: String? = nil,
        isPresented: Binding<Bool>,
        label: @escaping () -> V = { EmptyView() }
    ) {
        self.title = title
        self.systemImage = systemImage
        self._isPresented = isPresented
        self.label = label
    }
    
    public var body: some View {
        Button(role: .none, action: {
            isPresented.toggle()
        }, label: {
            if V.self != EmptyView.self {
                label()
            }else {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                if let title {
                    Text(title.localized())
                }
            }
        })
        .buttonStyle(.borderless)
    }
}

#Preview(
    "Button",
    body: {
        @Previewable @State var isPresent: Bool = false
        @Previewable @State var isLoading: Bool = false
        @Previewable @State var isNetworkWording: Bool?
        @Previewable @State var showConfirm: Bool = false
        
        NavigationStack {
            Form {
                Section {
                    SimpleMiddleButton("Middle Button") {}
                    SimpleMiddleButton(
                        "Middle Button",
                        role: .destructive,
                        rowVisibility: .visible
                    ) {}.tint(.red)
                }
                Section {
                    SimpleTriggerButton(
                        isPresented: $isPresent
                    ) {
                        Text(isPresent.toString())
                    }
                }
                Section {
                    SimpleConfirmButton(
                        title: "显示对话框"
                    ) {
                        showConfirm = true
                    }
                    SimpleConfirmButton(
                        title: "自定义标题",
                        role: .destructive
                    ) {}
                }
                Section {
                    SimpleAsyncButton {
                        isLoading = true
                        do {
                            isNetworkWording = try await SimpleWeb().isNetworkAvailable()
                        }catch {
                            debugPrint(error)
                        }
                        isLoading = false
                    } label: {
                        SimpleCell("多线程任务") {
                            if isLoading {
                                ProgressView()
                            }else if let isNetworkWording {
                                Text(isNetworkWording ? "连接" : "断开")
                                    .simpleTag(.border(contentColor: isNetworkWording ? . green : .red))
                            }
                        }
                    }
                }
                .navigationTitle("按钮类型")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.large)
                #endif
        }
        .formStyle(.grouped)
        .buttonCircleNavi(role: .cancel, title: "测试按钮")
        .buttonCircleNavi(role: .destructive, isLoading: false)
        .confirmationDialog(
            "测试按钮",
            isPresented: $showConfirm,
            titleVisibility: .visible
        ) {
            SimpleTriggerButton(
                title: "切换载入",
                isPresented: $isLoading
            )
            SimpleTriggerButton(
                title: "切换显示",
                isPresented: $isPresent
            )
        }
    }
})

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
    public func buttonCircleNavi(role: ButtonRole? = nil,
                                 title: String? = nil,
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
                                  title: title,
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

#if !os(watchOS)
struct ButtonShortkey: ViewModifier {
    let role: ButtonRole?
    let key: KeyEquivalent?
    let modifiers: EventModifiers?
    
    func body(content: Content) -> some View {
        if role == .cancel {
            content
                .keyboardShortcut(.escape)
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
