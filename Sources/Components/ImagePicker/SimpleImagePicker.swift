//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2024/9/9.
//

import SwiftUI
import PhotosUI

/*
 想要使用摄像头需要进行配置：
 1. 在xcode的Signing & Capabilities中，选择App Sandbox，打开Camera选项
 2. 在plist中加入Privacy - Camera Usage Description
 */
public struct SimpleImagePicker<V: View>: View {
    public enum PickerType {
        case library, carmera, both
    }
    
    @State private var showLibrary = false
    @State private var showCamera = false
    @State private var showMenu = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var errorMsg: String?
    
    @Binding var originalImage: SFImage?
    @Binding var adjustedImage: SFImage?
    public let pickerType: PickerType
    public let maxImageWidth: CGFloat
    public let maxImageHeight: CGFloat
    public let adjustWidth: CGFloat?
    public let adjustRatio: CGFloat?
    
    @ViewBuilder public let emptyView: () -> V
    
    public init(
        originalImage: Binding<SFImage?> = .constant(nil),
        adjustedImage: Binding<SFImage?>,
        pickerType: PickerType = .both,
        maxImageWidth: CGFloat = 400,
        maxImageHeight: CGFloat = 400,
        adjustWidth: CGFloat? = nil,
        adjustRatio: CGFloat? = nil,
        @ViewBuilder emptyView: @escaping () -> V = { EmptyView() }
    ) {
        self._originalImage = originalImage
        self._adjustedImage = adjustedImage
        self.pickerType = pickerType
        self.maxImageWidth = maxImageWidth
        self.maxImageHeight = maxImageHeight
        self.adjustWidth = adjustWidth
        self.adjustRatio = adjustRatio
        self.emptyView = emptyView
    }
    
    public var body: some View {
        Group {
            #if os(watchOS)
            Button {
                showLibrary = true
            } label: {
                Image(systemName: "photo.on.rectangle.angled")
                Text("Photo album", bundle: .module)
            }
            .buttonStyle(.plain)
            #else
            Menu {
                if pickerType == .both && SimpleDevice.hasCamera() {
                    Button {
                        showLibrary = true
                    } label: {
                        Image(systemName: "photo.on.rectangle.angled")
                        Text("Photo album", bundle: .module)
                    }
                    Button {
                        showCamera = true
                    } label: {
                        Image(systemName: "camera")
                        Text("Camera", bundle: .module)
                    }
                }
            } label: {
                photoView()
            }
            .buttonStyle(.plain)
            .onTapGesture {
                selectImage()
            }
            .onDropImage { newImage in
                adjustImage(for: newImage)
            }
            #endif
        }
            .photosPicker(isPresented: $showLibrary, selection: $selectedItem, matching: .images)
            #if os(iOS)
            .sheet(isPresented: $showCamera) {
                SimpleCamera() { newPhoto in
                    adjustImage(for: newPhoto)
                }
            }
            #endif
            .onChange(of: selectedItem) {
                if let selectedItem {
                    Task {
                        if #available(macOS 14.0, iOS 16.0, watchOS 9.0, *) {
                            let newImage = try? await selectedItem.loadTransferable(type: SFImage.self)
                            adjustImage(for: newImage)
                        }
                    }
                }
            }
            .simpleAlert(title: errorMsg, isPresented: .isPresented($errorMsg))
    }
}

extension SimpleImagePicker {
    
#if !os(watchOS)
    private func selectImage() {
        switch pickerType {
        case .library:
            showLibrary = true
        case .carmera:
            if SimpleDevice.hasCamera() {
                showCamera = true
            }else {
                errorMsg = "cameraError".localized(bundle: .module)
            }
        case .both:
            if !SimpleDevice.hasCamera() {
                showLibrary = true
            }
        }
    }
#endif
    
    private func adjustImage(for image: SFImage?) {
        guard let image else { return }
        
        originalImage = image
        var newImage: SFImage = image
        if let adjustWidth, adjustWidth > 0 {
            newImage = newImage.adjustSize(width: adjustWidth)
        }
        if let adjustRatio, adjustRatio < 1 {
            if let imageData = newImage.jpegImageData(quality: adjustRatio),
               let tempImage = SFImage(data: imageData) {
                newImage = tempImage
            }
        }
        
        adjustedImage = newImage
    }
}

extension SimpleImagePicker {
    @ViewBuilder
    private func photoView() -> some View {
        if let adjustedImage {
            HStack {
                Spacer()
                Image(sfImage: adjustedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        maxWidth: maxImageWidth,
                        maxHeight: maxImageHeight
                    )
                Spacer()
            }
        }else {
            if V.self == EmptyView.self {
                HStack {
                    Spacer()
                    VStack {
                        Image(sfImage: .placeHolder)
                            .imageModify(length: 100)
                    }
                    Spacer()
                }
            }else {
                emptyView()
            }
        }
    }
}

@available(iOS 17.0, macOS 14, watchOS 10, *)
#Preview {
    @Previewable @State var originalImage: SFImage?
    @Previewable @State var adjustedImage: SFImage?
    
    NavigationStack {
        Form {
            SimpleImagePicker(
                originalImage: $originalImage,
                adjustedImage: $adjustedImage,
                pickerType: .both
            )
            Button {
                adjustedImage = nil
            } label: {
                Text("清空图片")
            }
        }
        .formStyle(.grouped)
    }
}
