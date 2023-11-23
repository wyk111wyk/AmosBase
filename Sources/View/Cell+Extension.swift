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
                    .frame(width: imageSize, height: imageSize)
            }
            // Title 和 Content
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .foregroundColor(.primary)
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
            #if !os(watchOS)
            .textSelection(.enabled)
            #endif
        }
    }
}

#Preview("Cell") {
    NavigationView {
        ButtonTestView()
    }
#if canImport(UIKit)
    .navigationViewStyle(.stack)
    #endif
}
