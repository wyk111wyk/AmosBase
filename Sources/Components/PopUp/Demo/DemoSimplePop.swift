//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/4/11.
//

import SwiftUI

struct DemoSimplePop: View {
    @State private var popState: PopDemoState? = nil
    @State private var showDemoSheet = false
    @State private var showConfigSheet: SimplePopupStyle?
    
    @State private var bannerConfig: PopDemoConfig = .init(autohideIn: 2)
    @State private var toastConfig: PopDemoConfig = .init(displayMode: .window, autohideIn: 2)
    @State private var hudConfig: PopDemoConfig = .init(displayMode: .window, position: .center, appearFrom: .centerScale, showBackground: true, closeOnTapOutside: true)
    
    @State private var showReplacePop1 = false
    @State private var showReplacePop2 = false
    @State private var showReplacePop3 = false
    @State private var replaceTitle: String = .randomChinese(short: true)
    @State private var replaceSubTitle: String = .randomChinese(long: true)
    
    @State private var showInputPop = false
    @State private var showInputSheet = false
    @State private var showInputMutliPop = false
    @State private var inputText: String = ""
    @State private var contentText: String = ""
    
    @State private var showSuccessPop = false
    @State private var showErrorPop: Error?
    @State private var showLoadingPop = false
    @State private var showNoInternetPop = false
    
    var body: some View {
        let showSheet = Binding<Bool>(
            get: { showDemoSheet || showConfigSheet != nil },
            set: {
                showDemoSheet = $0
                showConfigSheet = nil
            }
        )
        
        Form {
            sheetSection()
            popDemoList()
        }
        .formStyle(.grouped)
        .navigationTitle("Popup 弹窗")
        .toolbar(content: toolbarMenu)
        .sheet(isPresented: showSheet) {
            sheetView()
        }
        .simpleNoInternetBanner(isPresented: $showNoInternetPop)
        .simpleSuccessBanner(
            isPresented: $showSuccessPop,
            title: "成功进行操作！",
            isCenter: true
        )
        .simpleErrorBanner(error: $showErrorPop)
        .simpleLoadingBanner(
            isPresented: $showLoadingPop,
            closeOnTap: true
        )
        .simpleInputBanner(
            isPresented: $showInputPop,
            pageName: "演示输入",
            title: inputText,
            cornerRadius: 15
        ) { result in
            inputText = result.title
        }
        .simpleInputBanner(
            isPresented: $showInputMutliPop,
            pageName: "多行输入",
            title: inputText,
            content: contentText,
            isContentRequired: true,
            showContent: true,
            cornerRadius: 15
        ) { result in
            inputText = result.title
            contentText = result.content
        }
        .popup(isPresented: $showReplacePop1) {
            PopBanner(mode: .loading, title: replaceTitle)
        } customize: { content in
            content
                .type(.floater())
                .position(.top)
        }
        .popup(isPresented: $showReplacePop2) {
            PopBanner(mode: .error, title: replaceTitle, subTitle: replaceSubTitle)
        } customize: { content in
            content
                .type(.floater())
                .position(.top)
        }
        .popup(isPresented: $showReplacePop3) {
            PopHud(mode: .success, title: replaceTitle, subTitle: replaceSubTitle)
        } customize: { content in
            content
                .type(.default)
                .position(.center)
                .appearFrom(.centerScale)
                .autohideIn(1.5)
        }
        .popup(item: $popState) { state in
            switch state.style {
            case .banner:
                PopBanner(mode: state.type, title: state.title, subTitle: state.subTitle, bgColor: state.bgColor)
            case .toast:
                PopToast(mode: state.type, isTop: config(.toast).position.isTop, title: state.title, subTitle: state.subTitle, bgColor: state.bgColor)
            case .hud:
                PopHud(mode: state.type, title: state.title, subTitle: state.subTitle, bgColor: state.bgColor)
            }
        } customize: {
            var content = $0
            if let popState {
                content.type = popState.style.toPopType()
                content.update(config(popState.style), mode: popState.type)
            }
            return content
        }
    }
    
    private func sheetSection() -> some View {
        Section {
            PlainButton {
                showDemoSheet = true
            } label: {
                SimpleCell("Sheet 查看", systemImage: "rectangle.portrait.bottomhalf.inset.filled", isCellButton: true)
            }
        }
        .simpleInputSheet(
            isPresented: $showInputSheet,
            pageName: "演示输入(Sheet)",
            title: inputText
        ) { result in
            inputText = result.title
        }
    }
    
    func config(_ style: SimplePopupStyle?) -> PopDemoConfig {
        guard let style else { return bannerConfig }
        switch style {
        case .banner: return bannerConfig
        case .toast: return toastConfig
        case .hud: return hudConfig
        }
    }
    
    func toggleReplace() {
        if showReplacePop1 {
            showReplacePop1 = false
            showReplacePop2 = true
            showReplacePop3 = false
        }else if showReplacePop2 {
            showReplacePop1 = false
            showReplacePop2 = false
            showReplacePop3 = true
        }else if showReplacePop3 {
            showReplacePop1 = true
            showReplacePop2 = false
            showReplacePop3 = false
        }else {
            showReplacePop1 = true
        }
    }
    
    private func specialSection() -> some View {
        Section {
            PlainButton {
                toggleReplace()
            } label: {
                SimpleCell("提醒覆盖", systemImage: "inset.filled.tophalf.bottomleft.bottomright.rectangle", content: "在同一个 View 声明提醒，可以通过更换提醒进行覆盖")
            }
            PlainButton {
                showInputPop = true
            } label: {
                SimpleCell("输入弹窗", systemImage: "keyboard", isCellButton: true)
            }
            PlainButton {
                showInputSheet = true
            } label: {
                SimpleCell("输入弹窗（Sheet）", systemImage: "keyboard", isCellButton: true)
            }
            PlainButton {
                showInputMutliPop = true
            } label: {
                SimpleCell("多行输入弹窗", systemImage: "keyboard", isCellButton: true)
            }
            PlainButton {
                showSuccessPop = true
            } label: {
                SimpleCell("成功弹窗", systemImage: "checkmark.square", isCellButton: true)
            }
            PlainButton {
                showErrorPop = SimpleError.customError(title: "Error Title", msg: "Error Message")
            } label: {
                SimpleCell("失败弹窗", systemImage: "xmark.square", isCellButton: true)
            }
            PlainButton {
                showLoadingPop = true
            } label: {
                SimpleCell("等待弹窗", systemImage: "progress.indicator", isCellButton: true)
            }
            PlainButton {
                showNoInternetPop = true
            } label: {
                SimpleCell("没有网络", systemImage: "wifi.exclamationmark", isCellButton: true)
            }
        }
    }
    
    @ViewBuilder
    private func popDemoList() -> some View {
        specialSection()
        ForEach(SimplePopupStyle.allCases) { style in
            Section {
                ForEach(SimplePopupMode.allCases) { type in
                    PlainButton {
                        if popState == nil {
                            popState = PopDemoState(style: style, type: type)
                        }else {
                            popState = nil
                        }
                    } label: {
                        SimpleCell(
                            type.title,
                            systemImage: style.systemName,
                            isCellButton: true
                        )
                    }
                }
            } header: {
                HStack {
                    Text(style.title)
                    Spacer()
                    Button { showConfigSheet = style } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            } footer: {
                infoFooter(config(style))
            }
        }
    }
    
    @ViewBuilder
    private func sheetView() -> some View {
        if showDemoSheet {
            NavigationStack {
                Form {
                    popDemoList()
                }
                .formStyle(.grouped)
                .navigationTitle("Sheet Popup")
                .buttonCircleNavi(role: .cancel) {
                    showDemoSheet = false
                }
            }
        }else if let showConfigSheet {
            SimplePopSetting(
                popStyle: showConfigSheet,
                bannerConfig: $bannerConfig,
                toastConfig: $toastConfig,
                hudConfig: $hudConfig
            )
        }
    }
    
    private func infoFooter(_ config: PopDemoConfig) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("·技术方案: \(config.displayMode.title)")
            HStack(spacing: 15) {
                Text("·弹窗位置: \(config.position.title)")
                Text("·出现动画: \(config.appearFrom?.title ?? "默认")")
                Text("·消失动画: \(config.disappearTo?.title ?? "默认")")
            }
            HStack(spacing: 15) {
                Text("·自动消失: \(config.autohideIn == 0 ? "无效" : config.autohideIn.toString(digit: 1)+"秒")")
                Text("·拖拽关闭: \(config.dragToDismiss ? "开启" : "关闭")")
                Text("·点击关闭: \(config.closeOnTap ? "开启" : "关闭")")
            }
            HStack(spacing: 15) {
                Text("·显示模态背景: \(config.showBackground ? "开启" : "关闭")")
                Text("·外部点击关闭: \(config.closeOnTapOutside ? "开启" : "关闭")")
            }
            HStack(spacing: 15) {
                Text("·计算键盘高度: \(config.useKeyboardSafeArea ? "开启" : "关闭")")
                Text("·启用震动: \(config.hasHaptic ? "开启" : "关闭")")
            }
        }
    }
}

extension DemoSimplePop {
    @ToolbarContentBuilder
    private func toolbarMenu() -> some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                showConfigSheet = .banner
            } label: {
                Image(systemName: "slider.horizontal.2.square")
            }
        }
    }
}
    
#Preview {
    NavigationStack {
        DemoSimplePop()
    }
}
