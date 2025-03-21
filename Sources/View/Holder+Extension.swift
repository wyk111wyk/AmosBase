//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2023/11/14.
//

import SwiftUI

public extension View {
    /// 简单UI组件 -  定制化的占位符
    ///
    /// 设置 themeColor 后替代所有颜色
    ///
    /// 可添加自定义的 Button 或者其他 View
    func simplePlaceholder<V: View>(
        isPresent: Bool,
        type: SimplePlaceholderType? = nil,
        systemImageName: String? = nil,
        imageName: String? = nil,
        imageLength: CGFloat? = nil,
        imagePadding: CGFloat? = nil,
        title: String,
        subtitle: String? = nil,
        content: String? = nil,
        titleFont: Font? = nil,
        subtitleFont: Font? = nil,
        contentFont: Font? = nil,
        themeColor: Color? = nil,
        imageColor: Color = .primary,
        titleColor: Color = .primary,
        subtitleColor: Color = .gray,
        contentColor: Color = .secondary,
        offsetY: CGFloat? = nil,
        maxWidth: CGFloat? = nil,
        @ViewBuilder buttonView: @escaping () -> V = { EmptyView() }) -> some View {
            modifier(
                SimplePlaceholderModify(
                    isPresent: isPresent,
                    type: type,
                    systemImageName: systemImageName,
                    imageName: imageName,
                    title: title,
                    subtitle: subtitle,
                    contentText: content,
                    titleFont: titleFont,
                    subtitleFont: subtitleFont,
                    contentFont: contentFont,
                    themeColor: themeColor,
                    imageColor: imageColor,
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                    contentColor: contentColor,
                    imageLength: imageLength,
                    imagePadding: imagePadding,
                    offsetY: offsetY,
                    maxWidth: maxWidth,
                    buttonView: buttonView
                )
            )
        }
}

struct SimplePlaceholderModify<V: View>: ViewModifier {
    let isPresent: Bool
    let type: SimplePlaceholderType?
        
    var systemImageName: String? = nil
    var imageName: String? = nil
    var title: String
    var subtitle: String? = nil
    var contentText: String? = nil
    
    var titleFont: Font? = nil
    var subtitleFont: Font? = nil
    var contentFont: Font? = nil
    
    var themeColor: Color? = nil
    var imageColor: Color = .primary
    var titleColor: Color = .primary
    var subtitleColor: Color = .gray
    var contentColor: Color = .secondary
    
    var imageLength: CGFloat? = nil
    var imagePadding: CGFloat? = nil
    var offsetY: CGFloat? = nil
    var maxWidth: CGFloat? = nil
    @ViewBuilder var buttonView: () -> V
    
    func body(content: Content) -> some View {
        if isPresent {
            content.overlay(alignment: .center) {
                SimplePlaceholder(
                    type: type,
                    systemImageName: systemImageName,
                    imageName: imageName,
                    title: title,
                    subtitle: subtitle,
                    content: contentText,
                    themeColor: themeColor,
                    imageColor: imageColor,
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                    contentColor: contentColor,
                    imageLength: imageLength,
                    imagePadding: imagePadding,
                    offsetY: offsetY,
                    maxWidth: maxWidth,
                    buttonView: buttonView)
            }
        }else {
            content
        }
    }
}

public enum SimplePlaceholderType: String, Identifiable, CaseIterable {
    case listEmpty, star, allDone, map, edit, alert, lock, bell, bookmark, clock, done, pencil, target, thumbUp
    
    public var id: String {
        self.rawValue
    }
    
    var image: Image {
        switch self {
        case .listEmpty: .init(bundle: .module, packageResource: "empty", ofType: "heic")
        case .star: .init(bundle: .module, packageResource: "star", ofType: "heic")
        case .allDone: .init(bundle: .module, packageResource: "allDone", ofType: "heic")
        case .map: .init(bundle: .module, packageResource: "map", ofType: "heic")
        case .edit: .init(bundle: .module, packageResource: "edit", ofType: "heic")
        case .alert: .init(bundle: .module, packageResource: "alert", ofType: "heic")
        case .lock: .init(bundle: .module, packageResource: "lock", ofType: "heic")
        case .bell: .init(bundle: .module, packageResource: "bell", ofType: "heic")
        case .bookmark: .init(bundle: .module, packageResource: "bookmark", ofType: "heic")
        case .clock: .init(bundle: .module, packageResource: "clock", ofType: "heic")
        case .done: .init(bundle: .module, packageResource: "done", ofType: "heic")
        case .pencil: .init(bundle: .module, packageResource: "edit2", ofType: "heic")
        case .target: .init(bundle: .module, packageResource: "target", ofType: "heic")
        case .thumbUp: .init(bundle: .module, packageResource: "thumb", ofType: "heic")
        }
    }
    
    var title: String {
        switch self {
        case .listEmpty: "内容为空"
        case .star: "收藏夹"
        case .allDone: "全部完成"
        case .map: "授权地点"
        case .edit: "编辑"
        case .alert: "警告"
        case .lock: "锁定"
        case .bell: "通知"
        case .bookmark: "收藏夹"
        case .clock: "时钟"
        case .done: "完成"
        case .pencil: "编辑"
        case .target: "目标"
        case .thumbUp: "点赞"
        }
    }
}

/// 简单UI组件 -  定制化的占位符
///
/// 设置 themeColor 后替代所有颜色
///
/// 可添加自定义的 Button 或者其他 View
public struct SimplePlaceholder<V: View>: View {
    let type: SimplePlaceholderType?
    
    let systemImageName: String?
    let imageName: String?
    let title: String
    let subtitle: String?
    let content: String?
    
    let themeColor: Color?
    let imageColor: Color
    let titleColor: Color
    let subtitleColor: Color
    let contentColor: Color
    
    var imageLength: CGFloat
    var imagePadding: CGFloat?
    var titleFont: Font
    var subtitleFont: Font
    var contentFont: Font
    var contentSpace: CGFloat
    var offsetY: CGFloat
    var maxWidth: CGFloat
    @ViewBuilder let buttonView: () -> V
    
    @State private var isBounce = false
    @State private var isHiden = false
    
    public init(
        type: SimplePlaceholderType? = nil,
        systemImageName: String? = nil,
        imageName: String? = nil,
        title: String,
        subtitle: String? = nil,
        content: String? = nil,
        themeColor: Color? = nil,
        imageColor: Color = .primary,
        titleColor: Color = .primary,
        subtitleColor: Color = .gray,
        contentColor: Color = .secondary,
        imageLength: CGFloat? = nil,
        imagePadding: CGFloat? = nil,
        titleFont: Font? = nil,
        subtitleFont: Font? = nil,
        contentFont: Font? = nil,
        contentSpace: CGFloat? = nil,
        offsetY: CGFloat? = nil,
        maxWidth: CGFloat? = nil,
        @ViewBuilder buttonView: @escaping () -> V = { EmptyView() }
    ) {
        self.type = type
        self.systemImageName = systemImageName
        self.imageName = imageName
        self.title = title
        self.subtitle = subtitle
        self.content = content
        self.buttonView = buttonView
        
        // 样式设计
        #if os(watchOS)
        self.titleFont = .system(size: 22, weight: .medium)
        self.subtitleFont = .system(size: 15, weight: .medium)
        self.contentFont = .footnote
        self.imageLength = 76
        self.imagePadding = 6
        self.contentSpace = 12
        self.offsetY = 0
        self.maxWidth = 140
        #elseif os(iOS)
        self.titleFont = .title
        self.subtitleFont = .headline
        self.contentFont = .footnote
        self.imageLength = 130
        self.imagePadding = 30
        self.contentSpace = 15
        self.offsetY = -26
        self.maxWidth = 250
        #elseif os(macOS) || targetEnvironment(macCatalyst)
        self.titleFont = .title
        self.subtitleFont = .headline
        self.contentFont = .body
        self.imageLength = 100
        self.imagePadding = 24
        self.contentSpace = 18
        self.offsetY = -10
        self.maxWidth = 300
        #endif
        
        // 用户配置
        if let titleFont {
            self.titleFont = titleFont
        }
        if let subtitleFont {
            self.subtitleFont = subtitleFont
        }
        if let contentFont {
            self.contentFont = contentFont
        }
        if let imageLength {
            self.imageLength = imageLength
        }
        if let imagePadding {
            self.imagePadding = imagePadding
        }
        if let contentSpace {
            self.contentSpace = contentSpace
        }
        if let offsetY {
            self.offsetY = offsetY
        }
        if let maxWidth {
            self.maxWidth = maxWidth
        }
        
        // 主题颜色
        self.themeColor = themeColor
        if let themeColor {
            self.imageColor = themeColor
            self.titleColor = themeColor
            self.subtitleColor = themeColor
            self.contentColor = themeColor
        }else {
            self.imageColor = imageColor
            self.titleColor = titleColor
            self.subtitleColor = subtitleColor
            self.contentColor = contentColor
        }
    }
    
    public var body: some View {
        #if os(watchOS)
        ScrollView {
            placeHolderContent()
        }
        #else
        placeHolderContent()
            .ignoresSafeArea(.keyboard)
        #endif
    }
    
    private func placeHolderContent() -> some View {
        VStack(spacing: contentSpace) {
            Group {
                if let type {
                    type.image
                        .imageModify(length: imageLength)
                }else if let systemImageName {
                    Image(systemName: systemImageName)
                        .imageModify(color: imageColor, length: imageLength)
                }else if let imageName {
                    Image(imageName)
                        .imageModify(length: imageLength)
                }
            }
            .modifier(BounceModifier(isToggled: isBounce))
            .opacity(isHiden ? 0.5 : 1)
            .onTapGesture {
                #if os(iOS) || os(watchOS)
                withAnimation {
                    isHiden.toggle()
                }
                #else
                isBounce.toggle()
                #endif
            }
            #if os(watchOS)
            .padding(.top, 30)
            #endif
            .padding(.bottom, imagePadding)
            if !isHiden {
                VStack(spacing: contentSpace/2) {
                    Text(LocalizedStringKey(title))
                        .font(titleFont)
                        .foregroundStyle(titleColor)
                        .lineLimit(1)
                    if let subtitle {
                        Text(LocalizedStringKey(subtitle))
                            .font(subtitleFont)
                            .foregroundStyle(subtitleColor)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    if let content {
                        Text(LocalizedStringKey(content))
                            .font(contentFont)
                            .lineLimit(8)
                            .foregroundStyle(contentColor)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                #if os(iOS)
                .onTapGesture {
                    withAnimation {
                        isHiden = true
                    }
                }
                #endif
                
                if V.self != EmptyView.self {
                    buttonView()
                        .padding(.top, contentSpace/2)
                }
            }
        }
        .frame(maxWidth: maxWidth)
        .offset(x: 0, y: offsetY)
    }
}

#Preview("Placeholder") {
    DemoSimplePlaceholder()
    #if os(macOS)
    .frame(minWidth: 500, minHeight: 400)
    #endif
}
