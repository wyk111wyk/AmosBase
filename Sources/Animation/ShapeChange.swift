//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/3/20.
//

import SwiftUI

struct ShapeChange: View {
    @State private var isExpanded = false
    @Namespace private var namespace
    
    var body: some View {
        VStack {
            VStack {
                if !isExpanded {
                    Spacer()
                }
                HStack {
                    if !isExpanded {
                        Spacer()
                    }
                    
                    ZStack() {
                        RoundedRectangle(cornerRadius: isExpanded ? 10 : 30)
                            .foregroundStyle(.blue)
                            .frame(
                                width: isExpanded ? nil : 60,
                                height: isExpanded ? 300 : 60
                            )
                        
                        Text("Hello SwiftUI!")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .opacity(isExpanded ? 1 : 0)
                            .scaleEffect(isExpanded ? 1 : 0.2)
                    }
                }
            }
            .frame(height: 300)
            .padding()
            .onTapGesture {
                withAnimation(.easeInOut) {
                    isExpanded.toggle()
                }
            }
            
            PlainButton {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                RoundedRectangle(cornerRadius: 8)
                    .foregroundStyle(.blue)
                    .frame(width: 200, height: 48)
                    .overlay(alignment: .center) {
                        Text("点击变换")
                            .foregroundStyle(.white)
                    }
            }
            .padding(.top, 70)
        }
    }
}

#Preview {
    ShapeChange()
}
