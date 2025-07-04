//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2023/11/14.
//

import SwiftUI

/*
 使用方式：在任何页面添加：
 typealias SimpleCell = _SimpleCell
 */
public typealias _SimpleCell = SimpleCell

/// 简单UI组件 -  多样的表格Cell
///
/// 使用自定义的State内容，需要添加Spacer()
public struct SimpleCell<V: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let isDisplay: Bool // 是否展示
    let isPushButton: Bool // 是否是Navi
    let isCellButton: Bool // 是否是列表中的按钮（右侧填充空白）
    let purchaseLevel: PurchaseLevel? // 是否是Premium
    // Title
    let titleSystemImage: String?
    let titleImageColor: Color?
    let title: String
    let titleLine: Int?
    let titleFont: Font
    let titleColor: Color?
    // SubTitle
    let subtitle: String?
    let subtitleLine: Int?
    // Icon
    let iconName: String?
    let systemImage: String?
    let bundleImageName: String?
    let bundleImageNameDark: String?
    let bundleImageType: String?
    let sfImage: SFImage?
    let numberIcon: Int?
    let iconColor: Color?
    let imageSize: Double
    // content
    let contentSystemImage: String?
    let content: String?
    let contentSubfix: String?
    let contentLine: Int?
    let contentFont: Font
    let contentColor: Color?
    let contentSpace: Double
    // state
    let stateText: String?
    @ViewBuilder let stateView: () -> V
    
    public let localizationBundle: Bundle
    
    public init(
        _ title: String,
        titleSystemImage: String? = nil,
        titleImageColor: Color? = nil,
        titleLine: Int? = nil,
        titleFont: Font = .body,
        titleColor: Color? = nil,
        subtitle: String? = nil,
        subtitleLine: Int? = 1,
        iconName: String? = nil,
        systemImage: String? = nil,
        bundleImageName: String? = nil,
        bundleImageNameDark: String? = nil,
        bundleImageType: String? = nil,
        sfImage: SFImage? = nil,
        imageSize: Double = 22,
        numberIcon: Int? = nil,
        iconColor: Color? = nil,
        content: String? = nil,
        contentSubfix: String? = nil,
        contentLine: Int? = nil,
        contentFont: Font = .caption,
        contentColor: Color? = .secondary,
        contentSystemImage: String? = nil,
        isDisplay: Bool = true,
        isPushButton: Bool = false,
        isCellButton: Bool = true,
        purchaseLevel: PurchaseLevel? = nil,
        contentSpace: Double = 12,
        stateText: String? = nil,
        localizationBundle: Bundle = .main,
        @ViewBuilder stateView: @escaping () -> V = { EmptyView() }
    ) {
        self.isDisplay = isDisplay
        self.isPushButton = isPushButton
        self.isCellButton = isCellButton
        self.purchaseLevel = purchaseLevel
        
        self.title = title
        self.titleSystemImage = titleSystemImage
        self.titleImageColor = titleImageColor
        self.titleLine = titleLine
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.subtitle = subtitle
        self.subtitleLine = subtitleLine
        self.contentSystemImage = contentSystemImage
        self.content = content
        self.contentSubfix = contentSubfix
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
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize, height: imageSize)
                        .foregroundColor(iconColor)
                }else if let bundleImageName, let bundleImageType {
                    if let bundleImageNameDark {
                        if colorScheme == .dark {
                            Image(bundle: localizationBundle, packageResource: bundleImageNameDark, ofType: bundleImageType)
                                .resizable()
                                .scaledToFit()
                                .frame(width: imageSize, height: imageSize)
                        }else {
                            Image(bundle: localizationBundle, packageResource: bundleImageName, ofType: bundleImageType)
                                .resizable()
                                .scaledToFit()
                                .frame(width: imageSize, height: imageSize)
                        }
                    }else {
                        Image(bundle: localizationBundle, packageResource: bundleImageName, ofType: bundleImageType)
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
                        Circle()
                            .stroke(lineWidth: 1)
                        Text(numberIcon.toString())
                            .minimumScaleFactor(0.5)
                            .padding(2)
                    }
                    .frame(width: imageSize, height: imageSize)
                    .foregroundColor(iconColor)
                }
                
                // Title 和 Content
                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        HStack(alignment: .top, spacing: 6) {
                            if let titleSystemImage {
                                Image(systemName: titleSystemImage)
                                    .foregroundColor(titleImageColor)
                                    .font(.body)
                                    .layoutPriority(1)
                                    .offset(y: 1)
                            }
                            HStack(alignment: .center, spacing: 6) {
                                Text(LocalizedStringKey(title), bundle: localizationBundle)
                                    .font(titleFont)
                                    .foregroundColor(titleColor)
                                    .lineLimit(titleLine)
                                    .multilineTextAlignment(.leading)
                                    .layoutPriority(1)
                                if let purchaseLevel {
                                    purchaseLevel.logoImage
                                        .resizable().scaledToFit()
                                        .frame(height: 13)
                                        .layoutPriority(2)
                                }
                            }
                        }
                        
                        if let subtitle {
                            Text(LocalizedStringKey(subtitle), bundle: localizationBundle)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .lineLimit(subtitleLine)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    
                    if let content = content, !content.isEmpty {
                        HStack(alignment: .top, spacing: 4) {
                            if let contentSystemImage {
                                Image(systemName: contentSystemImage)
                                    .foregroundColor(contentColor)
                                    .font(.footnote)
                            }
                            Text(LocalizedStringKey(content), bundle: localizationBundle)
                                .foregroundColor(contentColor)
                                .font(contentFont)
                                .lineLimit(contentLine)
                                .multilineTextAlignment(.leading)
                            
                            if let contentSubfix {
                                Text(LocalizedStringKey(contentSubfix), bundle: localizationBundle)
                                    .foregroundColor(contentColor)
                                    .font(contentFont)
                                    .lineLimit(contentLine)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    }
                }
                
                if isPushButton || V.self != EmptyView.self || stateText != nil || isCellButton {
                    Spacer()
                }
                
                if V.self != EmptyView.self || stateText != nil {
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
                
                if isPushButton {
                    Image(systemName: "chevron.right")
                        .imageScale(.small)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
            }
            .contentShape(Rectangle())
            .selectableText()
        }
    }
}

#Preview("Cell") {
    DemoSimpleUIElement()
}
