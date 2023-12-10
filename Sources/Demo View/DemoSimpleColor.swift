//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2023/12/9.
//

import SwiftUI
import PhotosUI

@available(iOS 16, macOS 13, watchOS 9, *)
public struct DemoSimpleColor: View {
    let title: String
    public init(_ title: String = "Color & Image") {
        self.title = title
    }
    
    @State private var selectedImage: Image?
    #if os(iOS)
    @State private var selectedUIImage: UIImage?
    #endif
    @State private var selectedItem: PhotosPickerItem?
    @State private var showPhotoPicker = false
    @State private var scanText: String? = nil
    @State private var faceCount: Int? = nil
    
    @State private var aveColor: Color?
    @State private var randomColor: Color?
    
    @State private var pickColor: Color = .red
    @State private var isLighten = false
    @State private var isDarken = false
    
    public var body: some View {
        Form {
            Section("图片处理") {
                imagePicker()
                SimpleCell("主题颜色") {
                    if let aveColor { circleView(aveColor) }
                }
                #if os(iOS)
                Button {
                    Task { await adjustImageSize() }
                } label: {
                    Text("缩放图片（宽300）")
                }
                SimpleCell("图片尺寸") {
                    if let selectedUIImage {
                        VStack {
                            Text("宽：\(selectedUIImage.width.toString())")
                            Text("长：\(selectedUIImage.height.toString())")
                        }
                    }
                }
                SimpleCell("图片大小") {
                    if let size = selectedUIImage?.fileSize {
                        Text(size.toStorage())
                    }
                }
                #endif
            }
            #if os(iOS)
            Section("图片识别") {
                SimpleCell("识别文字", stateText: scanText)
                SimpleCell("识别脸孔") {
                    if let faceCount { Text(faceCount.toString()) }
                }
            }
            #endif
            
            Section("颜色处理") {
                randomColorCell()
                #if !os(watchOS)
                ColorPicker("挑选颜色", selection: $pickColor)
                #endif
                SimpleCell("HEX", stateText: pickColor.hexString)
                darkenSection()
                lightenSection()
            }
        }
        .navigationTitle(title)
    }
    
    private func circleView(_ color: Color) -> some View {
        Circle().frame(width: 30)
            .foregroundStyle(color)
    }
    
    @ViewBuilder
    private func darkenSection() -> some View {
        Toggle("颜色变暗", isOn: $isDarken)
        if isDarken {
            SimpleCell("变暗60%") { circleView(pickColor.darken(by: 0.6)) }
            SimpleCell("变暗50%") { circleView(pickColor.darken(by: 0.5)) }
            SimpleCell("变暗40%") { circleView(pickColor.darken(by: 0.4)) }
            SimpleCell("变暗30%") { circleView(pickColor.darken(by: 0.3)) }
            SimpleCell("变暗20%") { circleView(pickColor.darken(by: 0.2)) }
            SimpleCell("变暗10%") { circleView(pickColor.darken(by: 0.1)) }
        }
    }
    
    @ViewBuilder
    private func lightenSection() -> some View {
        Toggle("颜色变淡", isOn: $isLighten)
        if isLighten {
            SimpleCell("变淡10%") { circleView(pickColor.lighten(by: 0.1)) }
            SimpleCell("变淡20%") { circleView(pickColor.lighten(by: 0.2)) }
            SimpleCell("变淡30%") { circleView(pickColor.lighten(by: 0.3)) }
            SimpleCell("变淡40%") { circleView(pickColor.lighten(by: 0.4)) }
            SimpleCell("变淡50%") { circleView(pickColor.lighten(by: 0.5)) }
            SimpleCell("变淡60%") { circleView(pickColor.lighten(by: 0.6)) }
        }
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
                        await analyzeImage()
                        #endif
                    }
                }
            }
#if os(iOS)
            .onChange(of: selectedUIImage) { newUIImage in
                if let newUIImage {
                    Task {
                        // 分析图片的主题颜色
                        if let avg = newUIImage.averageColor() {
                            aveColor = Color(uiColor: avg)
                        }
                        // 分析图片中的文字
                        scanText = await newUIImage.scanForText()
                        // 识别图中的脸孔
//                        faceCount = newUIImage.detectFace()?.count
                    }
                }
            }
#endif
    }
    
    @MainActor
    private func analyzeImage() async {
#if os(iOS)
        if let newImage = selectedImage?.asUIImage() {
            selectedUIImage = newImage
        }
#endif
    }
    
    @MainActor
    private func adjustImageSize() async {
    #if os(iOS)
        if let selectedUIImage {
            let newImage = selectedUIImage.adjustSizeToSmall(width: 300)
            self.selectedUIImage = newImage
            selectedImage = Image(uiImage: newImage)
        }
    #endif
    }
}

@available(iOS 16, macOS 13, watchOS 9, *)
#Preview("Color") {
    NavigationStack {
        DemoSimpleColor()
    }
}
