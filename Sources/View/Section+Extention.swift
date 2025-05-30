//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/5/11.
//

import SwiftUI

public struct ExpandableHeader<V: View>: View {
    @Binding var isExpanded: Bool
    public let title: String?
    public let imageName: String?
    public let arrowColor: Color
    public let header: () -> V
    public init(
        isExpanded: Binding<Bool>,
        title: String? = nil,
        imageName: String? = nil,
        arrowColor: Color = .primary,
        @ViewBuilder header: @escaping () -> V = { EmptyView() }
    ) {
        self._isExpanded = isExpanded
        self.imageName = imageName
        self.title = title
        self.arrowColor = arrowColor
        self.header = header
    }
    
    public var body: some View {
        PlainButton {
            withAnimation {
                isExpanded.toggle()
            }
        } label: {
            HStack(spacing: 6) {
                if let imageName {
                    Image(systemName: imageName)
                }
                if let title {
                    Text(title)
                }
                if V.self != EmptyView.self {
                    header()
                }
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundStyle(arrowColor)
                    .rotationEffect(.degrees(isExpanded ? 0 : 90))
            }
            .contentShape(Rectangle())
        }
    }
}

public struct ButtonHeader<V: View>: View {
    @Binding var toggle: Bool
    let titleText: Text?
    let imageName: String?
    
    let buttonTitle: String
    let buttonImageName: String
    let buttonColor: Color
    let showButtonTitle: Bool
    
    let header: () -> V
    let tapAction: () -> Void
    
    public init(
        toggle: Binding<Bool> = .constant(false),
        titleText: Text? = nil,
        imageName: String? = nil,
        buttonTitle: String = .add,
        buttonImageName: String = "plus",
        buttonColor: Color = .secondary,
        showButtonTitle: Bool = true,
        @ViewBuilder header: @escaping () -> V = { EmptyView() },
        tapAction: @escaping () -> Void = {}
    ) {
        self._toggle = toggle
        self.imageName = imageName
        self.titleText = titleText
        self.buttonTitle = buttonTitle
        self.buttonImageName = buttonImageName
        self.buttonColor = buttonColor
        self.showButtonTitle = showButtonTitle
        self.header = header
        self.tapAction = tapAction
    }
    
    public var body: some View {
        HStack(spacing: 6) {
            if let imageName {
                Image(systemName: imageName)
            }
            if let titleText {
                titleText
            }
            if V.self != EmptyView.self {
                header()
            }
            Spacer()
            PlainButton {
                toggle.toggle()
                tapAction()
            } label: {
                HStack(spacing: 2) {
                    Image(systemName: buttonImageName)
                    if showButtonTitle {
                        Text(buttonTitle.toLocalizedKey(), bundle: .module)
                    }
                }
                .simpleTag(
                    .border(
                        verticalPad: 2,
                        horizontalPad: 8,
                        cornerRadius: 15,
                        contentColor: buttonColor
                    )
                )
                .contentShape(Rectangle())
            }
        }
    }
}

struct DemoSection: View {
    @State private var isExpanded: Bool = true
    @State private var isAdd: Bool = false
    
    var body: some View {
        Form {
            Section {
                ExpandableHeader(
                    isExpanded: $isExpanded,
                    title: "Expandable Header",
                    imageName: "folder.badge.plus",
                    arrowColor: .red
                )
                if isExpanded {
                    Text("隐藏的内容")
                        .addLeadingStar(isAdd: true)
                }
            } header: {
                ButtonHeader(
                    toggle: $isAdd,
                    titleText: Text("Addable Header"),
                    buttonTitle: .add,
                    buttonImageName: "plus",
                    buttonColor: .blue
                )
                .environment(\.locale, .zhHans)
            }
        }
    }
}

#Preview {
    DemoSection()
}
