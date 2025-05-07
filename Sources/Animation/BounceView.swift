//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/3/21.
//

import SwiftUI

public extension View {
    func rotate(
        isActivated: Bool,
        duration: Double = 0.8,
        anchor: UnitPoint = .center
    ) -> some View {
        modifier(
            RotateModifier(
                isActivated: isActivated,
                duration: duration,
                anchor: anchor
            )
        )
    }
    
    func bounce(
        isToggled: Bool,
        maxScale: CGFloat = 1.2
    ) -> some View {
        modifier(BounceModifier(isToggled: isToggled, maxScale: maxScale))
    }
}

struct RotateModifier: ViewModifier {
    let isActivated: Bool
    let duration: Double
    let anchor: UnitPoint
    
    @State private var degree: Double = 0
    
    init(
        isActivated: Bool,
        duration: Double = 0.8,
        anchor: UnitPoint = .center
    ) {
        self.isActivated = isActivated
        self.duration = duration
        self.anchor = anchor
    }
    
    func body(content: Content) -> some View {
        if isActivated {
            content
                .onAppear {
                    degree += 360
                }
                .rotationEffect(.degrees(degree), anchor: anchor)
                .animation(
                    .linear(
                        duration: duration
                    ).repeatForever(autoreverses: false),
                    value: degree
                )
        }else {
            content
                .rotationEffect(.degrees(0))
        }
    }
}

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
    @State private var isRotating: Bool = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Hello, World!")
                .font(.largeTitle)
                .bounce(isToggled: isToggled)
                .rotate(isActivated: isRotating, anchor: .leading)
            Image(sfImage: .lal_nba)
                .imageModify(length: 100)
                .bounce(isToggled: isToggled)
                .rotate(isActivated: isRotating)
            Image(systemName: "rectangle.and.pencil.and.ellipsis")
                .imageModify(length: 100)
                .bounce(isToggled: isToggled)
                .rotate(isActivated: isRotating, anchor: .trailing)
            Image(systemName: "fan")
                .imageModify(length: 80)
                .bounce(isToggled: isToggled)
                .rotate(isActivated: isRotating)
            
            HStack {
                PlainButton {
                    isToggled.toggle()
                } label: {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(.blue)
                        .frame(width: 150, height: 48)
                        .overlay(alignment: .center) {
                            Text("点击跳跃")
                                .foregroundStyle(.white)
                        }
                }
                
                PlainButton {
                    isRotating.toggle()
                } label: {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(isRotating ? .green : .gray)
                        .frame(width: 150, height: 48)
                        .overlay(alignment: .center) {
                            Text(isRotating ? "取消旋转" : "点击旋转")
                                .foregroundStyle(.white)
                        }
                }
            }
            .padding(.top, 80)
        }
    }
}

#Preview {
    BounceView()
}
