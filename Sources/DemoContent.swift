//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2023/12/11.
//

import SwiftUI

public struct DemoContent: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State private var selectedPage: Page?
    
    @State private var showToastPage = false
    @State private var showMapShare = false
    @State private var showPositionShare = false
    
    @State private var showPurchasePage = false
    @State private var showWelcomePage = false
    
    let iCloudIdentifier: String
    let additionViews: [AnyView]
    
    public init(
        iCloudIdentifier: String = "",
        additionViews: [AnyView] = []
    ) {
        self.iCloudIdentifier = iCloudIdentifier
        self.additionViews = additionViews
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
                    sheetSection()
                }
                Section("UI - 页面元素") {
                    ForEach(Page.elementSection()) { page in
                        NavigationLink(value: page) {
                            SimpleCell(page.title, systemImage: page.icon)
                        }
                    }
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
                case "banner": DemoSimplePop()
                case "alert": DemoSimpleAlert()
                case "locale": DemoSimpleLocale()
                case "ui": DemoSimpleUIElement(additionViews: additionViews)
                case "animation": DemoSimpleAnimation()
                case "sfsymbol": DemoSFSymbol()
                case "button": DemoSimpleButton()
                case "card": DemoSimpleCard()
                case "haptic": DemoSimpleHaptic()
                case "device": DemoSimpleDevice(selectedPage.title)
                case "holder": DemoSimplePlaceholder()
                case "cloud": DemoSimpleCloud(iCloudIdentifier: iCloudIdentifier)
                case "upload": DemoSimpleUpload()
                case "ftp": DemoSimpleWebLoad()
                case "web": DemoSimpleWeb()
                case "collection": DemoSimpleCollection(selectedPage.title)
                case "date": DemoSimpleDate()
                case "image":
                    #if !os(watchOS)
                    DemoSimpleImage()
                    #else
                    Text("Only for iOS")
                    #endif
                case "color": SimpleColorPicker(selectedColor: .random())
                case "unit": DemoSimpleUnit()
                case "code": DemoSimpleCode()
                case "nl": DemoSimpleLanguage()
                case "md": DemoSimpleText(markdown: String.testText(.markdown02))
                case "aes": DemoSimpleCrypto()
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
    
    @ViewBuilder
    private func sheetSection() -> some View {
        PlainButton {
            showPurchasePage = true
        } label: {
            SimpleCell("IAP - 内购页面", systemImage: "bag")
        }
        .sheet(isPresented: $showPurchasePage) {
            DemoSimplePurchase()
                .interactiveDismissDisabled(true)
        }
        
        PlainButton {
            showWelcomePage.toggle()
        } label: {
            SimpleCell(
                "Welcome - 欢迎页",
                systemImage: "list.bullet.below.rectangle"
            )
        }
        .sheet(isPresented: $showWelcomePage) {
            SimpleWelcome<EmptyView>(
                allIntroItems: .allExamples,
                appName: "AmosBase",
                continueType: .dismiss)
            .interactiveDismissDisabled(true)
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
    
    public let id: String
    let title: String
    let icon: String
    let isOn: Bool
    
    public init(
        id: String,
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
        [.init(id: "banner", title: "Banner - 提醒系统", icon: "rectangle.portrait.topthird.inset.filled"),
         .init(id: "alert", title: "Alert - 系统提醒", icon: "bell")
        ]
    }
    
    static func elementSection() -> [Self] {
        let commonElements: [Self] =
        [.init(id: "locale", title: " Locale - 本地化", icon: "character.zh"),
         .init(id: "ui", title: "UI - 页面元素", icon: "uiwindow.split.2x1"),
         .init(id: "animation", title: "Animation - 动画", icon: "play.circle"),
         .init(id: "sfsymbol", title: "SF Symbols", icon: "heart.text.clipboard"),
         .init(id: "button", title: "Button - 按钮", icon: "rectangle.inset.topleft.filled"),
         .init(id: "card", title: "Card - 卡片", icon: "rectangle.portrait.on.rectangle.portrait.angled"),
         .init(id: "device", title: "Device - 设备信息", icon: "iphone.gen3"),
         .init(id: "haptic", title: "Haptic - 震动", icon: "iphone.homebutton.radiowaves.left.and.right"),
         .init(id: "holder", title: "Holder - 占位符", icon: "doc.text.image")
         ]
        
        return commonElements
    }
    
    static func webSection() -> [Self] {
        [.init(id: "cloud", title: "iCloud - 云存储", icon: "arrow.clockwise.icloud"),
         .init(id: "upload", title: "Upload - 图床", icon: "photo.badge.arrow.down"),
         .init(id: "ftp", title: "FTP - 网络传输", icon: "arrow.left.arrow.right.square"),
         .init(id: "web", title: "Web - 网页浏览", icon: "safari")]
    }
    
    static func dataSection() -> [Self] {
        [.init(id: "collection", title: "Collection - 集合", icon: "rectangle.grid.3x2"),
         .init(id: "date", title: "Date - 日期", icon: "calendar.badge.clock"),
         .init(id: "image", title: "Image - 图片", icon: "photo"),
         .init(id: "color", title: "Color - 颜色", icon: "paintpalette"),
         .init(id: "unit", title: "Units - 单位", icon: "gauge.with.dots.needle.33percent"),
         .init(id: "code", title: "Data - 编解码", icon: "externaldrive"),
         .init(id: "nl", title: "NL - 自然语言", icon: "character.book.closed"),
         .init(id: "md", title: "Text - MD可选文字", icon: "richtext.page"),
         .init(id: "aes", title: "AES - 加解密", icon: "lock.shield")
        ]
    }
}

#Preview {
    DemoContent()
    #if os(macOS)
    .frame(minWidth: 700, minHeight: 800)
    #endif
}
