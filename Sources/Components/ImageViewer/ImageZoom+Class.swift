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
    
    @State private var isPinching: Bool = false
    @State private var isDragging: Bool = false
    
    @State private var startScale: CGFloat = 1.0
    @State private var startOffset: CGSize = .zero
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale, anchor: anchor)
            .offset(offset)
            .gesture(pinch())
            .gesture(doubleTap())
            .gesture(drag(), isEnabled: scale > 1)
    }
    
    private func pinch() -> some Gesture {
        MagnifyGesture()
            .onChanged { value in
                if !isPinching {
                    isPinching = true
                    startScale = scale
                    anchor = value.startAnchor
                }
                
                scale = startScale * value.magnification
            }
            .onEnded { _ in
                isPinching = false
                // 如果缩放比例小于1，则恢复默认大小
                if scale < 1.0 {
                    withAnimation {
                        scale = 1.0
                        offset = .zero
                    }
                }
            }
    }
    
    private func doubleTap() -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    if scale == 1.0 {
                        scale = 2.5
                    } else {
                        scale = 1.0
                    }
                    anchor = .center
                    offset = .zero
                    startOffset = .zero
                }
            }
    }
    
    private func drag() -> some Gesture {
        DragGesture()
            .onChanged { value in
                if !isDragging {
                    isDragging = true
                    startOffset = offset
                }
                
//                print("Value: \(value)")
//                print("Translation: \(value.translation)")
                // 更新偏移量
                offset = CGSize(
                    width: startOffset.width + value.translation.width,
                    height: startOffset.height + value.translation.height
                )
            }
            .onEnded { value in
                isDragging = false
                startOffset = offset
            }
    }
}
