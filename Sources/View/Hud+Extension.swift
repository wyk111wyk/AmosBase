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
    
    let width: CGFloat?
    let height: CGFloat?
    
    init(
        isLoading: Bool,
        title: String? = nil,
        width: CGFloat? = 220,
        height: CGFloat? = 120
    ) {
        self.isLoading = isLoading
        self.title = title
        self.width = width
        self.height = height
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .center) {
                if isLoading {
                    VStack {
                        loadingView()
                    }
                        .transition(.scale(scale: 0.4).combined(with: .opacity))
                }
            }
    }
    
    private func loadingView() -> some View {
        PopHud(mode: .loading, title: title)
    }
}

extension View {
    public func simpleHud(
        isLoading: Bool,
        title: String? = nil
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
    .simpleHud(isLoading: isLoading)
}
