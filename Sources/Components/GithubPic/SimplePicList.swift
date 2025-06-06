//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2024/6/2.
//

import SwiftUI

public struct SimplePicList: View {
    @Environment(\.dismiss) private var dismissPage
    
    @State private var uploadPath: PicBedPath
    @State private var isLoading = false
    @State private var allImageList: [GithubRepoFileListModel] = []
    @State private var deleteImage: GithubRepoFileListModel?
    
    @State private var selectedIndex: Int? = nil
    @State private var allImage: [ImageStoreModel] = []
    
    @State private var error: Error?
    @State private var copyContent: String?
    
    let gitToken: String
    let isPushIn: Bool
    let showPathPicker: Bool
    let autoLoad: Bool
    let dismissAfterTap: Bool
    let copyAfterTap: Bool
    public let tapImage: (GithubRepoFileListModel) -> Void
    
    public init(
        gitToken: String = "",
        isPushIn: Bool = true,
        showPathPicker: Bool = true,
        autoLoad: Bool = true,
        dismissAfterTap: Bool = false,
        copyAfterTap: Bool = true,
        uploadPath: PicBedPath = .base,
        tapImage: @escaping (GithubRepoFileListModel) -> Void = {_ in}
    ) {
        self.gitToken = gitToken
        self.isPushIn = isPushIn
        self.showPathPicker = showPathPicker
        self.autoLoad = autoLoad
        self.dismissAfterTap = dismissAfterTap
        self.copyAfterTap = copyAfterTap
        self._uploadPath = State(initialValue: uploadPath)
        self.tapImage = tapImage
    }
    
    var picBed: SimplePicBed {
        SimplePicBed(gitToken: gitToken)
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                if showPathPicker {
                    Picker(selection: $uploadPath) {
                        ForEach(PicBedPath.allCases, id: \.self) { path in
                            Text(path.title).tag(path)
                        }
                    } label: {
                        Text("Imagebed path", bundle: .module)
                    }
                }
                imageListSection()
            }
            .formStyle(.grouped)
            .navigationTitle("图床列表")
            .buttonCircleNavi(role: .cancel, isPresent: !isPushIn) {
                dismissPage()
            }
        }
        .simpleErrorBanner(error: $error)
        .simpleSuccessBanner(subTitle: $copyContent, title: "成功复制图片URL")
        #if os(iOS)
        .simpleImageViewer(
            selectedIndex: $selectedIndex,
            allPhotos: allImage
        )
        #endif
    }
    
    @ViewBuilder
    private func imageListSection() -> some View {
        Section {
            ForEach(allImageList) { gitImage in
                Button {
                    if copyAfterTap {
                        gitImage.download_url.copyToPasteboard()
                        copyContent = gitImage.download_url
                    }
                    tapImage(gitImage)
                    if dismissAfterTap {
                        dismissPage()
                    }
                } label: {
                    SimpleCell(
                        gitImage.name,
                        content: gitImage.size.toStorage()
                    ) {
                        if let imageUrl = URL(string: gitImage.download_url) {
                            SimpleAsyncImage(url: imageUrl) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .onTapGesture {
                                        if let index = allImage.firstIndex(where: {
                                            $0.id == gitImage.id
                                        }) {
                                            selectedIndex = index
                                        }
                                    }
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(maxWidth: 100, maxHeight: 100)
                        }
                    }
                }
                .buttonStyle(.borderless)
                .simpleSwipe(deleteAction: {
                    deleteImage = gitImage
                })
            }
        } header: {
            HStack {
                Text("图床图片：\(allImageList.count) 张")
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
        .task {
            if autoLoad, gitToken.isNotEmpty {
                await fetchImageList()
            }
        }
        .simpleConfirmation(type: .destructiveCancel, title: "删除图片", item: $deleteImage, confirmTap: { item in
            if let deleteImage = item {
                deleteFile(deleteImage)
            }
        })
    }
    
    @MainActor
    private func loadingChange(_ isOn: Bool = true) {
        isLoading = isOn
    }
    
    private func fetchImageList() async {
        guard gitToken.isNotEmpty else {
            error = SimpleError.customError(msg: "请先设置Github密钥")
            return
        }
        
        loadingChange()
        do {
            allImage.removeAll()
            allImageList = try await picBed.fetchFileList(path: uploadPath.path)
            if allImageList.isNotEmpty {
                for gitImage in allImageList {
                    if let sfImage = try await SimpleWeb().loadImage(from: gitImage.download_url) {
                        if !allImage.contains(where: {
                            $0.id == gitImage.id
                        }) {
                            allImage.append(
                                .init(
                                    id: gitImage.id,
                                    image: sfImage
                                )
                            )
                        }
                    }
                }
            }
        }catch {
            self.error = error
        }
        loadingChange(false)
    }
    
    private func deleteFile(_ gitImage: GithubRepoFileListModel) {
        Task {
            loadingChange()
            do {
                if try await picBed.deleteFile(for: gitImage) {
                    withAnimation {
                        allImageList.removeByItem(gitImage)
                        allImage.removeAll(where: {
                            $0.id == gitImage.id
                        })
                    }
                }
            }catch {
                self.error = error
            }
            loadingChange(false)
        }
    }
}

#Preview {
    SimplePicList()
}
