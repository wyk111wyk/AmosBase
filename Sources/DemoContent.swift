//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2023/12/11.
//

import SwiftUI

public struct DemoContent<V: View, C: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State private var selectedPage: Page?
    
    @State private var showToastPage = false
    @State private var showMapShare = false
    @State private var showPositionShare = false
    
    @State private var showWelcomePage = false
    
    let iCloudIdentifier: String
    @ViewBuilder let hiddenView: () -> V
    
    @ViewBuilder let customView: () -> C
    public init(
        iCloudIdentifier: String = "",
        @ViewBuilder hiddenView: @escaping () -> V = { EmptyView() },
        @ViewBuilder customView: @escaping () -> C = { EmptyView() }
    ) {
        self.iCloudIdentifier = iCloudIdentifier
        self.hiddenView = hiddenView
        self.customView = customView
    }
    
    public var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $selectedPage) {
                Section("UI - 提醒") {
                    ForEach(Page.alertSection()) { page in
                        NavigationLink(value: page) {
                            SimpleCell(page.title, systemImage: page.icon)
                        }
                    }
                    Button {
                        showToastPage.toggle()
                    } label: {
                        SimpleCell("Toast - Sheet页面", systemImage: "rectangle.portrait.bottomthird.inset.filled")
                    }
                    .buttonStyle(.borderless)
                    .sheet(isPresented: $showToastPage) {
                        NavigationStack {
                            DemoSimpleToast()
                                .navigationTitle("Sheet页面测试")
                                .buttonCircleNavi(role: .cancel) { showToastPage.toggle() }
                        }
                    }
                }
                Section("UI - 页面元素") {
                    ForEach(Page.elementSection()) { page in
                        NavigationLink(value: page) {
                            SimpleCell(page.title, systemImage: page.icon)
                        }
                    }
                    Button {
                        showWelcomePage.toggle()
                    } label: {
                        SimpleCell("Welcome - 欢迎页", systemImage: "list.bullet.below.rectangle")
                    }
                    .buttonStyle(.borderless)
                    .sheet(isPresented: $showWelcomePage) {
                        SimpleWelcome<EmptyView>(
                            allIntroItems: .allExamples,
                            appName: "AmosBase",
                            continueType: .dismiss)
                        .interactiveDismissDisabled(true)
                    }
                }
                Section("Cus - 控制页面") {
                    #if os(iOS)
                    let control = Page(id: 18, title: "Controls - 应用管理", icon: "app.badge.clock")
                    NavigationLink(value: control) {
                        SimpleCell(control.title, systemImage: control.icon) {
                            if control.isOn {
                                Circle()
                                    .frame(width: 14, height: 14)
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                    #endif
                }
                Section("Web - 网络关联") {
                    ForEach(Page.webSection()) { page in
                        NavigationLink(value: page) {
                            SimpleCell(page.title, systemImage: page.icon)
                        }
                    }
                }
                Section("Data - 数据处理") {
                    ForEach(Page.dataSection()) { page in
                        NavigationLink(value: page) {
                            SimpleCell(page.title, systemImage: page.icon)
                        }
                    }
                }
                #if !os(watchOS)
                navigationButtons()
                #endif
                
                SimpleCommonAbout(
                    txcId: "123",
                    appStoreId: "123",
                    hasSubscribe: true,
                    headerView: {
                    Text("About - 关于")
                })
            }
            #if !os(watchOS)
            .listStyle(.sidebar)
            #endif
            .navigationSplitViewColumnWidth(ideal: 250, max: 400)
            .navigationTitle("AmosBase".localized(bundle: .module))
        } detail: {
            if let selectedPage {
                switch selectedPage.id {
                case 0: DemoSimpleToast()
                case 1: DemoSimpleAlert()
                case 2: DemoSimpleUIElement(hiddenView: hiddenView)
                case 3: DemoSimpleCard()
                case 4:
                    #if !os(watchOS)
                    DemoSimpleWeb()
                    #else
                    Text("Only for iOS")
                    #endif
                case 5: DemoSimpleDevice(selectedPage.title)
                case 6: DemoSimplePlaceholder()
                case 7: DemoSimpleCloud(iCloudIdentifier: iCloudIdentifier)
                case 8: DemoSimpleUpload()
                case 9: DemoSimpleCollection(selectedPage.title)
                case 10: DemoSimpleDate()
                case 11:
                    #if !os(watchOS)
                    DemoSimpleImage()
                    #else
                    Text("Only for iOS")
                    #endif
                case 12: SimpleColorPicker(selectedColor: .random())
                case 13: DemoSimpleUnit()
                case 14: DemoSimpleCode()
                case 15: DemoSimpleLanguage()
                case 16: DemoSimpleText(markdown: String.testText(.markdown02))
                case 17: DemoSimpleWebLoad()
                #if os(iOS)
                case 18: customView()
                #endif
                case 19: DemoSimpleCrypto()
                case 20: DemoSimpleHaptic()
                case 21: DemoSimpleButton()
                default: Text(selectedPage.title)
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
    
    private func navigationButtons() -> some View {
        Section("Navi - 导航") {
            Button {
                showMapShare.toggle()
            } label: {
                SimpleCell("Map - 导航", systemImage: "map")
            }
            .buttonStyle(.borderless)
            .confirmationDialog("Map Share", isPresented: $showMapShare) {
                SimpleNavigation(mode: .navi).navigationButtons()
            }
            Button {
                showPositionShare.toggle()
            } label: {
                SimpleCell("Map - 定位", systemImage: "mappin.circle")
            }
            .buttonStyle(.borderless)
            .confirmationDialog(
                "Map Share".localized(
                    bundle: .module
                ),
                isPresented: $showPositionShare
            ) {
                SimpleNavigation(mode: .position).navigationButtons()
            }
        }
    }
}

public struct Page: Identifiable, Equatable, Hashable {
    public static func == (lhs: Page, rhs: Page) -> Bool {
        lhs.id == rhs.id
    }
    
    public let id: Int
    let title: String
    let icon: String
    let isOn: Bool
    
    public init(
        id: Int,
        title: String,
        icon: String,
        isOn: Bool = false
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.isOn = isOn
    }
    
    static func alertSection() -> [Self] {
        [.init(id: 0, title: "Toast - 简单提醒", icon: "rectangle.portrait.topthird.inset.filled"),
         .init(id: 1, title: "Alert - 系统提醒", icon: "bell")]
    }
    
    static func elementSection() -> [Self] {
        let commonElements: [Self] =
        [.init(id: 2, title: "UI - 页面元素", icon: "uiwindow.split.2x1"),
         .init(id: 21, title: "Button - 按钮", icon: "rectangle.inset.topleft.filled"),
         .init(id: 3, title: "Card - 卡片", icon: "rectangle.portrait.on.rectangle.portrait.angled"),
         .init(id: 5, title: "Device - 设备信息", icon: "iphone.gen3"),
         .init(id: 20, title: "Haptic - 震动", icon: "iphone.homebutton.radiowaves.left.and.right"),
         .init(id: 6, title: "Holder - 占位符", icon: "doc.text.image")
         ]
        
        return commonElements
    }
    
    static func webSection() -> [Self] {
        [.init(id: 7, title: "iCloud - 云存储", icon: "arrow.clockwise.icloud"),
         .init(id: 8, title: "Upload - 图床", icon: "photo.badge.arrow.down"),
         .init(id: 17, title: "FTP - 网络传输", icon: "arrow.left.arrow.right.square"),
         .init(id: 4, title: "Web - 网页浏览", icon: "safari")]
    }
    
    static func dataSection() -> [Self] {
        [.init(id: 9, title: "Collection - 集合", icon: "rectangle.grid.3x2"),
         .init(id: 10, title: "Date - 日期", icon: "calendar.badge.clock"),
         .init(id: 11, title: "Image - 图片", icon: "photo"),
         .init(id: 12, title: "Color - 颜色", icon: "paintpalette"),
         .init(id: 13, title: "Units - 单位", icon: "gauge.with.dots.needle.33percent"),
         .init(id: 14, title: "Data - 编解码", icon: "externaldrive"),
         .init(id: 15, title: "NL - 自然语言", icon: "character.book.closed"),
         .init(id: 16, title: "Text - 可选文字", icon: "richtext.page"),
         .init(id: 19, title: "AES - 加解密", icon: "lock.shield")
        ]
    }
}

#Preview {
    DemoContent()
}
