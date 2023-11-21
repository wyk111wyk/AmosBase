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
    @State private var randomColor: Color?
    
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
                                #if os(iOS)
                                // 分析图片的主题颜色
                                if let newImage = selectedImage?.asUIImage(),
                                   let avg = newImage.averageColor() {
                                    aveColor = Color(uiColor: avg)
                                }
                                #endif
                            }
                        }
                    }
            }
            
            Section("图片处理") {
                SimpleCell("图片平均色") {
                    if let aveColor {
                        Circle().frame(width: 30)
                            .foregroundStyle(aveColor)
                    }
                }
#if canImport(UIKit)
                Button {
                    randomColor = Color.random()
                } label: {
                    SimpleCell("随机颜色") {
                        if let randomColor {
                            Circle().frame(width: 30)
                                .foregroundStyle(randomColor)
                        }
                    }
                }
                #endif
            }
        }
        .navigationTitle(title)
    }
}

#Preview {
    ImageView()
}
