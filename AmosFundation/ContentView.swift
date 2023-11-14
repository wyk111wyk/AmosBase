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
                        if page.id == 4 {
                            Button {
                                showMapShare.toggle()
                            } label: {
                                Label(page.title, systemImage: "map")
                            }
                        }else {
                            NavigationLink(value: page) {
                                Label(page.title, systemImage: "display")
                            }
                        }
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
        } detail: {
            if let selectedPage {
                switch selectedPage.id {
                case 0:
                    ToastView(selectedPage.title)
                case 1:
                    AlertView(selectedPage.title)
                case 2:
                    ButtonView(selectedPage.title, selectedPage: $selectedPage)
                case 3:
                    PlaceholderView(selectedPage.title)
                case 5:
                    SimpleWebView(url: URL(string: "https://www.baidu.com")!,
                                  pushIn: true)
                    .navigationTitle(selectedPage.title)
                    .navigationBarTitleDisplayMode(.inline)
                case 6:
                    DeviceInfoView(selectedPage.title)
                case 7:
                    ArrayView(selectedPage.title)
                case 8:
                    DateView(selectedPage.title)
                case 9:
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
