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
        imageLength: CGFloat = 180,
        imagePadding: CGFloat? = 80,
        title: String,
        subtitle: String? = nil,
        content: String? = nil,
        themeColor: Color? = nil,
        imageColor: Color = .primary,
        titleColor: Color = .primary,
        subtitleColor: Color = .gray,
        contentColor: Color = .secondary,
        offsetY: CGFloat = 0,
        maxWidth: CGFloat = 250,
        @ViewBuilder buttonView: @escaping () -> V = { EmptyView() }) -> some View {
            modifier(
                SimplePlaceholderModify(
                    isPresent: isPresent,
                    type: type,
                    systemImageName: systemImageName,
                    imageName: imageName,
                    imageLength: imageLength,
                    imagePadding: imagePadding,
                    title: title,
                    subtitle: subtitle,
                    contentText: content,
                    themeColor: themeColor,
                    imageColor: imageColor,
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                    contentColor: contentColor,
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
    var imageLength: CGFloat = 120
    var imagePadding: CGFloat? = 80
    var title: String
    var subtitle: String? = nil
    var contentText: String? = nil
    
    var themeColor: Color? = nil
    var imageColor: Color = .primary
    var titleColor: Color = .primary
    var subtitleColor: Color = .gray
    var contentColor: Color = .secondary
    
    var offsetY: CGFloat = -30
    var maxWidth: CGFloat = 250
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

public enum SimplePlaceholderType: String, Identifiable {
    case listEmpty, favorEmpty, allDone, map
    
    static var allCases: [SimplePlaceholderType] {
        [.listEmpty, .favorEmpty, .allDone, .map]
    }
    
    public var id: String {
        self.rawValue
    }
    
    var image: Image {
        switch self {
        case .listEmpty:
            return .init(packageResource: "empty", ofType: "png")
        case .favorEmpty:
            return .init(packageResource: "star", ofType: "png")
        case .allDone:
            return .init(packageResource: "allDone", ofType: "png")
        case .map:
            return .init(packageResource: "map", ofType: "png")
        }
    }
    
    var title: String {
        switch self {
        case .listEmpty:
            "内容为空"
        case .favorEmpty:
            "收藏夹"
        case .allDone:
            "全部完成"
        case .map:
            "授权地点"
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
    
    let imageLength: CGFloat
    let imagePadding: CGFloat?
    let titleFont: Font
    let contentSpace: CGFloat
    let offsetY: CGFloat
    let maxWidth: CGFloat
    @ViewBuilder let buttonView: () -> V
    
    @State private var isAnimate = false
    
    public init(type: SimplePlaceholderType? = nil,
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
                imageLength: CGFloat = 120,
                imagePadding: CGFloat? = 80,
                titleFont: Font = .title,
                contentSpace: CGFloat = 15,
                offsetY: CGFloat = -10,
                maxWidth: CGFloat = 250,
                @ViewBuilder buttonView: @escaping () -> V = { EmptyView() }) {
        self.type = type
        self.systemImageName = systemImageName
        self.imageName = imageName
        self.title = title
        self.subtitle = subtitle
        self.content = content
        
        #if os(watchOS)
        self.titleFont = .system(size: 20, weight: .medium)
        self.imageLength = 50
        self.imagePadding = 8
        self.contentSpace = 8
        self.offsetY = 0
        self.maxWidth = 120
        #else
        self.titleFont = titleFont
        self.imageLength = imageLength
        self.imagePadding = imagePadding
        self.contentSpace = contentSpace
        self.offsetY = offsetY
        self.maxWidth = maxWidth
        #endif
        self.buttonView = buttonView
        
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
        VStack(spacing: contentSpace) {
            Group {
                if let type {
                    type.image
                        .imageModify(length: imageLength)
                        .modifier(TapImageAnimation())
                }else if let systemImageName {
                    Image(systemName: systemImageName)
                        .imageModify(color: imageColor, length: imageLength)
                        .modifier(TapSystemIconAnimation())
                }else if let imageName {
                    Image(imageName)
                        .imageModify(length: imageLength)
                        .modifier(TapImageAnimation())
                }
            }
            .padding(.bottom, imagePadding)
            VStack(spacing: contentSpace/2) {
                Text(LocalizedStringKey(title))
                    .font(titleFont)
                    .foregroundStyle(titleColor)
                    .lineLimit(1)
                #if !os(watchOS)
                if let subtitle {
                    Text(LocalizedStringKey(subtitle))
                        .font(.headline)
                        .foregroundStyle(subtitleColor)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if let content {
                    Text(LocalizedStringKey(content))
                        .font(.footnote)
                        .lineLimit(8)
                        .foregroundStyle(contentColor)
                        .fixedSize(horizontal: false, vertical: true)
                }
                #endif
            }
            buttonView()
        }
        .frame(maxWidth: maxWidth)
        .offset(x: 0, y: offsetY)
    }
}

struct TapImageAnimation: ViewModifier {
    @State private var isScaled: Bool = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isScaled ? 1.1 : 1.0)
            .animation(
                Animation.interpolatingSpring(
                    stiffness: 60,
                    damping: 3
                ).repeatCount(1, autoreverses: false),
                value: isScaled
            )
            .onTapGesture {
                isScaled = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isScaled = false
                }
            }
    }
}

struct TapSystemIconAnimation: ViewModifier {
    // the animation is triggered each time the value changes
    @State private var isAnimate: Bool = false
    
    func body(content: Content) -> some View {
        if #available(iOS 17, watchOS 10, macOS 14.0, *) {
            content
                .symbolEffect(.bounce, value: isAnimate)
                .onTapGesture {
                    self.isAnimate.toggle()
                }
        }else {
            content
        }
    }
}

#Preview("Placeholder") {
    NavigationStack {
        VStack {
            Text("")
        }
        .navigationTitle("Navi Title")
    }
    .simplePlaceholder(isPresent: true,
                       type: .favorEmpty,
                       systemImageName: "list.clipboard",
                       title: "Title Title",
                       subtitle: "Subtitle Subtitle Subtitle",
                       content: "content content content content content content content") {
        Button("Button") {}
            .buttonStyle(.borderedProminent)
    }
}
