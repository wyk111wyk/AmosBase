//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2023/12/9.
//

import SwiftUI
import PhotosUI

@available(iOS 16, macOS 13, watchOS 9, *)
struct DemoSimpleColor: View {
    let title: String
    init(_ title: String = "Color & Image") {
        self.title = title
    }
    
    @State private var selectedImage: Image?
    @State private var selectedItem: PhotosPickerItem?
    @State private var showPhotoPicker = false
    
    @State private var aveColor: Color?
    @State private var randomColor: Color?
    
    @State private var pickColor: Color = .red
    
    var body: some View {
        Form {
            Section("图片处理") {
                imagePicker()
                SimpleCell("主题颜色") {
                    if let aveColor { circleView(aveColor) }
                }
            }
            
            Section("颜色处理") {
                randomColorCell()
                ColorPicker("挑选颜色", selection: $pickColor)
            }
        }
        .navigationTitle(title)
    }
    
    private func circleView(_ color: Color) -> some View {
        Circle().frame(width: 30)
            .foregroundStyle(color)
    }
    
    @ViewBuilder
    private func randomColorCell() -> some View {
        #if canImport(UIKit)
        Button {
            randomColor = Color.random()
        } label: {
            SimpleCell("随机颜色") {
                if let randomColor { circleView(randomColor) }
            }
        }
        #endif
    }
}

@available(iOS 16, macOS 13, watchOS 9, *)
extension DemoSimpleColor {
    @ViewBuilder
    private func imagePicker() -> some View {
        if let selectedImage {
            selectedImage.imageModify()
        }
        PhotosPicker("挑选图片", selection: $selectedItem, matching: .images)
            .onChange(of: selectedItem) { newItem in
                if let newItem {
                    Task {
                        selectedImage = try? await newItem.loadTransferable(type: Image.self)
                        #if os(iOS)
                        // 分析图片的主题颜色
                        if let newImage = selectedImage?.asUIImage(),
                           let avg = newImage.averageColor() {
                            aveColor = Color(uiColor: avg)
                        }
                        #endif
                    }
                }
            }
    }
}

@available(iOS 16, macOS 13, watchOS 9, *)
#Preview("Color") {
    NavigationStack {
        DemoSimpleColor()
    }
}
