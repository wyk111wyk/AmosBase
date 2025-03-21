//
//  File.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/10/22.
//

import Foundation
import SwiftUI

public extension View {
    func contentBackground(
        verticalPadding: CGFloat? = nil,
        horizontalPadding: CGFloat? = nil,
        cornerRadius: CGFloat = 12,
        shadowRadius: CGFloat? = nil,
        shadowY: CGFloat = 0,
        color: Color? = nil,
        withMaterial: Bool = true,
        isAppear: Bool = true
    ) -> some View {
        self
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .background {
                if isAppear {
                    if let shadowRadius {
                        if let color {
                            if withMaterial {
                                ZStack {
                                    RoundedRectangle(cornerRadius: cornerRadius)
                                        .foregroundStyle(color)
                                        .opacity(0.6)
                                    RoundedRectangle(cornerRadius: cornerRadius)
                                        .foregroundStyle(.ultraThickMaterial)
                                        .shadow(radius: shadowRadius, y: shadowY)
                                }
                            }else {
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .foregroundStyle(color)
                                    .shadow(radius: shadowRadius, y: shadowY)
                            }
                        }else {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .foregroundStyle(.background.secondary)
                                .shadow(radius: shadowRadius, y: shadowY)
                        }
                    }else if let color {
                        if withMaterial {
                            ZStack {
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .foregroundStyle(color)
                                    .opacity(0.6)
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .foregroundStyle(.ultraThickMaterial)
                            }
                        }else {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .foregroundStyle(color)
                        }
                    }else {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .foregroundStyle(.background.secondary)
                            .opacity(0.9)
                    }
                }
            }
    }
}

#Preview(body: {
    VStack (spacing: 20) {
        Text("Black")
            .contentBackground()
        Text("Color")
            .contentBackground(color: .blue)
        Text("Shadow")
            .contentBackground(shadowRadius: 20)
        Text("Shadow")
            .contentBackground(shadowRadius: 5, color: .green)
    }
})
