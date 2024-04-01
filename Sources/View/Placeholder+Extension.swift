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
        systemImageName: String? = nil,
        imageName: String? = nil,
        imageLength: CGFloat = 90,
        title: String,
        subtitle: String? = nil,
        content: String? = nil,
        themeColor: Color? = nil,
        imageColor: Color = .primary,
        titleColor: Color = .primary,
        subtitleColor: Color = .gray,
        contentColor: Color = .secondary,
        offsetY: CGFloat = -30,
        maxWidth: CGFloat = 250,
        @ViewBuilder buttonView: @escaping () -> V = { EmptyView() }) -> some View {
            modifier(SimplePlaceholderModify(isPresent: isPresent,
                                             systemImageName: systemImageName,
                                             imageName: imageName,
                                             imageLength: imageLength,
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
                                             buttonView: buttonView))
        }
}

struct SimplePlaceholderModify<V: View>: ViewModifier {
    let isPresent: Bool
    
    var systemImageName: String? = nil
    var imageName: String? = nil
    var imageLength: CGFloat = 90
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
                    offsetY: offsetY,
                    maxWidth: maxWidth,
                    buttonView: buttonView)
            }
        }else {
            content
        }
    }
}

/// 简单UI组件 -  定制化的占位符
///
/// 设置 themeColor 后替代所有颜色
///
/// 可添加自定义的 Button 或者其他 View
public struct SimplePlaceholder<V: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
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
    let titleFont: Font
    let contentSpace: CGFloat
    let offsetY: CGFloat
    let maxWidth: CGFloat
    @ViewBuilder let buttonView: () -> V
    
    @State private var isAnimate = false
    
    public init(systemImageName: String? = nil,
                imageName: String? = nil,
                title: String,
                subtitle: String? = nil,
                content: String? = nil,
                themeColor: Color? = nil,
                imageColor: Color = .primary,
                titleColor: Color = .primary,
                subtitleColor: Color = .gray,
                contentColor: Color = .secondary,
                imageLength: CGFloat = 90,
                titleFont: Font = .title,
                contentSpace: CGFloat = 15,
                offsetY: CGFloat = -30,
                maxWidth: CGFloat = 250,
                @ViewBuilder buttonView: @escaping () -> V = { EmptyView() }) {
        self.systemImageName = systemImageName
        self.imageName = imageName
        self.title = title
        self.subtitle = subtitle
        self.content = content
        
        #if os(watchOS)
        self.titleFont = .system(size: 20, weight: .medium)
        self.imageLength = 50
        self.contentSpace = 8
        self.offsetY = 0
        self.maxWidth = 120
        #else
        self.titleFont = titleFont
        self.imageLength = imageLength
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
            if let systemImageName {
                Image(systemName: systemImageName)
                    .imageModify(color: imageColor, length: imageLength)
                    .modifier(TapImageAnimation())
            }else if let imageName {
                Image(imageName)
                    .imageModify(length: imageLength)
                    .modifier(TapImageAnimation())
            }
            VStack(spacing: contentSpace/2) {
                Text(LocalizedStringKey(title))
                    .font(titleFont)
                    .foregroundStyle(titleColor)
                    .lineLimit(1)
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
            }
            buttonView()
        }
        .frame(maxWidth: maxWidth)
        .offset(x: 0, y: horizontalSizeClass == .regular ? 0 : offsetY)
    }
}

struct TapImageAnimation: ViewModifier {
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
    NavigationView {
        VStack {
            Text("")
        }
        .navigationTitle("Navi Title")
    }
#if canImport(UIKit)
    .navigationViewStyle(.stack)
    #endif
    .simplePlaceholder(isPresent: true,
                       systemImageName: "list.clipboard",
                       title: "Title Title",
                       subtitle: "Subtitle Subtitle Subtitle",
                       content: "content content content content content content content") {
        Button("Button") {}
            .buttonStyle(.borderedProminent)
    }
}
