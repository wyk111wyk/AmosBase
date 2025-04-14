//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/3/21.
//

import SwiftUI

struct BounceModifier: ViewModifier {
    let isToggled: Bool
    let maxScale: CGFloat
    @State private var isScaled: Bool = false
    
    init(isToggled: Bool, maxScale: CGFloat = 1.2) {
        self.isToggled = isToggled
        self.maxScale = maxScale
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isScaled ? maxScale : 1.0)
            .animation(
                .spring(response: 0.4, dampingFraction: 0.3),
                value: isScaled
            )
            .contentShape(Rectangle())
            .onChange(of: isToggled) {
                withAnimation {
                    isScaled = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isScaled = false
                    }
                }
            }
    }
}

struct BounceView: View {
    @State private var isToggled: Bool = false
    var body: some View {
        VStack(spacing: 30) {
            Text("Hello, World!")
                .font(.largeTitle)
                .modifier(BounceModifier(isToggled: isToggled))
            Image(sfImage: .lal_nba)
                .imageModify(width: 100)
                .modifier(BounceModifier(isToggled: isToggled))
            Image(systemName: "rectangle.and.pencil.and.ellipsis")
                .imageModify(width: 100)
                .modifier(BounceModifier(isToggled: isToggled))
            
            PlainButton {
                isToggled.toggle()
            } label: {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(.blue)
                    .frame(width: 200, height: 48)
                    .overlay(alignment: .center) {
                        Text("点击跳跃")
                            .foregroundStyle(.white)
                    }
            }
            .padding(.top, 80)
        }
    }
}

#Preview {
    BounceView()
}
