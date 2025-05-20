//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/11/13.
//

import SwiftUI

public struct SimplePremiumLogo: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let verticalPadding: CGFloat
    let horizontalPadding: CGFloat
    let cornerRadius: CGFloat
    let width: CGFloat
    let isVersa: Bool
    
    public init(
        verticalPadding: CGFloat = 4.5,
        horizontalPadding: CGFloat = 6,
        cornerRadius: CGFloat = 3,
        width: CGFloat = 80,
        isVersa: Bool = false
    ) {
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
        self.cornerRadius = cornerRadius
        self.width = width
        self.isVersa = isVersa
    }
    
    var logoImage: Image {
        if colorScheme == .light {
            if isVersa {
                return Image(sfImage: .premium_w)
            }else {
                return Image(sfImage: .premium)
            }
        }else {
            if isVersa {
                return Image(sfImage: .premium)
            }else {
                return Image(sfImage: .premium_w)
            }
        }
    }
    
    var borderColor: Color {
        if colorScheme == .light {
            if isVersa { return .white
            }else { return .black }
        }else {
            if isVersa { return .black
            }else { return .white }
        }
    }
    
    public var body: some View {
        logoImage
            .resizable().scaledToFit()
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(borderColor)
            }
            .frame(width: width)
    }
}

#Preview {
    VStack(spacing: 15) {
        SimplePremiumLogo()
        SimplePremiumLogo(isVersa: true)
    }
    .padding()
    .background { Color.gray }
}
