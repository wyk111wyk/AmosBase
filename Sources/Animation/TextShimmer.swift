//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/3/21.
//

import SwiftUI

public struct AnimaTextShimmer: View {
    public let textContent: String
    public let textColor: Color
    public let textFont: Font
    public let duration: Double
    
    @State var isShimmering = false
    
    public init(
        textContent: String = "Get started",
        textColor: Color = .gray,
        textFont: Font = .title,
        duration: Double = 2.5
    ) {
        self.textContent = textContent
        self.textColor = textColor
        self.textFont = textFont
        self.duration = duration
    }
    
    public var body: some View {
        if #available(iOS 18.0, macOS 15.0, watchOS 10.0, *) {
            ZStack {
                Text(textContent)
                    .font(textFont)
                    .foregroundStyle(textColor.opacity(0.2))
                Text(textContent)
                    .font(textFont)
                    .textRenderer(ShimmerEffect(animationProgress: isShimmering ? 3 : -1))
            }
            .onAppear(){
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    isShimmering.toggle()
                }
            }
        } else {
            Text(textContent)
                .font(textFont)
                .foregroundStyle(textColor)
        }
    }
}

struct ShimmerEffect: TextRenderer {
    var animationProgress: CGFloat
    var animatableData: Double {
        get { animationProgress }
        set { animationProgress = newValue }
    }
    
    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        for line in layout{
            for runs in line {
                for (index, glyph) in runs.enumerated() {
                    let relativePosition = CGFloat(index) / CGFloat(runs.count)
                    let adjustedOpacity = max(
                        0,
                        1 - abs(relativePosition - animationProgress)
                    )
                    ctx.opacity = Double(adjustedOpacity)
                    ctx.draw(glyph)
                }
            }
        }
        
    }
}

#Preview {
    AnimaTextShimmer()
        .padding()
        .background(.gray.tertiary, in: Capsule())
}
