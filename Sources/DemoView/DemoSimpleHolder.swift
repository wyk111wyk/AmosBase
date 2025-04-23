//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2024/3/26.
//

import SwiftUI

struct DemoSimplePlaceholder: View {
    @Environment(\.dismiss) private var dismissPage
    @State private var selectedItem: SimplePlaceholderType?
    
    @State private var showPickerSheet = false
    
    var body: some View {
        TabView(selection: $selectedItem) {
            ForEach(SimplePlaceholderType.allCases) { type in
                placeholder(type).tag(type)
            }
        }
        #if os(iOS)
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        #endif
        .navigationTitle("占位符")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    showPickerSheet = true
                } label: {
                    Image(systemName: "rectangle.grid.2x2.fill")
                }
            }
        }
        .sheet(isPresented: $showPickerSheet) {
            pickerSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    private func placeholder(_ type: SimplePlaceholderType) -> some View {
        List {
            Text("")
            #if os(iOS)
                .listRowSeparator(.hidden)
            #endif
        }
        .listStyle(.plain)
        .simplePlaceholder(
            isPresent: true,
            type: type,
            title: type.title,
            subtitle: "Subtitle Subtitle Subtitle Subtitle Subtitle Subtitle",
            content: "content content content content content content content content content content content content content content content content"
        ) {
            Button {
                showPickerSheet = true
            }label: {
                Label("查看类别", systemImage: "rectangle.grid.2x2.fill")
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    @ViewBuilder
    private func pickerSheet() -> some View {
        NavigationStack {
            let columns = [GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 8)]
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12){
                    ForEach(SimplePlaceholderType.allCases) { type in
                        Button {
                            selectedItem = type
                            SimpleHaptic.playLightHaptic()
                            showPickerSheet = false
                        } label: {
                            VStack(spacing: 8) {
                                type.image
                                    .imageModify(length: 100)
                                Text(type.title)
                                    .font(.footnote)
                            }
                            .padding(8)
                        }
                    }
                }
                .padding()
            }
            .buttonCircleNavi(role: .cancel) {
                showPickerSheet = false
            }
            .navigationTitle("占位符选择")
            .inlineTitleForNavigationBar()
        }
    }
}

#Preview {
    NavigationStack {
        DemoSimplePlaceholder()
    }
}
