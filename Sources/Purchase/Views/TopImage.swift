//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/7/3.
//

import SwiftUI

struct PurchaseTopImage: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let titleSlogen: String?
    let titleImage_w: Image
    let titleImage_b: Image?
    let showImageCaption: Bool
    
    init(
        titleSlogen: String? = nil,
        titleImage_w: Image,
        titleImage_b: Image? = nil,
        showImageCaption: Bool = true
    ) {
        self.titleSlogen = titleSlogen
        self.titleImage_w = titleImage_w
        self.titleImage_b = titleImage_b
        self.showImageCaption = showImageCaption
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: 8) {
                    topLog()
                    if let titleSlogen {
                        Text(titleSlogen.toLocalizedKey(), bundle: .main)
                            .font(.callout)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .padding(.bottom, 8)
            deviceImage
            if showImageCaption {
                Text("Single Purchase · Devices Access", bundle: .module)
                    .foregroundStyle(LinearGradient(
                        colors: [Color.secondary.opacity(0.9), Color.secondary.opacity(0.5)],
                        startPoint: .bottom,
                        endPoint: .top
                    ))
                    .font(.body.weight(.medium))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 30)
                    .background {
                        Capsule().stroke(
                            LinearGradient(
                                colors: [Color.secondary.opacity(0.9), Color.secondary.opacity(0.38)],
                                startPoint: .bottom,
                                endPoint: .top
                            ),
                            lineWidth: 1.3
                        )
                    }
            }
        }
        .padding(.horizontal, 2)
    }
    
    @ViewBuilder
    private func topLog() -> some View {
        if colorScheme == .light {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(LinearGradient(colors: [Color.black.opacity(0.9), Color.black.opacity(0.73)], startPoint: .trailing, endPoint: .leading))
                    .frame(width: 220, height: 44)
                HStack(spacing: 12) {
                    Image(sfImage: .dimond_w)
                        .resizable().scaledToFit()
                        .frame(width: 32)
                    Text("Membership", bundle: .module)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.white)
                }
            }
        }else {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(LinearGradient(colors: [Color.white.opacity(0.96), Color.white.opacity(0.8)], startPoint: .trailing, endPoint: .leading))
                    .frame(width: 220, height: 44)
                HStack(spacing: 12) {
                    Image(sfImage: .dimond)
                        .resizable().scaledToFit()
                        .frame(width: 32)
                    Text("Membership", bundle: .module)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(.black)
                }
            }
            .padding(.horizontal, 30)
        }
    }
    
    private var deviceImage: some View {
        if colorScheme == .light {
            titleImage_w
                .resizable().scaledToFit()
        } else {
            if let titleImage_b {
                titleImage_b
                    .resizable().scaledToFit()
            }else {
                titleImage_w
                    .resizable().scaledToFit()
            }
        }
    }
}

#Preview {
    PurchaseTopImage(
        titleSlogen: "体验完整AI魅力",
        titleImage_w: Image(sfImage: .device)
    )
        .environment(\.locale, .zhHans)
}
