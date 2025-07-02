//
//  File.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/10/27.
//

import Foundation
import SwiftUI

public struct SimpleLogoView: View {
    @Environment(\.colorScheme) private var colorScheme
    let appUrl: URL = URL(string: "https://www.amosstudio.com.cn")!
    let logoWidth: CGFloat
    let textSize: CGFloat
    
    public init(
        logoWidth: CGFloat = 120,
        textSize: CGFloat = 11
    ) {
        self.logoWidth = logoWidth
        self.textSize = textSize
    }
    
    public var body: some View {
        logoView()
    }
    
    private var logoImage: SFImage {
        colorScheme == .dark ? .amosStudioWhite : .amosStudioBlack
    }
    
    private func logoView() -> some View {
        Link(destination: appUrl) {
            HStack {
                VStack(spacing: 1) {
                    Image(sfImage: logoImage)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.primary)
                        .frame(width: logoWidth)
                    Text("slogen", bundle: .module)
                        .font(
                            .system(
                                size: textSize,
                                weight: .light,
                                design: .default
                            )
                        )
                        .foregroundColor(.secondary)
                        .layoutPriority(1)
                        .lineLimit(nil)
                }
            }
        }
        .buttonStyle(.borderless)
    }
}
