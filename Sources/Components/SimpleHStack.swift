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
                content1()
                    .frame(width: geometry.size.width / 2)
//                .background{Color.red}
                
                content2()
                    .frame(width: geometry.size.width / 2)
//                    .background{Color.blue}
            }
            .edgesIgnoringSafeArea(.all)
        }
        .listRowInsets(EdgeInsets())
    }
}

#Preview("Dual") {
    NavigationStack {
        SimpleDualView(
            content1: {
                GroupBox("按钮1") {
                    Text("HHHHH")
                }
            },
            content2: {
                Button("按钮2"){}
                    .buttonStyle(.bordered)
            }
        )
        .frame(height: 60)
        .padding(.top)
        
        Form {
            SimpleDualView(
                content1: {
                    Text("1")
                },
                content2: {
                    Text("2")
                }
            )
            SimpleDualView(
                content1: {
                    Button("按钮1"){}
                        .buttonStyle(.borderedProminent)
                },
                content2: {
                    Button("按钮2"){}
                        .buttonStyle(.bordered)
                }
            )
        }
        .formStyle(.grouped)
    }
}
