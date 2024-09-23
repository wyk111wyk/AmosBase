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
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .center) {
                if isLoading {
                    VStack(spacing: 15) {
                        ProgressView()
                            .scaleEffect(1.5)
                        if let title {
                            Text(title)
                        }
                    }
                    .padding()
                    .frame(width: 240, height: 140)
                    .background {
                        if #available(iOS 16.0, macOS 13, watchOS 10, *) {
                            // 使用 regularMaterial
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle(.regularMaterial)
                                .shadow(radius: 5, x: 2, y: 2)
                        } else {
                            // 使用其他替代方案
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundStyle(.gray)
                                .shadow(radius: 5, x: 2, y: 2)
                        }
                    }
                }
            }
    }
}

extension View {
    public func simpleHud(isLoading: Bool, title: String?) -> some View {
        modifier(SimpleHud(isLoading: isLoading, title: title))
    }
}

@available(iOS 17.0, macOS 14, watchOS 10, *)
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
