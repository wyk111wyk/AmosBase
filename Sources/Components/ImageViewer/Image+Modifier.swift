//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/2/28.
//

import SwiftUI

#if os(iOS) || os(macOS)
public extension View {
    func simpleImageViewer(
        selectedIndex: Binding<Int?>,
        allPhotos: [SimpleImageStore]
    ) -> some View {
        modifier(
            SimpleImageViewer(
                selectedIndex: selectedIndex,
                allPhotos: allPhotos
            )
        )
    }
}

struct SimpleImageViewer: ViewModifier {
    @Binding var selectedIndex: Int?
    let allPhotos: [SimpleImageStore]
    
    func body(content: Content) -> some View {
        content
            .sheet(item: $selectedIndex) { select in
                MutiImageViewer(allImages: allPhotos,
                                selectedIndex: select)
            }
    }
}
#endif
