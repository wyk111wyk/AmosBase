//
//  SwiftUIView.swift
//
//
//  Created by AmosFitness on 2024/6/5.
//

import SwiftUI

struct SimpleDualView<v1: View, v2: View>: View {
    @ViewBuilder let content1: () -> v1
    @ViewBuilder let content2: () -> v2
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                VStack(alignment: .center) {
                    Spacer()
                    content1()
                    Spacer()
                }
                .frame(width: geometry.size.width / 2)
                .background{Color.red}
                content2()
                    .frame(width: geometry.size.width / 2)
                    .background{Color.blue}
            }
            .edgesIgnoringSafeArea(.all)
        }
        .listRowInsets(EdgeInsets())
    }
}

#Preview("Dual") {
    NavigationStack {
        Form {
            SimpleDualView(content1: {
                Text("1")
            }, content2: {
                Text("2")
            })
        }
    }
}
