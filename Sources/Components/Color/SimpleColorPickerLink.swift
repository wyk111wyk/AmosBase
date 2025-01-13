//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2024/6/22.
//

import SwiftUI

public struct SimpleColorPickerLink: View {
    public let title: String
    public let systemImage: String?
    public let content: String?
    
    public let pickColor: Color
    public let colorAction: (Color) -> Void
    
    public init(
        title: String = "自定义颜色",
        systemImage: String? = "paintpalette",
        content: String? = nil,
        pickColor: Color = .random(),
        colorAction: @escaping (Color) -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.content = content
        self.pickColor = pickColor
        self.colorAction = colorAction
    }
    
    public var body: some View {
        NavigationLink {
            SimpleColorPicker(
                selectedColor: pickColor
            ) { newColor in
                colorAction(newColor)
            }
        } label: {
            SimpleCell(
                title,
                systemImage: systemImage,
                content: content
            ) {
                circleView(pickColor)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func circleView(_ color: Color) -> some View {
        Circle().frame(width: 26)
            .foregroundStyle(color)
    }
}

#Preview {
    NavigationStack {
        Form {
            SimpleColorPickerLink() { _ in }
        }
        .formStyle(.grouped)
    }
}
