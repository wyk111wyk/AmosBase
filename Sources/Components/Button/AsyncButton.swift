//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/3/14.
//

import SwiftUI

/// 简单的用来进行多线程任务的按钮
public struct SimpleAsyncButton<V: View>: View {
    let title: String?
    let systemImage: String?
    let role: ButtonRole?
    
    let action: () async throws -> Void
    @ViewBuilder var label: () -> V
    
    public init(
        title: String? = nil,
        systemImage: String? = nil,
        role: ButtonRole? = nil,
        action: @escaping () async throws -> Void,
        label: @escaping () -> V = { EmptyView() }
    ) {
        self.title = title
        self.systemImage = systemImage
        self.role = role
        self.action = action
        self.label = label
    }
    
    public var body: some View {
        Button(role: role) {
            Task { try await action() }
        } label: {
            if V.self != EmptyView.self {
                label()
            } else {
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
        }
    }
}
