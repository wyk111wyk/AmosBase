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
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: SFImage?
    var defaultImage: SFImage {
        SFImage(packageResource: "IMG_5151", ofType: "jpeg")!
    }
    var placeHolder: SFImage {
        SFImage(packageResource: "photoProcess", ofType: "png")!
    }
    
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
                    if let selectedImage {
                        VStack {
                            Text("宽：\(selectedImage.width.toString())")
                            Text("长：\(selectedImage.height.toString())")
                        }
                        .font(.callout)
                    }
                }
                SimpleCell("图片大小") {
                    if let size = selectedImage?.fileSize {
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
        .task {
            if selectedImage == nil {
                selectedImage = defaultImage
                await analyzeImage()
            }
        }
    }
    
    private func circleView(_ color: Color) -> some View {
        Circle().frame(width: 30)
            .foregroundStyle(color)
    }
}

extension DemoSimpleImage {
    @ViewBuilder
    private func photoView() -> some View {
        if let selectedImage {
            Image(sfImage: selectedImage)
                .imageModify()
        }else {
            Image(sfImage: placeHolder)
                .imageModify()
        }
    }
    
    @ViewBuilder
    private func imagePicker() -> some View {
        photoView()
            #if !os(watchOS)
            .onDropImage { image in
                selectedImage = image
            }
            #endif
        PhotosPicker("挑选图片", selection: $selectedItem, matching: .images)
            #if os(iOS)
            .onChange(of: selectedItem) { newItem in
                if let newItem {
                    Task {
                        selectedImage = try? await newItem.loadTransferable(type: SFImage.self)
                        await analyzeImage()
                    }
                }
            }
        #endif
    }
    
    @MainActor
    private func adjustImageSize() async {
        #if os(iOS)
        if let selectedImage {
            let newImage = selectedImage.adjustSizeToSmall(width: 300)
            self.selectedImage = newImage
        }
        #endif
    }
    
    private func analyzeImage() async {
        #if os(iOS)
        if let selectedImage {
            // 分析图片的主题颜色
            if let avg = selectedImage.averageColor() {
                aveColor = Color(uiColor: avg)
            }
            // 分析图片中的文字
            scanText = await selectedImage.scanForText()
            // 识别图中的脸孔
            faceCount = selectedImage.detectFace()?.count
        }
        #endif
    }
}

#Preview("Image") {
    NavigationStack {
        DemoSimpleImage()
    }
}
