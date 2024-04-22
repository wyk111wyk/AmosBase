//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2023/12/9.
//

import SwiftUI
import PhotosUI

public struct DemoSimpleImage: View {
    let title: String
    public init(_ title: String = "Image 图片") {
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
    
    @State private var selectedPhotoIndex: Int? = nil
    
    @State private var aveColor: Color?
    @State private var randomColor: Color?
    
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
            Section {
                Button {
                    selectedPhotoIndex = 0
                } label: {
                    Label("Image - 图片查看", systemImage: "photo.on.rectangle.angled")
                }
                .simpleImageViewer(selectedIndex: $selectedPhotoIndex,
                                   allPhotos: ImageStoreModel.examples())
            }
            #endif
        }
        .navigationTitle(title)
    }
    
    private func circleView(_ color: Color) -> some View {
        Circle().frame(width: 30)
            .foregroundStyle(color)
    }
}

@available(iOS 16, macOS 13, watchOS 9, *)
extension DemoSimpleImage {
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

#Preview("Image") {
    NavigationStack {
        DemoSimpleImage()
    }
}
