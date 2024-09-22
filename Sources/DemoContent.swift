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
    
    let iCloudIdentifier: String
    @ViewBuilder let stateView: () -> V
    public init(
        iCloudIdentifier: String = "",
        @ViewBuilder stateView: @escaping () -> V = { EmptyView() }
    ) {
        self.iCloudIdentifier = iCloudIdentifier
        self.stateView = stateView
    }
    
    public var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selectedPage) {
                Section("UI - 提醒") {
                    ForEach(Page.alertSection()) { page in
                        NavigationLink(value: page) {
                            Label(page.title, systemImage: page.icon ?? "bell")
                        }
                    }
                    Button {
                        showToastPage.toggle()
                    } label: {
                        Label("Toast - Sheet页面", systemImage: "rectangle.portrait.topthird.inset.filled")
                    }
                }
                Section("UI - 页面元素") {
                    ForEach(Page.elementSection()) { page in
                        NavigationLink(value: page) {
                            Label(page.title, systemImage: page.icon ?? "display")
                        }
                    }
                }
                Section("Data - 数据处理") {
                    ForEach(Page.dataSection()) { page in
                        NavigationLink(value: page) {
                            Label(page.title, systemImage: page.icon ?? "externaldrive")
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
                        Label("Map Share - 定位按钮", systemImage: "mappin.circle")
                    }
                    .confirmationDialog(
                        "Map Share".localized(
                            bundle: .module
                        ),
                        isPresented: $showPositionShare
                    ) {
                        SimpleNavigation(mode: .position).navigationButtons()
                    }
                }
#endif
                
                SimpleCommonAbout(txcId: "123", userId: "123", nickName: "Amos", avatarUrl: "123", appStoreId: "123", headerView: {
                    Text("About - 关于")
                })
            }
            .navigationTitle("AmosBase".localized(bundle: .module))
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
                    if #available(iOS 17.0, macOS 14, watchOS 10, *) {
                        DemoSimpleCard()
                    } else {
                        Text("Require iOS 17", bundle: .module)
                    }
                case 4:
                    #if os(iOS)
                    DemoSimpleWeb()
                    #else
                    Text("Only for iOS")
                    #endif
                case 5:
                    DemoSimpleDevice(selectedPage.title)
                case 6:
                    DemoSimplePlaceholder()
                case 7:
                    DemoSimpleCloud(iCloudIdentifier: iCloudIdentifier)
                case 8:
                    DemoSimpleUpload()
                case 9:
                    DemoSimpleCollection(selectedPage.title)
                case 10:
                    DemoSimpleDate()
                case 11:
                    #if os(iOS)
                    DemoSimpleImage()
                    #else
                    Text("Only for iOS")
                    #endif
                case 12:
                    SimpleColorPicker(
                        selectedColor: .random(),
                        isPush: true
                    ) { _ in }
                case 13:
                    DemoSimpleUnit()
                case 14:
                    DemoSimpleData()
                case 15:
                    DemoSimpleLanguage()
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
    let icon: String?
    
    init(
        id: Int,
        title: String,
        icon: String? = nil
    ) {
        self.id = id
        self.title = title
        self.icon = icon
    }
    
    static func alertSection() -> [Self] {
        [.init(id: 0, title: "Toast - 简单提醒", icon: "rectangle.portrait.topthird.inset.filled"),
         .init(id: 1, title: "Alert - 系统提醒")]
    }
    
    static func elementSection() -> [Self] {
        [.init(id: 2, title: "UI - 页面元素", icon: "uiwindow.split.2x1"),
         .init(id: 3, title: "Card - 卡片", icon: "rectangle.portrait.on.rectangle.portrait.angled"),
         .init(id: 4, title: "Web - 网页", icon: "safari"),
         .init(id: 5, title: "Device - 设备信息", icon: "iphone.gen3"),
         .init(id: 6, title: "PlaceHolder - 占位符", icon: "doc.text.image")]
    }
    
    static func dataSection() -> [Self] {
        [.init(id: 7, title: "iCloud - 云存储", icon: "arrow.clockwise.icloud"),
         .init(id: 8, title: "Upload - 图床", icon: "photo.badge.arrow.down"),
         .init(id: 9, title: "Collection - 集合", icon: "rectangle.grid.3x2"),
         .init(id: 10, title: "Date - 日期", icon: "calendar.badge.clock"),
         .init(id: 11, title: "Image - 图片", icon: "photo"),
         .init(id: 12, title: "Color - 颜色", icon: "paintpalette"),
         .init(id: 13, title: "Units - 单位", icon: "gauge.with.dots.needle.33percent"),
         .init(id: 14, title: "Data - 编解码", icon: "externaldrive"),
         .init(id: 15, title: "NL - 自然语言", icon: "character.book.closed")
        ]
    }
}

@available(iOS 16, macOS 13, watchOS 10, *)
#Preview {
    DemoContent()
}
