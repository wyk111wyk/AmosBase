//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/4/5.
//

import SwiftUI

public extension Toggle {
    /// 仅图形
    func confirmStyle(iconColor: Color = .green) -> some View {
        self.toggleStyle(ConfirmToggleStyle(iconColor: iconColor))
    }
    
    /// 图形和标题
    func labelStyle(
        font: Font = .body,
        selectLabelColor: Color = .primary,
        deselectLabelColor: Color = .secondary,
        iconColor: Color = .green,
        space: Double = 8,
        tagConfig: SimpleTagConfig? = nil
    ) -> some View {
        self.toggleStyle(
            LabelToggleStyle(
                font: font,
                selectLabelColor: selectLabelColor,
                deselectLabelColor: deselectLabelColor,
                iconColor: iconColor,
                space: space,
                tagConfig: tagConfig
            )
        )
    }
}

struct ConfirmToggleStyle: ToggleStyle {
    let iconColor: Color
    
    init(iconColor: Color) {
        self.iconColor = iconColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                .accessibility(label: Text(configuration.isOn ? "Checked" : "Unchecked"))
                .foregroundColor(configuration.isOn ? iconColor : .init(white: 0.8))
                .imageScale(.large)
        }
        .buttonStyle(.plain)
    }
}

struct LabelToggleStyle: ToggleStyle {
    let font: Font
    let selectLabelColor: Color
    let deselectLabelColor: Color
    let iconColor: Color
    let space: Double
    let tagConfig: SimpleTagConfig?
    
    init(
        font: Font,
        selectLabelColor: Color,
        deselectLabelColor: Color,
        iconColor: Color,
        space: Double,
        tagConfig: SimpleTagConfig? = nil
    ) {
        self.selectLabelColor = selectLabelColor
        self.deselectLabelColor = deselectLabelColor
        self.iconColor = iconColor
        self.font = font
        self.space = space
        self.tagConfig = tagConfig
    }
    
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack(spacing: space) {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .accessibility(label: Text(configuration.isOn ? "Checked" : "Unchecked"))
                    .foregroundColor(configuration.isOn ? iconColor : .init(white: 0.8))
                    .imageScale(.medium)
                configuration.label
                    .foregroundColor(configuration.isOn ? selectLabelColor : deselectLabelColor)
            }
            .font(font)
            .simpleTag(tagConfig)
        }
        .buttonStyle(.plain)
    }
}

#Preview(body: {
    @Previewable @State var isOn1: Bool = true
    @Previewable @State var isOn2: Bool = true
    Form {
        Toggle("Confirm", isOn: $isOn1)
            .confirmStyle()
        Toggle("Label", isOn: $isOn2)
            .labelStyle(tagConfig: .bg())
    }
    .formStyle(.grouped)
})
