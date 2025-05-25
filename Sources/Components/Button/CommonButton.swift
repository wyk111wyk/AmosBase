//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/5/18.
//

import SwiftUI

public struct DeleteButton<V: View, S: PrimitiveButtonStyle>: View {
    let style: S
    let role: ButtonRole?
    let color: Color?
    let isInMiddle: Bool
    let isLoading: Bool
    let label: () -> V
    let tapAction: () -> Void
    
    public init(
        style: S = .automatic,
        role: ButtonRole? = .destructive,
        color: Color? = nil,
        isInMiddle: Bool = false,
        isLoading: Bool = false,
        tapAction: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> V = {EmptyView()}
    ) {
        self.style = style
        self.role = role
        self.color = color
        self.isInMiddle = isInMiddle
        self.isLoading = isLoading
        self.label = label
        self.tapAction = tapAction
    }
    
    public var body: some View {
        BaseButton(
            title: .delete,
            systemImage: "trash",
            imageBgColor: color,
            role: role,
            style: style,
            bundle: .module,
            isInMiddle: isInMiddle,
            isLoading: isLoading,
            action: tapAction,
            label: label
        )
        .tint(color)
    }
}

public struct ConfirmButton<V: View, S: PrimitiveButtonStyle>: View {
    let title: String
    let systemImage: String
    let style: S
    let role: ButtonRole?
    let color: Color?
    let isInMiddle: Bool
    let isLoading: Bool
    let label: () -> V
    let tapAction: () -> Void
    
    public init(
        title: String = .confirm,
        systemImage: String = "checkmark",
        style: S = .borderless,
        role: ButtonRole? = nil,
        color: Color? = .green,
        isInMiddle: Bool = false,
        isLoading: Bool = false,
        tapAction: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> V = {EmptyView()}
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.role = role
        self.color = color
        self.isInMiddle = isInMiddle
        self.isLoading = isLoading
        self.label = label
        self.tapAction = tapAction
    }
    
    public var body: some View {
        BaseButton(
            title: title,
            systemImage: systemImage,
            imageBgColor: color,
            role: role,
            style: style,
            bundle: .module,
            isInMiddle: isInMiddle,
            isLoading: isLoading,
            action: tapAction,
            label: label
        )
        .tint(color)
    }
}

public struct CancelButton<V: View, S: PrimitiveButtonStyle>: View {
    let title: String
    let systemImage: String
    let style: S
    let role: ButtonRole?
    let color: Color
    let isInMiddle: Bool
    let isLoading: Bool
    let label: () -> V
    let tapAction: () -> Void
    
    public init(
        title: String = .cancel,
        systemImage: String = "xmark",
        style: S = .borderless,
        role: ButtonRole? = nil,
        color: Color = .gray,
        isInMiddle: Bool = false,
        isLoading: Bool = false,
        tapAction: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> V = {EmptyView()}
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.role = role
        self.color = color
        self.isInMiddle = isInMiddle
        self.isLoading = isLoading
        self.label = label
        self.tapAction = tapAction
    }
    
    public var body: some View {
        BaseButton(
            title: title,
            systemImage: systemImage,
            imageBgColor: color,
            role: role,
            style: style,
            bundle: .module,
            isInMiddle: isInMiddle,
            isLoading: isLoading,
            action: tapAction,
            label: label
        )
        .tint(color)
    }
}

public struct SimpleEditButton<V: View, S: PrimitiveButtonStyle>: View {
    let style: S
    let role: ButtonRole?
    let isInMiddle: Bool
    let isLoading: Bool
    let label: () -> V
    let tapAction: () -> Void
    
    public init(
        style: S = .automatic,
        role: ButtonRole? = nil,
        isInMiddle: Bool = false,
        isLoading: Bool = false,
        tapAction: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> V = {EmptyView()}
    ) {
        self.style = style
        self.role = role
        self.isInMiddle = isInMiddle
        self.isLoading = isLoading
        self.label = label
        self.tapAction = tapAction
    }
    
    public var body: some View {
        BaseButton(
            title: .edit,
            systemImage: "square.and.pencil",
            role: role,
            style: style,
            bundle: .module,
            isInMiddle: isInMiddle,
            isLoading: isLoading,
            action: tapAction,
            label: label
        )
        .tint(.blue)
    }
}

package struct DemoCommonButton: View {
    package init() {}
    package var body: some View {
        NavigationStack {
            Form {
                DeleteButton(tapAction: {})
                ConfirmButton(tapAction: {})
                CancelButton(tapAction: {})
                SimpleEditButton(tapAction: {})
            }
            .formStyle(.grouped)
        }
    }
}

#Preview {
    DemoCommonButton()
}
