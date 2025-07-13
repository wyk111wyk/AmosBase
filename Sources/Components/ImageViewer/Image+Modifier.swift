//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/2/28.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func simpleImageViewer(
        selectedIndex: Binding<Int?>,
        allPhotos: [any SimpleImageStore],
        isFullScreen: Bool = false
    ) -> some View {
        #if os(macOS)
        modifier(
            LLMAnswerImageSheet(
                selectedIndex: selectedIndex,
                allPhotos: allPhotos
            )
        )
        #else
        if isFullScreen {
            modifier(
                LLMAnswerImageFullScreen(
                    selectedIndex: selectedIndex,
                    allPhotos: allPhotos
                )
            )
        }else {
            modifier(
                LLMAnswerImageSheet(
                    selectedIndex: selectedIndex,
                    allPhotos: allPhotos
                )
            )
        }
        #endif
    }
}

struct LLMAnswerImageSheet: ViewModifier {
    @Binding var selectedIndex: Int?
    let allPhotos: [any SimpleImageStore]
    
    func body(content: Content) -> some View {
        content
            .sheet(item: $selectedIndex) { select in
                MutiImageViewer(
                    allImages: allPhotos,
                    selectedIndex: select
                )
                .interactiveDismissDisabled(true)
            }
    }
}

#if os(iOS)
struct LLMAnswerImageFullScreen: ViewModifier {
    @Binding var selectedIndex: Int?
    let allPhotos: [any SimpleImageStore]
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(item: $selectedIndex) { select in
                MutiImageViewer(
                    allImages: allPhotos,
                    selectedIndex: select
                )
            }
    }
}
#endif
