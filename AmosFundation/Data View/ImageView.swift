//
//  ImageView.swift
//  AmosFundation
//
//  Created by AmosFitness on 2023/11/14.
//

import SwiftUI
import AmosBase
import PhotosUI

struct ImageView: View {
    let title: String
    init(_ title: String = "Array") {
        self.title = title
    }
    
    @State private var selectedImage: Image?
    @State private var selectedItem: PhotosPickerItem?
    @State private var showPhotoPicker = false
    
    @State private var aveColor: Color?
    @State private var exif: String = ""
    
    var body: some View {
        Form {
            Section {
                if let selectedImage {
                    selectedImage.imageModify()
                }
                PhotosPicker("挑选图片", selection: $selectedItem, matching: .images)
                    .onChange(of: selectedItem) {
                        if let selectedItem {
                            Task {
                                selectedImage = try? await selectedItem.loadTransferable(type: Image.self)
                                // 分析图片的主题颜色
                                if let newImage = selectedImage?.asUIImage(),
                                   let avg = newImage.averageColor() {
                                    aveColor = Color(uiColor: avg)
                                    if let exif = newImage.exif() {
                                        self.exif = exif.description
                                    }
                                }
                            }
                        }
                    }
            }
            
            Section("图片处理") {
                SimpleCell("图片平均色") {
                    Circle().frame(width: 30)
                        .foregroundStyle(aveColor ?? .clear)
                }
                SimpleCell("图片Exif信息", content: exif)
            }
        }
        .navigationTitle(title)
    }
}

#Preview {
    ImageView()
}
