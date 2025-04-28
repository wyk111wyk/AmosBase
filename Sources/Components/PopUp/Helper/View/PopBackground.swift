//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/4/13.
//

import SwiftUI

public struct PopBackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    public init() {}
    
    var gradient: Gradient {
        if colorScheme == .light {
            return Gradient(colors: [
                .white.opacity(0.1),
                .white.opacity(0.02)
            ])
        }else{
            return Gradient(colors: [
                .black.opacity(0.1),
                .black.opacity(0.02)
            ])
        }
    }
    
    public var body: some View {
        ZStack {
            // 基础半透明层：更透明
            Color.black.opacity(0.1) // 降低 opacity 以提高透明度
                .ignoresSafeArea()
            
            // 轻量毛玻璃效果 + 微妙渐变
            Rectangle()
                .fill(.ultraThinMaterial.opacity(0.3)) // 降低材质透明度
                .overlay(
                    LinearGradient(
                        gradient: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .blendMode(.overlay)
                )
                .ignoresSafeArea()
        }
    }
}

#Preview {
    @Previewable @State var showBackground: Bool = true
    ZStack {
        Form {
            ForEach(0...30) { _ in
                Text("Hello World!")
            }
        }
        if showBackground {
            PopBackgroundView()
        }
    }
    .onTapGesture {
        showBackground.toggle()
    }
}
