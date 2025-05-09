//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/4/13.
//

import SwiftUI

struct SimplePopSetting: View {
    @Environment(\.dismiss) private var dismissPage
    @State private var popStyle: SimplePopupStyle = .banner
    @Binding var bannerConfig: PopDemoConfig
    @Binding var toastConfig: PopDemoConfig
    @Binding var hudConfig: PopDemoConfig
    var currentConfig: Binding<PopDemoConfig> {
        get {
            switch popStyle {
            case .banner: return _bannerConfig
            case .toast: return _toastConfig
            case .hud: return _hudConfig
            }
        }
        set {
            switch popStyle {
            case .banner: _bannerConfig = newValue
            case .toast: _toastConfig = newValue
            case .hud: _hudConfig = newValue
            }
        }
    }
    
    init(
        popStyle: SimplePopupStyle? = nil,
        bannerConfig: Binding<PopDemoConfig>,
        toastConfig: Binding<PopDemoConfig>,
        hudConfig: Binding<PopDemoConfig>
    ) {
        if let popStyle {
            self._popStyle = State(initialValue: popStyle)
        }
        _bannerConfig = bannerConfig
        _toastConfig = toastConfig
        _hudConfig = hudConfig
    }
    
    var body: some View {
        NavigationStack {
            Form {
                techSection()
                appearSection()
                dismissSection()
                otherSection()
            }
            .formStyle(.grouped)
            .navigationTitle(popStyle.title)
            #if !os(watchOS)
            .toolbar(content: toolbarMenu)
            #endif
            .buttonCircleNavi(role: .destructive) {
                dismissPage()
            }
        }
    }
    
    private func techSection() -> some View {
        Section {
            Picker(
                "技术方案",
                selection: currentConfig.displayMode
            ) {
                ForEach(AmosBase.popup.DisplayMode.allCases) {
                    Text($0.title).tag($0)
                }
            }
            .segmentStyle()
            Picker(
                "弹窗位置",
                selection: currentConfig.position
            ) {
                ForEach(AmosBase.popup.Position.allCases) {
                    Text($0.title).tag($0)
                }
            }
        }
    }
    
    private func appearSection() -> some View {
        Section {
            OptionalPicker(
                "出现动画",
                selection: currentConfig.appearFrom,
                options: AmosBase.popup.AppearAnimation.allCases,
                nilOptionText: "默认"
            ) {
                Text($0.title)
            }
            OptionalPicker(
                "消失动画",
                selection: currentConfig.disappearTo,
                options: AmosBase.popup.AppearAnimation.allCases,
                nilOptionText: "默认"
            ) {
                Text($0.title)
            }
        }
    }
    
    private func dismissSection() -> some View {
        Section {
            VStack {
                HStack {
                    Text("自动消失")
                    Spacer()
                    if currentConfig.autohideIn.wrappedValue == 0 {
                        Text("无效")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }else {
                        Text(currentConfig.autohideIn.wrappedValue.toString(digit: 1)+"秒")
                            .font(.callout)
                    }
                }
                Slider(
                    value: currentConfig.autohideIn,
                    in: 0...5,
                    step: 0.1
                ) {
                    Text("自动消失")
                }
            }
            Toggle("拖拽关闭", isOn: currentConfig.dragToDismiss)
            Toggle("点击关闭", isOn: currentConfig.closeOnTap)
            Toggle("显示模态背景", isOn: currentConfig.showBackground.animation())
            if currentConfig.showBackground.wrappedValue {
                Toggle("外部点击关闭", isOn: currentConfig.closeOnTapOutside)
            }
        }
    }
    
    private func otherSection() -> some View {
        Section {
            Toggle("启用震动（成功/失败）", isOn: currentConfig.hasHaptic)
        }
    }
}

#if !os(watchOS)
extension SimplePopSetting {
    @ToolbarContentBuilder
    private func toolbarMenu() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Picker("Popup Style", selection: $popStyle) {
                ForEach(SimplePopupStyle.allCases) { style in
                    Text(style.title).tag(style)
                }
            }
            .segmentStyle()
            .frame(width: 220)
        }
    }
}
#endif

#Preview("Setting") {
    @Previewable @State var bannerConfig: PopDemoConfig = .init()
    @Previewable @State var toastConfig: PopDemoConfig = .init()
    @Previewable @State var hudConfig: PopDemoConfig = .init()
    SimplePopSetting(
        bannerConfig: $bannerConfig,
        toastConfig: $toastConfig,
        hudConfig: $hudConfig
    )
}
