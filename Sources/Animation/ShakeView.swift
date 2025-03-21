//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/3/21.
//

import SwiftUI

struct ShakeModifier: ViewModifier {
    let isShake: Bool
    init(isShake: Bool) {
        self.isShake = isShake
    }
    
    @State private var shakeAttempts: Int = 0
    
    func body(content: Content) -> some View {
        content
            .shakeEffect(shakes: CGFloat(shakeAttempts))
            .onChange(of: isShake) {
                withAnimation(.linear(duration: 0.2).repeatCount(1, autoreverses: true)) {
                    shakeAttempts += 3
                }
            }
    }
}

struct ShakeEffect: AnimatableModifier {
    var shakes: CGFloat = 0
    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }
    
    func body(content: Content) -> some View {
        content
            .offset(x: sin(shakes * .pi * 2) * 10)
    }
}

extension View {
    func shakeEffect(shakes: CGFloat) -> some View {
        self.modifier(ShakeEffect(shakes: shakes))
    }
}

struct ShakeViewDemo: View {
    @State private var isShake: Bool = false
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.blue)
                .frame(width: 200, height: 150)
                .padding(.bottom, 50)
                .modifier(ShakeModifier(isShake: isShake))
            
            PlainButton {
                isShake.toggle()
                SimpleHaptic.playFailureHaptic()
            } label: {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(.blue)
                    .frame(width: 200, height: 48)
                    .overlay(alignment: .center) {
                        Text("点击晃动")
                            .foregroundStyle(.white)
                    }
            }
        }
    }
}

#Preview {
    ShakeViewDemo()
}
