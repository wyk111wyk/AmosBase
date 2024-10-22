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
        color: Color? = nil
    ) -> some View {
        self
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .background {
                if let shadowRadius {
                    if let color {
                        ZStack {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .foregroundStyle(color)
                                .opacity(0.6)
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .foregroundStyle(.ultraThickMaterial)
                                .shadow(radius: shadowRadius)
                        }
                    }else {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .foregroundStyle(.regularMaterial)
                            .shadow(radius: shadowRadius)
                    }
                }else if let color {
                    ZStack {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .foregroundStyle(color)
                            .opacity(0.6)
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .foregroundStyle(.ultraThickMaterial)
                    }
                }else {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .foregroundStyle(.regularMaterial)
                        .opacity(0.9)
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
            .contentBackground(shadowRadius: 5)
        Text("Shadow")
            .contentBackground(shadowRadius: 5, color: .green)
    }
})
