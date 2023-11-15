//
//  ContentView.swift
//  AmosFundation
//
//  Created by AmosFitness on 2023/11/9.
//

import SwiftUI
import AmosBase
import CoreLocation

struct ContentView: View {
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State private var selectedPage: Page?
    
    @State private var showToastPage = false
    @State private var showMapShare = false
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selectedPage) {
                Section("UI - 提醒") {
                    ForEach(Page.alertSection()) { page in
                        NavigationLink(value: page) {
                            Label(page.title, systemImage: "bell")
                        }
                    }
                }
                Section("UI - 页面元素") {
                    ForEach(Page.elementSection()) { page in
                        NavigationLink(value: page) {
                            Label(page.title, systemImage: "display")
                        }
                    }
                }
                Section("Sheet - 按钮") {
                    #if os(iOS)
                    Button {
                        showMapShare.toggle()
                    } label: {
                        Label("Map Share - 导航按钮", systemImage: "map")
                    }
                    #endif
                    Button {
                        showToastPage.toggle()
                    } label: {
                        Label("Toast - Sheet页面", systemImage: "bell")
                    }
                }
                Section("Data - 数据处理") {
                    ForEach(Page.dataSection()) { page in
                        NavigationLink(value: page) {
                            Label(page.title, systemImage: "externaldrive")
                        }
                    }
                }
            }
            .navigationTitle("Amos基础库")
            .sheet(isPresented: $showToastPage) {
                NavigationStack {
                    ToastTestView("Sheet页面测试")
                        .buttonCircleNavi(role: .cancel) { showToastPage.toggle() }
                }
            }
        } detail: {
            if let selectedPage {
                switch selectedPage.id {
                case 0:
                    ToastTestView(selectedPage.title)
                case 1:
                    AlertView(selectedPage.title)
                case 2:
                    ButtonView(selectedPage.title, selectedPage: $selectedPage)
                case 3:
                    PlaceholderView(selectedPage.title)
                case 4:
                    #if !os(macOS) && !os(watchOS)
                    SimpleWebView(url: URL(string: "https://www.baidu.com")!,
                                  pushIn: true)
                    .navigationTitle(selectedPage.title)
                    .navigationBarTitleDisplayMode(.inline)
                    #else
                    Text(selectedPage.title)
                    #endif
                case 5:
                    DeviceInfoView(selectedPage.title)
                case 6:
                    ArrayView(selectedPage.title)
                case 7:
                    DateView(selectedPage.title)
                case 8:
                    ImageView(selectedPage.title)
                default:
                    Text(selectedPage.title)
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .confirmationDialog("Map Share", isPresented: $showMapShare) {
            MapShareHelper().navigationButtons()
        }
    }
}

#Preview {
    ContentView()
}
