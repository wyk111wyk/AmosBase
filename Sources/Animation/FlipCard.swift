//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/3/17.
//

import SwiftUI

struct FlipCard: View {
    @State private var isFlipped01 = false
    @State private var isFlipped02 = false
    
    let duration: Double
    
    init(duration: Double = 0.8) {
        self.duration = duration
    }
    
    var body: some View {
        ZStack {
            Image(sfImage: .lady02Image)
                .resizable().scaledToFit()
                .frame(height: 400)
                .zIndex(isFlipped02 ? 1 : 0)
            Image(sfImage: .lady01Image)
                .resizable().scaledToFit()
                .frame(height: 400)
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 8)
        .rotation3DEffect(
            .degrees(isFlipped01 ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .onTapGesture {
            withAnimation(.spring(duration: duration)) {
                isFlipped01.toggle()
            }
            Timer.scheduledTimer(withTimeInterval: (duration / 4), repeats: false) { _ in
                withAnimation(.spring(duration: duration)) {
                    isFlipped02.toggle()
                }
            }
        }
        .overlay(alignment: .bottom) {
            Text("点击卡片反转")
                .offset(y: 80)
        }
    }
}

#Preview {
    FlipCard()
}
