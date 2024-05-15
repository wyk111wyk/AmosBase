//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2023/12/11.
//

import SwiftUI

@available(iOS 16, macOS 13, watchOS 10, *)
public struct DemoContent<V: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State private var selectedPage: Page?
    
    @State private var showToastPage = false
    @State private var showMapShare = false
    @State private var showPositionShare = false
    
    let githubToken: String
    @ViewBuilder let stateView: () -> V
    public init(githubToken: String = "",
                @ViewBuilder stateView: @escaping () -> V = { EmptyView() }) {
        self.githubToken = githubToken
        self.stateView = stateView
    }
    
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
#if os(iOS)
                Section("Navi - 导航") {
                    Button {
                        showMapShare.toggle()
                    } label: {
                        Label("Map Share - 导航按钮", systemImage: "map")
                    }
                    .confirmationDialog("Map Share", isPresented: $showMapShare) {
                        SimpleNavigation(mode: .navi).navigationButtons()
                    }
                    Button {
                        showPositionShare.toggle()
                    } label: {
                        Label("Map Share - 定位按钮", systemImage: "map")
                    }
                    .confirmationDialog("Map Share", isPresented: $showPositionShare) {
                        SimpleNavigation(mode: .position).navigationButtons()
                    }
                }
#endif
                
                SimpleCommonAbout(txcId: "123", userId: "123", nickName: "Amos", avatarUrl: "123", appStoreId: "123") {
                    Text("About - 关于")
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
                    DemoSimpleButton(stateView: stateView)
                case 3:
                    #if !os(macOS) && !os(watchOS)
                    DemoSimpleWeb()
                    #else
                    Text(selectedPage.title)
                    #endif
                case 4:
                    DemoSimpleDevice(selectedPage.title)
                case 5:
                    DemoSimplePlaceholder()
                case 6:
                    DemoSimpleCollection(selectedPage.title)
                case 7:
                    DemoSimpleDate()
                case 8:
                    DemoSimpleImage()
                case 9:
                    DemoSimpleColor()
                case 10:
                    DemoSimpleUnit()
                case 11:
                    DemoSimpleUpload(githubToken: githubToken)
                default:
                    Text(selectedPage.title)
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onAppear {
            if horizontalSizeClass == .regular {
                selectedPage = Page.alertSection().first
            }
        }
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
        [.init(id: 2, title: "Button - 按钮表格"),
         .init(id: 3, title: "Web - 网页"),
         .init(id: 4, title: "Device - 设备信息"),
         .init(id: 5, title: "PlaceHolder - 占位符")]
    }
    
    static func dataSection() -> [Self] {
        [.init(id: 6, title: "Collection - 集合"),
         .init(id: 7, title: "Date - 日期"),
         .init(id: 8, title: "Image - 图片"),
         .init(id: 9, title: "Color - 颜色"),
         .init(id: 10, title: "Units - 单位"),
         .init(id: 11, title: "Upload - 图床")
        ]
    }
}

#Preview {
    DemoContent()
}
