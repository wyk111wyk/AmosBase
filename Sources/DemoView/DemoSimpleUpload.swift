//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2024/5/15.
//

import SwiftUI
import PhotosUI

public struct DemoSimpleUpload: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: SFImage? {
        didSet {
            timeStampName = Date().timeIntervalSince1970.toString()
        }
    }
    @State private var showImage: SFImage?
    @State private var timeStampName: String = ""
    @State private var uploadPath: String = ""
    @State private var isCrop = true
    @State private var newWidth: Int = 500
    @State private var ratio: CGFloat = 0.9
    @State private var size: String = ""
    
    @State private var isLoading = false
    @State private var allImageList: [GithubRepoFileListModel] = []
    
    @State private var deleteImage: GithubRepoFileListModel?
    @State private var error: Error?
    @State private var copyContent: String?
    
    let picBed: SimplePicBed
    init(gitToken: String = "") {
        picBed = SimplePicBed(gitToken: gitToken)
    }
    
    var finalPath: String {
        if uploadPath.isEmpty {
            return "AmosBase/"
        }else {
            if uploadPath.hasSuffix("/") {
                return uploadPath
            }else {
                return uploadPath + "/"
            }
        }
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    photoView()
                        #if !os(watchOS)
                        .onDropImage { image in
                            chooseImage(image)
                        }
                        #endif
                    imagePicker()
                    clipImageView()
                    imageInfo()
                } header: {
                    Text("图片信息")
                }
                Section {
                    Button {
                        imageUpload()
                    } label: {
                        SimpleCell("上传到Github", systemImage: "square.and.arrow.up") {
                            if isLoading {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isLoading || selectedImage == nil)
                    TextField("自定义路径", text: $uploadPath, prompt: Text("自定义路径（默认AmosBase/）"))
                } header: {
                    Text("上传图床")
                }
                imageListSection()
            }
            .navigationTitle("上传图床")
        }
        .simpleErrorToast(error: $error)
        .simpleSuccessToast(presentState: .isOptionalPresented($copyContent), displayMode: .topToast, title: "复制图片URL", subtitle: copyContent ?? "无法读取链接")
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
    private func imagePicker() -> some View {
        PhotosPicker("挑选图片", selection: $selectedItem, matching: .images)
            #if os(iOS)
            .onChange(of: selectedItem) { newItem in
                if let newItem {
                    Task {
                        let newImage = try? await newItem.loadTransferable(type: SFImage.self)
                        chooseImage(newImage)
                    }
                }
            }
            #endif
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
    
    @ViewBuilder
    private func imageListSection() -> some View {
        Section {
            ForEach(allImageList) { gitImage in
                Button {
                    gitImage.download_url.copyToPasteboard()
                    copyContent = gitImage.download_url
                } label: {
                    SimpleCell(gitImage.name, content: gitImage.size.toStorage()) {
                        if let imageUrl = URL(string: gitImage.download_url) {
                            CachedAsyncImage(url: imageUrl) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(maxWidth: 100, maxHeight: 100)
                        }
                    }
                }
                .simpleSwipe(deleteAction: {
                    deleteImage = gitImage
                })
            }
        } header: {
            HStack {
                Text("图床图片：\(allImageList.count)张 ~\(finalPath)")
                Spacer()
                Button {
                    Task {
                        await fetchImageList()
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                    }else {
                        Image(systemName: "arrow.circlepath")
                    }
                }
            }
        }
        .confirmationDialog("删除图片", isPresented: .isPresented($deleteImage), titleVisibility: .visible) {
            if let deleteImage {
                Button(role: .destructive) {
                    deleteFile(deleteImage)
                } label: {
                    Text("删除\(deleteImage.name)")
                }
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
                if let updated = try await picBed.uploadFile(
                    content: content,
                    name: timeStampName,
                    type: "jpeg",
                    path: finalPath
                ) {
                    allImageList.addOrReplace(updated)
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
    
    private func fetchImageList() async {
        isLoading = true
        do {
            allImageList = try await picBed.fetchFileList(path: finalPath)
        }catch {
            self.error = error
        }
        isLoading = false
    }
    
    private func deleteFile(_ gitImage: GithubRepoFileListModel) {
        Task {
            isLoading = true
            do {
                if try await picBed.deleteFile(for: gitImage) {
                    allImageList.removeById(gitImage)
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
