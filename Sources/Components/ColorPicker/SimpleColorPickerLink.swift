//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2024/6/22.
//

import SwiftUI

public struct SimpleColorPickerLink: View {
    public let title: String
    
    @State private var pickColor: Color
    public let colorAction: (Color) -> Void
    
    public init(
        title: String = "自定义颜色",
        pickColor: Color = .random(),
        colorAction: @escaping (Color) -> Void
    ) {
        self.title = title
        self.pickColor = pickColor
        self.colorAction = colorAction
    }
    
    public var body: some View {
        NavigationLink {
            SimpleColorPicker { newColor in
                pickColor = newColor
                colorAction(newColor)
            }
        } label: {
            SimpleCell("自定义颜色") {
                circleView(pickColor)
            }
        }
    }
    
    private func circleView(_ color: Color) -> some View {
        Circle().frame(width: 26)
            .foregroundStyle(color)
    }
}

#Preview {
    NavigationStack {
        Form {
            SimpleColorPickerLink(pickColor: .random()) { _ in }
        }
    }
}
