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
    let animationDuration: Double
    let cornerRadius: CGFloat

    @State private var dashPhase: CGFloat = 0

    public init(
        isMoving: Bool,
        borderWidth: CGFloat = 4,
        dashLength: CGFloat = 60,
        dashSpacing: CGFloat = 200,
        animationDuration: Double = 5,
        cornerRadius: CGFloat = 10,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.isMoving = isMoving
        self.borderWidth = borderWidth
        self.dashLength = dashLength
        self.dashSpacing = dashSpacing
        self.animationDuration = animationDuration
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        GeometryReader { geometry in
            let rect = geometry.frame(in: .local)
            let perimeter = 2 * (rect.width + rect.height)

            content
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(
                            style: StrokeStyle(
                                lineWidth: borderWidth,
                                lineCap: .round,
                                lineJoin: .round,
                                dash: [dashLength, dashSpacing],
                                dashPhase: dashPhase
                            )
                        )
                        .foregroundStyle(linearGradientColor)
                        .opacity(isMoving ? 1 : 0)
                )
                .onAppear {
                    if isMoving {
                        withAnimation(.linear(duration: animationDuration).repeatForever(autoreverses: false)) {
                            dashPhase = perimeter
                        }
                    }
                }
        }
    }

    private var linearGradientColor: some ShapeStyle {
        LinearGradient(
            gradient: Gradient(colors: [.indigo, .white, .green, .mint, .white, .orange, .indigo]),
            startPoint: .trailing,
            endPoint: .leading
        )
    }
}

public struct FlowLightBorder<Content: View>: View {
    let content: Content
    let lineWidth: CGFloat
    let cornerRadius: CGFloat
    let animationDuration: Double
    let glowRadius: CGFloat

    @State private var rotation: Angle = .degrees(0)

    public init(
        lineWidth: CGFloat = 5,
        cornerRadius: CGFloat = 20,
        animationDuration: Double = 6,
        glowRadius: CGFloat = 15,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.lineWidth = lineWidth
        self.cornerRadius = cornerRadius
        self.animationDuration = animationDuration
        self.glowRadius = glowRadius
    }

    public var body: some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                GeometryReader { geo in
                    let size = geo.size

                    ZStack {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .strokeBorder(
                                AngularGradient(
                                    gradient: Gradient(colors: gradientColors()),
                                    center: .center
                                ),
                                lineWidth: lineWidth
                            )
                            .rotationEffect(rotation)
                            .blur(radius: glowRadius)
                            .mask(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(lineWidth: lineWidth)
                                    .frame(width: size.width, height: size.height)
                            )
                    }
                    .onAppear {
                        withAnimation(.linear(duration: animationDuration).repeatForever(autoreverses: false)) {
                            rotation = .degrees(360)
                        }
                    }
                }
            }
    }

    private func gradientColors() -> [Color] {
        [
            .clear,
            .mint,
            .green,
            .cyan,
            .blue,
            .purple,
            .pink,
            .orange,
            .yellow,
            .red,
            .mint,
            .clear
        ]
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
                }
            }
            .frame(width: 200, height: 50)
            .padding()
            
            AnimaMovingBorder(
                isMoving: isBorderMoving,
                cornerRadius: 100
            ) {
                PlainButton {
                    isBorderMoving.toggle()
                } label: {
                    Circle()
                        .foregroundStyle(.gray.opacity(0.2))
                }
            }
            .frame(width: 200, height: 100)
            .padding()
            
            FlowLightBorder(lineWidth: 6, cornerRadius: 30, animationDuration: 3) {
                VStack {
                    Image(systemName: "waveform.circle.fill")
                        .font(.system(size: 60))
                    Text("Siri is thinking...")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(width: 220, height: 220)
                .background(Color.green)
            }
            .frame(width: 220, height: 220)
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
