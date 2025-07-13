//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/7/3.
//

import SwiftUI

// 产品寄语
struct PurchaseProductMessage: View {
    let message: String?
    
    var body: some View {
        if let message {
            let textColor: Color = .hexColor("f1f2f4")
            let bgColor: Color = .hexColor("367098")
            let shadowColor: Color = .hexColor("78abaf")
            Text(message.toLocalizedKey(), bundle: .main)
                .allowsTightening(true)
                .lineSpacing(6)
                .font(.callout)
                .foregroundStyle(textColor)
                .padding(.horizontal)
                .padding(.bottom)
                .padding(.top, 66)
                .background {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundStyle(bgColor.opacity(0.9))
                            .shadow(color: shadowColor.opacity(0.9), radius: 0, x: 10, y: 10)
                        HStack {
                            Text("“")
                                .font(.system(size: 100))
                            Text("Product Message", bundle: .module)
                                .fontDesign(.rounded)
                                .fontWeight(.semibold)
                                .font(.title)
                                .offset(y: -20)
                        }
                        .foregroundStyle(textColor)
                        .offset(x: 15)
                    }
                }
                .compositingGroup()
        }
    }
}

#Preview {
    PurchaseProductMessage(message: .randomChinese(long: true))
        .padding()
}
