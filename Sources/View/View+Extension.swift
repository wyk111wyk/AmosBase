//
//  File.swift
//
//
//  Created by AmosFitness on 2023/11/10.
//

import SwiftUI

public enum AmosError: Error, Equatable, LocalizedError {
    case customError(msg: String)
    
    public var errorDescription: String? {
        switch self {
        case .customError(let msg):
            return msg
        }
    }
}

/// 判断是否处于 Preview 环境
public let isPreviewCondition: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

public extension Binding {
    static func isPresented<V>(_ value: Binding<V?>) -> Binding<Bool> {
        Binding<Bool>(
            get: { value.wrappedValue != nil },
            set: { if !$0 { value.wrappedValue = nil } }
        )
    }
}

public extension View {
    @ViewBuilder func simpleTagBackground<S: ShapeStyle>(verticalPad: CGFloat = 5,
                                                         horizontalPad: CGFloat = 10,
                                                         contentColor: S = .white,
                                                         cornerRadius: CGFloat = 6,
                                                         bgStyle: S = .blue) -> some View {
        self.modifier(TagBackground(verticalPad: verticalPad,
                                    horizontalPad: horizontalPad,
                                    contentColor: contentColor,
                                    cornerRadius: cornerRadius,
                                    bgStyle: bgStyle))
    }
    
}

struct TagBackground<S>: ViewModifier where S: ShapeStyle {
    let verticalPad: CGFloat
    let horizontalPad: CGFloat
    let contentColor: S
    let cornerRadius: CGFloat
    let bgStyle: S
    
    init(verticalPad: CGFloat, 
         horizontalPad: CGFloat,
         contentColor: S,
         cornerRadius: CGFloat,
         bgStyle: S) {
        self.verticalPad = verticalPad
        self.horizontalPad = horizontalPad
        self.contentColor = contentColor
        self.cornerRadius = cornerRadius
        self.bgStyle = bgStyle
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.vertical, verticalPad)
            .padding(.horizontal, horizontalPad)
            .foregroundStyle(contentColor)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundStyle(bgStyle)
            }
    }
}
