//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2024/5/15.
//

import SwiftUI
import PhotosUI

public struct DemoSimpleUpload: View {
    @SimpleSetting(.library_gitToken) var gitToken
    @State private var showGithubKey = false
    
    @State private var originalImage: SFImage?
    @State private var adjustedImage: SFImage?
    
    @State private var timeStampName: String = ""
    @State private var uploadPath: PicBedPath = .base
    @State private var isCrop = true
    @State private var newWidth: Int = 500
    @State private var ratio: CGFloat = 0.9
    @State private var imageFileSize: String = ""
    
    @State private var isLoading = false
    @State private var error: Error?
    
    var picBed: SimplePicBed {
        SimplePicBed(gitToken: gitToken)
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    tokenSection()
                }
                Section {
                    imagePicker()
                    clipImageView()
                    imageInfo()
                } header: {
                    Text("图片信息")
                }
                Section {
                    Button {
                        uploadImage()
                    } label: {
                        SimpleCell(
                            "Upload to Github",
                            systemImage: "square.and.arrow.up",
                            localizationBundle: .module
                        )
                        if isLoading {
                            ProgressView()
                        }
                    }
                    .disabled(isLoading || adjustedImage == nil || gitToken.isEmpty)
                    Picker(selection: $uploadPath) {
                        ForEach(PicBedPath.allCases, id: \.self) { path in
                            Text(path.title).tag(path)
                        }
                    } label: {
                        Text("Imagebed path", bundle: .module)
                    }
                } header: {
                    Text("上传图床")
                }
                NavigationLink {
                    SimplePicList(
                        gitToken: gitToken,
                        autoLoad: true,
                        dismissAfterTap: false,
                        copyAfterTap: true,
                        uploadPath: uploadPath
                    )
                } label: {
                    SimpleCell("浏览所有图片")
                }
            }
            .formStyle(.grouped)
            .navigationTitle("上传图床")
        }
        .simpleErrorToast(error: $error)
    }
    
    private func tokenSection() -> some View {
        SimpleTokenTextField(
            $gitToken,
            tokenTitle: "Github密钥",
            prompt: "Github密钥"
        )
    }
    
    @ViewBuilder
    private func imagePicker() -> some View {
        SimpleImagePicker(
            originalImage: $originalImage,
            adjustedImage: $adjustedImage,
            adjustWidth: isCrop ? newWidth.toCGFloat : nil,
            adjustRatio: isCrop ? ratio : nil
        )
        .onChange(of: originalImage) {
            timeStampName = Date().timeIntervalSince1970.toString()
        }
    }
    
    @ViewBuilder
    private func clipImageView() -> some View {
        Toggle("压缩图片", isOn: $isCrop.animation())
            .onChange(of: isCrop) {
                adjustShowImage()
            }
        if isCrop {
            SimpleCell("图片宽度W") {
                TextField("", value: $newWidth, format: .number)
                    .multilineTextAlignment(.trailing)
            }
            .onChange(of: newWidth) {
                if newWidth > 0 {
                    adjustShowImage()
                }
            }
            VStack(alignment: .leading) {
                if ratio == 1 {
                    Text("不压缩")
                }else {
                    Text("压缩比率：\(ratio, specifier: "%.1f")")
                }
                Slider(value: $ratio, in: 0.1...1, step: 0.1)
            }
            .onChange(of: ratio) {
                adjustShowImage()
            }
        }
    }
    
    @ViewBuilder
    private func imageInfo() -> some View {
        if let adjustedImage {
            SimpleCell(timeStampName + ".jpeg", content: imageFileSize) {
                VStack {
                    Text("w: \(adjustedImage.width.toString())")
                    Text("h: \(adjustedImage.height.toString())")
                }
                .foregroundStyle(.secondary)
                .font(.caption)
            }
        }
    }
}

extension DemoSimpleUpload {
    @discardableResult
    private func adjustShowImage() -> Data? {
        guard let originalImage else { return nil }
        if isCrop {
            // 进行缩放
            var newImage = originalImage.adjustSize(width: newWidth.toDouble)
            let imageData = newImage.jpegImageData(quality: ratio)
            // 进行压缩
            if let imageData,
               let tempImage = SFImage(data: imageData) {
                newImage = tempImage
            }
            imageFileSize = imageData?.count.toDouble.toStorage() ?? ""
            adjustedImage = newImage
            return imageData
        }else {
            let imageData = originalImage.jpegImageData(quality: ratio)
            imageFileSize = imageData?.count.toDouble.toStorage() ?? ""
            adjustedImage = originalImage
            return imageData
        }
    }
    
    @MainActor
    private func loadingChange(_ isOn: Bool = true) {
        isLoading = isOn
    }
    
    private func uploadImage() {
        guard let imageData = adjustedImage?.jpegImageData(quality: 1.0) else
        { return }
        
        Task {
            loadingChange()
            do {
                let content = imageData.base64EncodedString()
                if let _ = try await picBed.uploadFile(
                    content: content,
                    name: timeStampName,
                    type: "jpeg",
                    path: uploadPath.path
                ) {
                    adjustedImage = nil
                    originalImage = nil
                }
            }catch {
                self.error = error
            }
            loadingChange(false)
        }
    }
}

#Preview {
    DemoSimpleUpload()
}
