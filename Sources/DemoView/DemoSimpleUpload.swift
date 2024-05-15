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
            if let selectedImage {
                tempFile = selectedImage.tempPath(timeStampName)
            }
        }
    }
    @State private var timeStampName: String = ""
    @State private var uploadPath: String = ""
    @State private var tempFile: URL?
    
    @State private var isLoading = false
    @State private var allImageList: [GithubRepoFileListModel] = []
    @State private var deleteImage: GithubRepoFileListModel?
    
    var defaultImage: SFImage {
        SFImage(packageResource: "IMG_5151", ofType: "jpeg")!
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    imagePicker()
                    imageInfo()
                } header: {
                    Text("图片信息")
                }
                Section {
                    Button {
                        imageUpload()
                    } label: {
                        SimpleCell("上传到Github") {
                            if isLoading {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isLoading)
                    TextField("自定义路径", text: $uploadPath, prompt: Text("自定义路径（默认AmosBase/）"))
                } header: {
                    Text("上传图床")
                }
                imageListSection()
            }
            .navigationTitle("上传图床")
        }
        .onAppear {
            if selectedImage == nil {
//                selectedImage = defaultImage
            }
        }
    }
    
    @ViewBuilder
    private func imagePicker() -> some View {
        if let selectedImage {
            Image(sfImage: selectedImage).imageModify()
                .onTapGesture {
                    self.selectedImage = defaultImage
                }
        }
        PhotosPicker("挑选图片", selection: $selectedItem, matching: .images)
            #if os(iOS)
            .onChange(of: selectedItem) { newItem in
                if let newItem {
                    Task {
                        selectedImage = try? await newItem.loadTransferable(type: SFImage.self)?.adjustSizeToSmall(width: 500)
                    }
                }
            }
            #endif
    }
    
    @ViewBuilder
    private func imageInfo() -> some View {
        if let selectedImage {
            SimpleCell(timeStampName, content: selectedImage.fileSize.toStorage()) {
                VStack {
                    Text("w: \(selectedImage.width.toString())")
                    Text("h: \(selectedImage.height.toString())")
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
                SimpleCell(gitImage.name, content: gitImage.size.toStorage()) {
                    if let imageUrl = URL(string: gitImage.download_url) {
                        AsyncImage(url: imageUrl) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(maxWidth: 100, maxHeight: 100)
                    }
                }
                .simpleSwipe(deleteAction: {
                    deleteImage = gitImage
                })
            }
        } header: {
            HStack {
                Text("图床图片：\(allImageList.count)张")
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
    
    private func deleteFile(_ gitImage: GithubRepoFileListModel) {
        Task {
            isLoading = true
            if await SimplePicBed().deleteFile(for: gitImage) {
                allImageList.removeById(gitImage)
            }
            isLoading = false
        }
    }
}

extension DemoSimpleUpload {
    private func imageUpload() {
        guard let selectedImage,
              let imageData = selectedImage.jpegData() else
        { return }
        
        Task {
            isLoading = true
            let content = imageData.base64EncodedString()
            await SimplePicBed().uploadFile(
                content: content,
                name: timeStampName,
                type: "jpeg"
            )
            isLoading = false
        }
    }
    
    private func fetchImageList() async {
        isLoading = true
        allImageList = await SimplePicBed().fetchFileList()
        isLoading = false
    }
}

#Preview {
    DemoSimpleUpload()
}
