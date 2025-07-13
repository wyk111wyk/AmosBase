//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2023/12/9.
//

import SwiftUI
import PhotosUI

#if !os(watchOS)
public struct DemoLLMAnswerImage: View {
    let title: String
    public init(_ title: String = "Image 图片") {
        self.title = title
    }
    
    @State private var originalImage: SFImage? = .gymGirl()
    @State private var adjustedImage: SFImage? = .gymGirl()
    
    var defaultImage: SFImage { .gymGirl() }
    
    @State private var isSaveSuccessed: Bool = false
    
    @State private var resizeImage: Bool = false
    @State private var scanText: String? = nil
    @State private var faceCount: Int? = nil
    
    @State private var aveColor: Color?
    @State private var randomColor: Color?
    
    public var body: some View {
        Form {
            Section("图片处理") {
                imagePicker()
                SimpleCell("主题颜色") {
                    if let aveColor { circleView(aveColor) }
                }
                Toggle(isOn: $resizeImage.animation()) {
                    Text("缩放图片（宽300）")
                }
                .onChange(of: resizeImage) {
                    adjustImageSize()
                }
                SimpleCell("图片尺寸") {
                    if let adjustedImage {
                        VStack {
                            Text("w: \(adjustedImage.width.toString())")
                            Text("l: \(adjustedImage.height.toString())")
                        }
                        .font(.callout)
                    }
                }
                SimpleCell("图片大小") {
                    if let size = adjustedImage?.fileSize {
                        Text(size.toStorage())
                    }
                }
            }
            
            if let originalImage {
                Section {
                    SimpleAsyncButton {
                        self.isSaveSuccessed = (try? await originalImage.saveToPhotoLibrary(accessLevel: .readWrite)) ?? false
                    } label: {
                        SimpleCell("存入相册", systemImage: "arrow.down.doc")
                    }
                }
            }
            
            Section("图片识别") {
                SimpleCell("识别文字", content: scanText)
                SimpleCell("识别脸孔") {
                    if let faceCount { Text(faceCount.toString()) }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(title)
        .simpleSuccessBanner(
            isPresented: $isSaveSuccessed,
            title: "图片已存入相册"
        )
        .task {
            await analyzeImage()
        }
    }
    
    private func circleView(_ color: Color) -> some View {
        Circle().frame(width: 30)
            .foregroundStyle(color)
    }
}

extension DemoLLMAnswerImage {
    @ViewBuilder
    private func imagePicker() -> some View {
        LLMAnswerImagePicker(
            originalImage: $originalImage,
            adjustedImage: $adjustedImage
        )
        .onChange(of: originalImage) {
            adjustImageSize()
        }
    }
    
    private func adjustImageSize() {
        guard let originalImage else { return }
        
        if resizeImage {
            let newImage = originalImage.adjustSize(length: 300)
            self.adjustedImage = newImage
        }else {
            self.adjustedImage = originalImage
        }
        
        Task { await analyzeImage() }
    }
    
    private func analyzeImage() async {
        if let adjustedImage {
            // 分析图片的主题颜色
            if let avg = adjustedImage.averageColor() {
                aveColor = Color(sfColor: avg)
            }
            // 分析图片中的文字
            scanText = await adjustedImage.scanForText()
            // 识别图中的脸孔
            faceCount = adjustedImage.detectFace()?.count
        }
    }
}

#Preview("Image") {
    NavigationStack {
        DemoLLMAnswerImage()
    }
}
#endif
