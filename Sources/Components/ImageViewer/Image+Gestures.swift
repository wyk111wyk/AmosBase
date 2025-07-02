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
        self.modifier(ImageViewerModifier())
    }
}

// MARK: - 图片浏览视图修饰符
struct ImageViewerModifier: ViewModifier {
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var lastScale: CGFloat = 1.0
    @State private var isDragging: Bool = false
    @State private var isZooming: Bool = false
    @State private var startAnchor: UnitPoint = .center
    
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 5.0
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .scaleEffect(scale, anchor: startAnchor)
                .offset(offset)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .highPriorityGesture(
                    dragGestures(in: geometry),
                    isEnabled: scale > minScale && !isZooming
                )
                .simultaneousGesture(zoomGesture(in: geometry))
                .onTapGesture(count: 2) {
                    handleDoubleTap()
                }
                #if os(watchOS)
                .focusable()
                .digitalCrownRotation(
                    $scale,
                    from: minScale,
                    through: maxScale,
                    by: 0.1,
                    sensitivity: .medium,
                    isContinuous: true,
                    isHapticFeedbackEnabled: true
                )
                .onChange(of: scale) {
                    handleScaleChange(scale, in: geometry)
                }
                #elseif os(macOS)
                .simultaneousGesture(scrollGesture(in: geometry))
                #endif
        }
        .clipped()
    }
    
    // MARK: - 手势处理
    private func dragGestures(in geometry: GeometryProxy) -> some Gesture {
        let dragGesture = DragGesture()
            .onChanged { value in
                if scale > minScale {
                    isDragging = true
                    let newOffset = CGSize(
                        width: lastOffset.width + value.translation.width,
                        height: lastOffset.height + value.translation.height
                    )
                    offset = constrainOffset(newOffset, in: geometry)
                }
            }
            .onEnded { _ in
                isDragging = false
                lastOffset = offset
            }
        
        return dragGesture
    }
    
    private func zoomGesture(in geometry: GeometryProxy) -> some Gesture {
        let magnificationGesture = MagnifyGesture()
            .onChanged { value in
                isZooming = true
                if scale == minScale {
                    startAnchor = value.startAnchor
                }
                let newScale = lastScale * value.magnification
                scale = min(max(newScale, minScale), maxScale)
                updateOffset(for: geometry)
            }
            .onEnded { _ in
                isZooming = false
                lastScale = scale
            }
        
        return magnificationGesture
    }
    
    #if os(macOS)
    private func scrollGesture(in geometry: GeometryProxy) -> some Gesture {
        // macOS 支持滚轮缩放
        let scrollGesture = MagnificationGesture()
            .onChanged { value in
                let newScale = lastScale * value
                scale = min(max(newScale, minScale), maxScale)
                updateOffset(for: geometry)
            }
            .onEnded { _ in
                lastScale = scale
            }

        return scrollGesture
    }
    #endif
    
    // MARK: - 双击处理
    private func handleDoubleTap() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if scale > minScale {
                // 恢复到原始大小
                scale = minScale
                offset = .zero
                lastScale = minScale
                lastOffset = .zero
            } else {
                // 放大到2.8倍
                scale = 2.8
                lastScale = 2.8
                offset = .zero
                lastOffset = .zero
            }
        }
    }
    
    // MARK: - 缩放变化处理（主要用于 watchOS 数码表冠）
    private func handleScaleChange(_ newScale: CGFloat, in geometry: GeometryProxy) {
        updateOffset(for: geometry)
        lastScale = newScale
    }
    
    // MARK: - 偏移约束
    private func constrainOffset(_ proposedOffset: CGSize, in geometry: GeometryProxy) -> CGSize {
        let imageSize = geometry.size
        
        // 计算内容的缩放后宽高
        let scaledSize = CGSize(
            width: imageSize.width * scale,
            height: imageSize.height * scale
        )
        
        // 计算最大允许的偏移量
        let maxOffsetX = max(0, (scaledSize.width - imageSize.width) / 2)
        let maxOffsetY = max(0, (scaledSize.height - imageSize.height) / 2)
        
        return CGSize(
            width: min(max(proposedOffset.width, -maxOffsetX), maxOffsetX),
            height: min(max(proposedOffset.height, -maxOffsetY), maxOffsetY)
        )
    }
    
    // MARK: - 更新偏移
    private func updateOffset(for geometry: GeometryProxy) {
        offset = constrainOffset(offset, in: geometry)
        lastOffset = offset
    }
}

#Preview {
    MutiImageViewer(
        allImages: ImageStoreModel.examples(),
        selectedIndex: 0
    )
}
