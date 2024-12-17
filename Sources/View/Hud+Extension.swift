//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2024/9/9.
//

import SwiftUI

struct SimpleHud: ViewModifier {
    let isLoading: Bool
    let title: String?
    // 0 - 1
    let progress: Float?
    
    let width: CGFloat?
    let height: CGFloat?
    
    init(
        isLoading: Bool,
        title: String? = nil,
        progress: Float? = nil,
        width: CGFloat? = 240,
        height: CGFloat? = 140
    ) {
        self.isLoading = isLoading
        self.title = title
        self.progress = progress
        self.width = width
        self.height = height
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .center) {
                if isLoading {
                    hudView()
                        .transition(.scale(scale: 0.4).combined(with: .opacity))
                }
            }
    }
    
    private func hudView() -> some View {
        VStack(spacing: 15) {
            ProgressView()
                #if os(iOS)
                .scaleEffect(1.5)
                #endif
            if let title {
                Text(title)
            }
            if let progress {
                ProgressView(value: progress, total: 1)
            }
        }
        .padding()
        .frame(width: width, height: height)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.regularMaterial)
                .shadow(radius: 5, x: 2, y: 2)
        }
    }
}

extension View {
    public func simpleHud(
        isLoading: Bool,
        title: String?
    ) -> some View {
        modifier(
            SimpleHud(
                isLoading: isLoading,
                title: title
            )
        )
    }
}

#Preview {
    @Previewable @State var isLoading: Bool = true
    NavigationStack {
        Form {
            Button {
                withAnimation {
                    isLoading.toggle()
                }
            } label: {
                Text("开/关 HUD")
            }
        }
    }
    .simpleHud(isLoading: isLoading, title: "我是Hud")
}
