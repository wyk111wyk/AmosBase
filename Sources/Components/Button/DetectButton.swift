//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/3/14.
//

import SwiftUI

// 检测点击和点按的按钮
public struct DetectButton<V: View>: View {
    let label: () -> V
    let holdAction: (Bool) -> Void
    let tapAction: () -> Void
    
    public init(
        tapAction: @escaping () -> Void = {},
        holdAction: @escaping (Bool) -> Void,
        @ViewBuilder label: @escaping () -> V
    ) {
        self.label = label
        self.tapAction = tapAction
        self.holdAction = holdAction
    }
    
    public var body: some View {
        Button(action: tapAction, label: label)
            .buttonStyle(ButtonModifier(holdAction: holdAction))
    }
}

private struct ButtonModifier: ButtonStyle {
    let holdAction: (Bool) -> Void
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.8 : 1)
            .onChange(of: configuration.isPressed) {
                holdAction(configuration.isPressed)
            }
    }
}
