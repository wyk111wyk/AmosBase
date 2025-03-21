//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/3/20.
//

import SwiftUI

public struct AnimaMovingBorder<Content: View>: View {
    let content: Content
    let isMoving: Bool
    let borderWidth: CGFloat
    let dashLength: CGFloat
    let dashSpacing: CGFloat
    let dashPhase: CGFloat
    let animationDuration: Double
    let cornerRadius: CGFloat
    
    @State private var isMovingAround = false

    public init(
        isMoving: Bool,
        borderWidth: CGFloat = 4,
        dashLength: CGFloat = 50,
        dashSpacing: CGFloat = 400,
        dashPhase: CGFloat = 220,
        animationDuration: Double = 2,
        cornerRadius: CGFloat = 10,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.isMoving = isMoving
        self.borderWidth = borderWidth
        self.dashLength = dashLength
        self.dashSpacing = dashSpacing
        self.dashPhase = dashPhase
        self.animationDuration = animationDuration
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        style: StrokeStyle(
                            lineWidth: borderWidth,
                            lineCap: .round,
                            lineJoin: .round,
                            dash: [dashLength, dashSpacing],
                            dashPhase: isMovingAround ? dashPhase : -dashPhase
                        )
                    )
                    .foregroundStyle(linearGradientColor)
                    .opacity(isMoving ? 1 : 0)
            )
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    isMovingAround.toggle()
                }
            }
    }
    
    private func linearGradientSingle(for color: Color) -> some ShapeStyle {
        LinearGradient(
            gradient:Gradient(
                colors: [color.opacity(0.01), color, color, color.opacity(0.01)]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var linearGradientColor: some ShapeStyle {
        LinearGradient(
            gradient: Gradient(
                colors:
                    [.indigo, .white, .green, .mint, .white, .orange, .indigo]
            ),
            startPoint: .trailing,
            endPoint: .leading
        )
    }
}

struct MovingDashDemo: View {
    @State private var isBorderMoving = true

    var body: some View {
        VStack {
            AnimaMovingBorder(
                isMoving: isBorderMoving,
                cornerRadius: 0
            ) {
                PlainButton {
                    isBorderMoving.toggle()
                } label: {
                    Rectangle()
                        .foregroundStyle(.gray.opacity(0.2))
                        .frame(width: 200, height: 50)
                }
            }
            .padding()
            
            AnimaMovingBorder(
                isMoving: isBorderMoving,
                cornerRadius: 50
            ) {
                PlainButton {
                    isBorderMoving.toggle()
                } label: {
                    Circle()
                        .foregroundStyle(.gray.opacity(0.2))
                        .frame(width: 100, height: 100)
                }
            }
            .padding()

            SimpleToggleButton(isPresented: $isBorderMoving) {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(.blue)
                    .frame(width: 200, height: 48)
                    .overlay(alignment: .center) {
                        Text("点击切换")
                            .foregroundStyle(.white)
                    }
            }
            .padding(.top, 80)
        }
    }
}

#Preview {
    MovingDashDemo()
}
