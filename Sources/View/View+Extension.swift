//
//  File.swift
//
//
//  Created by AmosFitness on 2023/11/10.
//

import SwiftUI

public enum AmosError: Error, Equatable, LocalizedError {
    case customError(msg: String)
    
    public var errorDescription: String? {
        switch self {
        case .customError(let msg):
            return msg
        }
    }
}

/// 判断是否处于 Preview 环境
public let isPreviewCondition: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

public extension Binding {
    static func isPresented<V>(_ value: Binding<V?>) -> Binding<Bool> {
        Binding<Bool>(
            get: { value.wrappedValue != nil },
            set: { if !$0 { value.wrappedValue = nil } }
        )
    }
}

#if !os(watchOS)
public extension UIView {
    // This is the function to convert UIView to UIImage
    func asUIImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

public extension View {
    /// 可以将 Image 转换为 UIImage
    func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        
        // Set the background to be transparent incase the image is a PNG, WebP or (Static) GIF
        controller.view.backgroundColor = .clear
        
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        scene?.windows.first?.rootViewController?.view.addSubview(controller.view)
        
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()
        
        // here is the call to the function that converts UIView to UIImage: `.asUIImage()`
        let image = controller.view.asUIImage()
        controller.view.removeFromSuperview()
        return image
    }
}
#endif
    
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
                    imageLength: imageLength,
                    title: title,
                    subtitle: subtitle,
                    content: contentText,
                    themeColor: themeColor,
                    imageColor: imageColor,
                    titleColor: titleColor,
                    subtitleColor: subtitleColor,
                    contentColor: contentColor,
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
    let systemImageName: String?
    let imageName: String?
    let imageLength: CGFloat
    let title: String
    let subtitle: String?
    let content: String?
    
    let themeColor: Color?
    let imageColor: Color
    let titleColor: Color
    let subtitleColor: Color
    let contentColor: Color
    
    let offsetY: CGFloat
    let maxWidth: CGFloat
    @ViewBuilder let buttonView: () -> V
    
    @State private var isAnimate = false
    
    public init(systemImageName: String? = nil,
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
                @ViewBuilder buttonView: @escaping () -> V = { EmptyView() }) {
        self.systemImageName = systemImageName
        self.imageName = imageName
        self.imageLength = imageLength
        self.title = title
        self.subtitle = subtitle
        self.content = content
        self.offsetY = offsetY
        self.maxWidth = maxWidth
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
        VStack(spacing: 15) {
            if let systemImageName {
                Image(systemName: systemImageName)
                    .imageModify(color: imageColor, length: imageLength)
                    .modifier(TapImageAnimation())
            }else if let imageName {
                Image(imageName)
                    .imageModify(length: imageLength)
                    .modifier(TapImageAnimation())
            }
            VStack(spacing: 8) {
                Text(title)
                    .font(.title)
                    .foregroundStyle(titleColor)
                    .lineLimit(1)
                if let subtitle {
                    Text(subtitle)
                        .font(.headline)
                        .foregroundStyle(subtitleColor)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if let content {
                    Text(content)
                        .font(.footnote)
                        .foregroundStyle(contentColor)
                        .lineLimit(10)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            buttonView()
        }
        .frame(maxWidth: maxWidth)
        .offset(x: 0, y: offsetY)
    }
}

struct TapImageAnimation: ViewModifier {
    // the animation is triggered each time the value changes
    @State private var isAnimate: Bool = false
    
    func body(content: Content) -> some View {
        if #available(iOS 17, *) {
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
                       systemImageName: "list.clipboard",
                       title: "Title Title",
                       subtitle: "Subtitle Subtitle Subtitle Subtitle Subtitle Subtitle",
                       content: "content content content content content content content content content content content content content content content content") {
        Button("Button") {}
            .buttonStyle(.borderedProminent)
    }
}
