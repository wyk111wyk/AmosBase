//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/2/28.
//

import Foundation
import SwiftUI

extension View {
    func pinchToZoom() -> some View {
        self.modifier(PinchToZoom())
    }
}

struct PinchToZoom: ViewModifier {
    @State private var scale: CGFloat = 1.0
    @State private var anchor: UnitPoint = .center
    @State private var offset: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0
    @State private var lastOffset: CGSize = .zero
    
    // 用于数码表冠和触控板支持
    @State private var magnificationValue: CGFloat = 0
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .scaleEffect(scale, anchor: anchor)
                .offset(offset)
                // 确保内容在GeometryReader中居中显示
                .frame(width: geometry.size.width, height: geometry.size.height)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            guard scale > 1.0 else { return }
                            // 实时更新位置，确保拖动流畅
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                        .onEnded { value in
                            // 保存最后的偏移位置
                            lastOffset = offset
                            
                            // 检查是否需要边界矫正
                            constrainOffsetToBounds(geometry: geometry)
                        }
                )
                .gesture(
                    TapGesture(count: 2)
                        .onEnded {
                            withAnimation {
                                if scale != 1.0 {
                                    // 重置为默认状态
                                    scale = 1.0
                                    offset = .zero
                                    lastOffset = .zero
                                } else {
                                    // 放大到2倍
                                    scale = 2.0
                                }
                            }
                        }
                )
                #if !os(watchOS)
                .simultaneousGesture(
                    MagnifyGesture()
                        .onChanged { value in
                            // 直接在手势变化时更新缩放比例，使用相对缩放
                            anchor = value.startAnchor
                            // 限制缩放范围
                            let newScale = scale * value.magnification
                            scale = min(max(newScale, 0.5), 8.0)
                        }
                        .onEnded { value in
                            // 保存最后的缩放值
                            lastScale = 1.0
                            
                            // 如果缩放小于1，恢复默认
                            if scale < 1.0 {
                                withAnimation {
                                    scale = 1.0
                                    offset = .zero
                                    lastOffset = .zero
                                }
                            }
                            
                            // 检查是否需要边界矫正
                            constrainOffsetToBounds(geometry: geometry)
                        }
                )
                // watchOS 数码表冠支持
                #else
                .digitalCrownRotation(
                    $magnificationValue,
                    from: -2.0,
                    through: 2.0,
                    by: 0.05,
                    sensitivity: .medium,
                    isContinuous: true,
                    isHapticFeedbackEnabled: true
                )
                .onChange(of: magnificationValue) {
                    // 使用表冠值来调整缩放
                    let newScale = 1.0 + magnificationValue
                    scale = min(max(newScale, 0.5), 5.0)
                    
                    // 检查是否需要边界矫正
                    constrainOffsetToBounds(geometry: geometry)
                }
                #endif
        }
    }
    
    // 边界约束函数，防止内容被缩放过大后拖出视图范围
    private func constrainOffsetToBounds(geometry: GeometryProxy) {
        let size = geometry.size
        
        // 计算内容的缩放后宽高
        let scaledWidth = size.width * scale
        let scaledHeight = size.height * scale
        
        // 计算最大允许的偏移量
        let maxOffsetX = max(0, (scaledWidth - size.width) / 2)
        let maxOffsetY = max(0, (scaledHeight - size.height) / 2)
        
        // 约束偏移量在允许范围内
        offset = CGSize(
            width: min(maxOffsetX, max(-maxOffsetX, offset.width)),
            height: min(maxOffsetY, max(-maxOffsetY, offset.height))
        )
        
        // 更新保存的偏移量
        lastOffset = offset
    }
}

#Preview {
    MutiImageViewer(
        allImages: ImageStoreModel.examples(),
        selectedIndex: 0
    )
}
