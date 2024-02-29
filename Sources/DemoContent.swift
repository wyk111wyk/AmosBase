//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2023/12/11.
//

import SwiftUI

@available(iOS 16, macOS 13, watchOS 10, *)
public struct DemoContent: View {
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State private var selectedPage: Page?
    
    @State private var showToastPage = false
    @State private var showMapShare = false
    @State private var showPositionShare = false
    
    @State private var selectedIndex: Int? = nil
    public init() {}
    
    public var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selectedPage) {
                Section("UI - 提醒") {
                    ForEach(Page.alertSection()) { page in
                        NavigationLink(value: page) {
                            Label(page.title, systemImage: "bell")
                        }
                    }
                    Button {
                        showToastPage.toggle()
                    } label: {
                        Label("Toast - Sheet页面", systemImage: "bell")
                    }
#if os(iOS)
                    Button {
                        selectedIndex = 0
                    } label: {
                        Label("Image - 图片查看", systemImage: "photo.on.rectangle.angled")
                    }
                    .simpleImageViewer(selectedIndex: $selectedIndex,
                                       allPhotos: ImageStoreModel.examples())
#endif
                }
                Section("UI - 页面元素") {
                    ForEach(Page.elementSection()) { page in
                        NavigationLink(value: page) {
                            Label(page.title, systemImage: "display")
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
                Section("Navi - 导航") {
                    #if os(iOS)
                    Button {
                        showMapShare.toggle()
                    } label: {
                        Label("Map Share - 导航按钮", systemImage: "map")
                    }
                    .confirmationDialog("Map Share", isPresented: $showMapShare) {
                        SimpleMapShare(mode: .navi).navigationButtons()
                    }
                    Button {
                        showPositionShare.toggle()
                    } label: {
                        Label("Map Share - 定位按钮", systemImage: "map")
                    }
                    .confirmationDialog("Map Share", isPresented: $showPositionShare) {
                        SimpleMapShare(mode: .position).navigationButtons()
                    }
                    #endif
                }
            }
            .navigationTitle("Amos基础库")
            .sheet(isPresented: $showToastPage) {
                NavigationStack {
                    DemoSimpleToast()
                        .navigationTitle("Sheet页面测试")
                        .buttonCircleNavi(role: .cancel) { showToastPage.toggle() }
                }
            }
        } detail: {
            if let selectedPage {
                switch selectedPage.id {
                case 0:
                    DemoSimpleToast()
                case 1:
                    DemoSimpleAlert()
                case 2:
                    DemoSimpleButton()
                case 3:
                    #if !os(macOS) && !os(watchOS)
                    SimpleWebView(url: URL(string: "https://www.baidu.com")!,
                                  pushIn: true)
                    .navigationTitle(selectedPage.title)
                    .navigationBarTitleDisplayMode(.inline)
                    #else
                    Text(selectedPage.title)
                    #endif
                case 4:
                    DemoSimpleDevice(selectedPage.title)
                case 5:
                    DemoSimpleCollection(selectedPage.title)
                case 6:
                    DemoSimpleDate()
                case 7:
                    DemoSimpleColor()
                case 8:
                    DemoSimpleUnit()
                default:
                    Text(selectedPage.title)
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

struct Page: Identifiable, Equatable, Hashable {
    static func == (lhs: Page, rhs: Page) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: Int
    let title: String
    
    init(id: Int, title: String) {
        self.id = id
        self.title = title
    }
    
    static func alertSection() -> [Self] {
        [.init(id: 0, title: "Toast - 简单提醒"),
         .init(id: 1, title: "Alert - 系统提醒")]
    }
    
    static func elementSection() -> [Self] {
        [.init(id: 2, title: "Button & Cell - 按钮表格"),
         .init(id: 3, title: "Web Page - 网页"),
         .init(id: 4, title: "Device Info - 设备信息")]
    }
    
    static func dataSection() -> [Self] {
        [.init(id: 5, title: "Collection"),
         .init(id: 6, title: "Date - 日期"),
         .init(id: 7, title: "Image - 图片"),
         .init(id: 8, title: "Units - 单位")
        ]
    }
}

@available(iOS 16, macOS 13, watchOS 10, *)
#Preview {
    DemoContent()
}
