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
    
    @State private var error: Error?
    @State private var copyContent: String?
    
    let gitToken: String
    let isPushIn: Bool
    let showPathPicker: Bool
    let autoLoad: Bool
    let dismissAfterTap: Bool
    let copyAfterTap: Bool
    public let tapImage: (GithubRepoFileListModel) -> Void
    
    public init(gitToken: String = "",
                isPushIn: Bool = true,
                showPathPicker: Bool = true,
                autoLoad: Bool = true,
                dismissAfterTap: Bool = false,
                copyAfterTap: Bool = true,
                uploadPath: PicBedPath = .base,
                tapImage: @escaping (GithubRepoFileListModel) -> Void = {_ in}) {
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
                    Picker("图床路径", selection: $uploadPath) {
                        ForEach(PicBedPath.allCases, id: \.self) { path in
                            Text(path.title).tag(path)
                        }
                    }
                }
                imageListSection()
            }
            .navigationTitle("图床列表")
            .buttonCircleNavi(role: .cancel, isPresent: !isPushIn) {
                dismissPage()
            }
        }
        .simpleErrorToast(error: $error)
        .simpleSuccessToast(presentState: .isOptionalPresented($copyContent), displayMode: .topToast, title: "复制图片URL", subtitle: copyContent ?? "无法读取链接")
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
    
    private func fetchImageList() async {
        guard gitToken.isNotEmpty else {
            error = SimpleError.customError(msg: "请先设置Github密钥")
            return
        }
        
        isLoading = true
        do {
            allImageList = try await picBed.fetchFileList(path: uploadPath.path)
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
    SimplePicList()
}
