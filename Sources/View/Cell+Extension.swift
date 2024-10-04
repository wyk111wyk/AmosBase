//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2023/11/14.
//

import SwiftUI


/// 简单UI组件 -  多样的表格Cell
///
/// 使用自定义的State内容，需要添加Spacer()
public struct SimpleCell<V: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let isDisplay: Bool // 是否展示
    
    let title: String
    let titleFont: Font
    let titleColor: Color?
    
    let iconName: String?
    let systemImage: String?
    let bundleImageName: String?
    let bundleImageNameDark: String?
    let bundleImageType: String?
    let sfImage: SFImage?
    let numberIcon: Int?
    let iconColor: Color?
    
    let contentSystemImage: String?
    let content: String?
    let contentLine: Int?
    let contentFont: Font
    let contentColor: Color?
    
    let imageSize: Double
    let contentSpace: Double
    
    let stateText: String?
    @ViewBuilder let stateView: () -> V
    let stateWidth: CGFloat
    
    public let localizationBundle: Bundle
    
    public init(
        _ title: String,
        titleFont: Font = .body,
        titleColor: Color? = nil,
        iconName: String? = nil,
        systemImage: String? = nil,
        bundleImageName: String? = nil,
        bundleImageNameDark: String? = nil,
        bundleImageType: String? = nil,
        sfImage: SFImage? = nil,
        imageSize: Double = 22,
        numberIcon: Int? = nil,
        iconColor: Color? = nil,
        contentSystemImage: String? = nil,
        content: String? = nil,
        contentLine: Int? = nil,
        contentFont: Font = .caption,
        contentColor: Color? = .secondary,
        isDisplay: Bool = true,
        contentSpace: Double = 12,
        stateText: String? = nil,
        stateWidth: CGFloat = 100,
        localizationBundle: Bundle = .main,
        @ViewBuilder stateView: @escaping () -> V = { EmptyView() }
    ) {
        self.isDisplay = isDisplay
        self.title = title
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.contentSystemImage = contentSystemImage
        self.content = content
        self.contentLine = contentLine
        self.contentFont = contentFont
        self.contentColor = contentColor
        self.iconName = iconName
        self.systemImage = systemImage
        self.numberIcon = numberIcon
        self.iconColor = iconColor
        self.bundleImageName = bundleImageName
        self.bundleImageNameDark = bundleImageNameDark
        self.bundleImageType = bundleImageType
        self.sfImage = sfImage
        
        self.imageSize = imageSize
        self.contentSpace = contentSpace
        self.stateText = stateText
        self.stateWidth = stateWidth
        self.stateView = stateView
        
        self.localizationBundle = localizationBundle
    }
    
    
    public var body: some View {
        if isDisplay {
            HStack(alignment: .center, spacing: contentSpace) {
                // 图标 icon
                if let iconName = iconName {
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize, height: imageSize)
                }else if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .frame(width: imageSize, height: imageSize)
                        .foregroundColor(iconColor)
                }else if let bundleImageName, let bundleImageType {
                    if let bundleImageNameDark {
                        if colorScheme == .dark {
                            Image(packageResource: bundleImageNameDark, ofType: bundleImageType)
                                .resizable()
                                .scaledToFit()
                                .frame(width: imageSize, height: imageSize)
                        }else {
                            Image(packageResource: bundleImageName, ofType: bundleImageType)
                                .resizable()
                                .scaledToFit()
                                .frame(width: imageSize, height: imageSize)
                        }
                    }else {
                        Image(packageResource: bundleImageName, ofType: bundleImageType)
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageSize, height: imageSize)
                    }
                }else if let sfImage {
                    Image(sfImage: sfImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize, height: imageSize)
                }else if let numberIcon {
                    ZStack {
                        Circle().stroke(iconColor ?? .primary)
                        Text(numberIcon.toString())
                            .minimumScaleFactor(0.6)
                            .padding(3)
                    }
                    .frame(width: imageSize, height: imageSize)
                    .foregroundColor(iconColor)
                }
                // Title 和 Content
                VStack(alignment: .leading, spacing: 5) {
                    Text(LocalizedStringKey(title), bundle: localizationBundle)
                        .font(titleFont)
                        .foregroundColor(titleColor)
                        .multilineTextAlignment(.leading)
                    Group {
                        if let content = content, !content.isEmpty,
                           let contentSystemImage = contentSystemImage, contentSystemImage.count > 0 {
                            Text("\(Image(systemName: contentSystemImage))\(content.localized(bundle: localizationBundle))")
                        } else if let content = content, content.count > 0 {
                            Text(LocalizedStringKey(content), bundle: localizationBundle)
                        }
                    }
                    .foregroundColor(contentColor)
                    .font(contentFont)
                    .lineLimit(contentLine)
                    .multilineTextAlignment(.leading)
                }
                
                if V.self != EmptyView.self || stateText != nil {
                    Spacer(minLength: 0)
                    Group {
                        if let stateText = stateText {
                            Text(LocalizedStringKey(stateText), bundle: localizationBundle)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }else {
                            stateView()
                        }
                    }
                }
            }
            #if !os(watchOS)
            .textSelection(.enabled)
            #endif
        }
    }
}

#Preview("Cell") {
    DemoSimpleButton()
}
