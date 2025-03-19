//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/3/14.
//

import SwiftUI

/*
 使用方式：在任何页面添加：
 typealias PlainButton = _PlainButton
 */
public typealias _PlainButton = PlainButton

public struct PlainButton<V: View>: View {
    let label: () -> V
    let tapAction: () -> Void
    
    public init(
        tapAction: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> V
    ) {
        self.label = label
        self.tapAction = tapAction
    }
    
    public var body: some View {
        Button(action: tapAction, label: label)
            .buttonStyle(.plain)
    }
}
