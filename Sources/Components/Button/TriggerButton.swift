//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/3/14.
//

import SwiftUI

/// 简单的开关，点击后切换 isPresented 的值
public struct SimpleTriggerButton<V: View>: View {
    let title: String?
    let systemImage: String?
    
    @ViewBuilder var label: () -> V
    @Binding var isPresented: Bool
    
    public init(
        title: String? = "Trigger",
        systemImage: String? = nil,
        isPresented: Binding<Bool>,
        label: @escaping () -> V = { EmptyView() }
    ) {
        self.title = title
        self.systemImage = systemImage
        self._isPresented = isPresented
        self.label = label
    }
    
    public var body: some View {
        Button(role: .none, action: {
            isPresented.toggle()
        }, label: {
            if V.self != EmptyView.self {
                label()
            }else {
                HStack {
                    if let systemImage {
                        Image(systemName: systemImage)
                    }
                    if let title {
                        Text(title.localized())
                    }
                    Spacer()
                }
                .contentShape(Rectangle())
            }
        })
        .buttonStyle(.borderless)
    }
}
