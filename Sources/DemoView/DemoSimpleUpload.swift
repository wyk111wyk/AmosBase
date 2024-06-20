//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2024/5/15.
//

import SwiftUI
import PhotosUI

public struct DemoSimpleUpload: View {
    @AppStorage("gitToken") private var gitToken: String = ""
    @State private var showGithubKey = false
    
    @State private var showPhotoPicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: SFImage? {
        didSet {
            timeStampName = Date().timeIntervalSince1970.toString()
        }
    }
    @State private var showImage: SFImage?
    @State private var timeStampName: String = ""
    @State private var uploadPath: PicBedPath = .base
    @State private var isCrop = true
    @State private var newWidth: Int = 500
    @State private var ratio: CGFloat = 0.9
    @State private var size: String = ""
    
    @State private var isLoading = false
    @State private var error: Error?
    
    var picBed: SimplePicBed {
        SimplePicBed(gitToken: gitToken)
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    imagePicker()
                    clipImageView()
                    imageInfo()
                } header: {
                    Text("图片信息")
                }
                Section {
                    tokenSection()
                    Button {
                        imageUpload()
                    } label: {
                        SimpleCell("上传到Github", systemImage: "square.and.arrow.up") {
                            if isLoading {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isLoading || selectedImage == nil || gitToken.isEmpty)
                    Picker("图床路径", selection: $uploadPath) {
                        ForEach(PicBedPath.allCases, id: \.self) { path in
                            Text(path.title).tag(path)
                        }
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
            .navigationTitle("上传图床")
        }
        .simpleErrorToast(error: $error)
    }
    
    @ViewBuilder
    private func tokenSection() -> some View {
        if gitToken.isEmpty || showGithubKey {
            TextField("Github密钥", text: $gitToken, axis: .vertical)
                .lineLimit(nil)
                .scrollDismissesKeyboard(.automatic)
                .onSubmit { showGithubKey = false }
        }else {
            Button {
                showGithubKey = true
            } label: {
                HStack {
                    Text("Github密钥")
                    Text(gitToken.lastCharacters())
                }
            }
        }
    }
    
    @ViewBuilder
    private func imagePicker() -> some View {
        photoView()
            .onTapGesture {
                showPhotoPicker = true
            }
            #if !os(watchOS)
            .onDropImage { image in
                selectedImage = image
            }
            #endif
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedItem, matching: .images)
            .onChange(of: selectedItem) { newItem in
                #if os(iOS)
                if let newItem {
                    Task {
                        let newImage = try? await newItem.loadTransferable(type: SFImage.self)
                        chooseImage(newImage)
                    }
                }
                #endif
            }
    }
    
    @ViewBuilder
    private func photoView() -> some View {
        if let showImage {
            Image(sfImage: showImage)
                .imageModify()
        }else {
            Image(sfImage: .placeHolder)
                .imageModify(length: 100)
        }
    }
    
    @ViewBuilder
    private func clipImageView() -> some View {
        Toggle("压缩图片", isOn: $isCrop)
            .onChange(of: isCrop) { newValue in
                adjustShowImage()
            }
        if isCrop {
            SimpleCell("图片宽度W") {
                TextField("", value: $newWidth, format: .number)
                    .multilineTextAlignment(.trailing)
            }
            .onChange(of: newWidth) { newValue in
                if newValue > 0 {
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
            .onChange(of: ratio) { newValue in
                adjustShowImage()
            }
        }
    }
    
    @ViewBuilder
    private func imageInfo() -> some View {
        if let showImage {
            SimpleCell(timeStampName + ".jpeg", content: size) {
                VStack {
                    Text("w: \(showImage.width.toString())")
                    Text("h: \(showImage.height.toString())")
                }
                .foregroundStyle(.secondary)
                .font(.caption)
            }
        }
    }
}

extension DemoSimpleUpload {
    private func chooseImage(_ image: SFImage?) {
        guard let image else { return }
        selectedImage = image
        adjustShowImage()
    }
    
    @discardableResult
    private func adjustShowImage() -> Data? {
        guard let selectedImage else { return nil }
        if isCrop {
            // 进行缩放
            var newImage = selectedImage.adjustSize(width: newWidth.toDouble)
            let imageData = newImage.jpegImageData(quality: ratio)
            // 进行压缩
            if let imageData,
               let tempImage = SFImage(data: imageData) {
                newImage = tempImage
            }
            size = imageData?.count.toDouble.toStorage() ?? ""
            showImage = newImage
            return imageData
        }else {
            let imageData = selectedImage.jpegImageData(quality: ratio)
            size = imageData?.count.toDouble.toStorage() ?? ""
            showImage = selectedImage
            return imageData
        }
    }
    
    private func imageUpload() {
        guard let imageData = adjustShowImage() else
        { return }
        
        Task {
            isLoading = true
            do {
                let content = imageData.base64EncodedString()
                if let _ = try await picBed.uploadFile(
                    content: content,
                    name: timeStampName,
                    type: "jpeg",
                    path: uploadPath.path
                ) {
                    selectedItem = nil
                    selectedImage = nil
                    showImage = nil
                }
            }catch {
                self.error = error
            }
            isLoading = false
        }
    }
}

#Preview {
    DemoSimpleUpload()
}
