//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/2/28.
//

import Foundation
import SwiftUI

#if os(iOS) || os(macOS)
public struct ImageDetailView: View {
    @Environment(\.dismiss) private var dismissPage
    
    var image: Image
    var imageOpt: Image?
    var caption: String?
    
    @State var dragOffset: CGSize = CGSize.zero
    @State var dragOffsetPredicted: CGSize = CGSize.zero
    
    public init(
        image: SFImage,
        caption: String? = nil
    ) {
        self.image = .init(sfImage: image)
        self.imageOpt = nil
        self.caption = caption
    }
    
    public init(
        image: Image?,
        caption: String? = nil
    ) {
        self.image = .init(
            packageResource: "photoProcess",
            ofType: "png"
        )
        self.imageOpt = image
        self.caption = caption
    }
    
    func getImage() -> Image {
        if let imageOpt {
            return imageOpt
        }else {
            return image
        }
    }

    @ViewBuilder
    public var body: some View {
        self.getImage()
            .resizable()
            .scaledToFit()
            .offset(x: self.dragOffset.width, 
                    y: self.dragOffset.height)
        #if os(iOS)
            .pinchToZoom()
        #endif
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.12, green: 0.12, blue: 0.12, opacity: (1.0 - Double(abs(self.dragOffset.width) + abs(self.dragOffset.height)) / 1000)).edgesIgnoringSafeArea(.all))
        .overlay(alignment: .bottom) {
            if let caption = caption, !caption.isEmpty {
                Text(caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 15)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(.regularMaterial)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
            }
        }
        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
        .onAppear() {
            self.dragOffset = .zero
            self.dragOffsetPredicted = .zero
        }
    }
}

#Preview {
    ImageDetailView(
        image: nil,
        caption: "I am IronMan I am IronMan I am IronMan I am IronMan I am IronMan I am IronMan I am IronMan I am IronMan I am IronMan"
    )
}
#endif
