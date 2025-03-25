//
//  SwiftUIView.swift
//
//
//  Created by AmosFitness on 2023/12/7.
//

import SwiftUI

public struct DemoSimpleToast: View {
    
    @State private var selectedToast: ToastType? = nil
    @State private var simpleError: Bool? = false
    @State private var simpleLoading: Bool? = false
    @State private var simpleSuccess: Bool? = false
    
    @State private var toastTitle: String? = nil
    
    let title: String
    public init(_ title: String = "Toast 提示") {
        self.title = title
    }
    
    public var body: some View {
        Form {
            Section("转换 Toast") {
                Button {
                    selectedToast = .topLoading
                    SimpleTimer().after(timeInterval: 2) {
                        selectedToast = .centerSuccess
                    }
                } label: {
                    SimpleCell("Loading -> Success", localizationBundle: .module)
                }
                .buttonStyle(.borderless)
                Button {
                    selectedToast = .topLoading
                    SimpleTimer().after(timeInterval: 2) {
                        selectedToast = .topError
                    }
                } label: {
                    SimpleCell("Loading -> Error", localizationBundle: .module)
                }
                .buttonStyle(.borderless)
                Button {
                    loadingTest()
                } label: {
                    SimpleCell("Loading Title Change", localizationBundle: .module)
                }
                .buttonStyle(.borderless)
            }
            
            Section("Simple Toast".localized(bundle: .module)) {
                Button {
                    simpleError = true
                } label: {
                    SimpleCell("Simple Error", localizationBundle: .module)
                }
                .buttonStyle(.borderless)
                Button {
                    if simpleLoading == true {
                        simpleLoading = nil
                    }else {
                        simpleLoading = true
                    }
                } label: {
                    SimpleCell("Simple Loading", localizationBundle: .module)
                }
                .buttonStyle(.borderless)
                Button {
                    simpleSuccess = true
                } label: {
                    SimpleCell("Simple Success", localizationBundle: .module)
                }
                .buttonStyle(.borderless)
            }
            
            Section("Top Toasts".localized(bundle: .module)) {
                ForEach(ToastType.topToasts(), id: \.self.rawValue) { tosat in
                    Button {
                        selectedToast = tosat
                    } label: {
                        SimpleCell(tosat.rawValue, localizationBundle: .module)
                    }
                    .buttonStyle(.borderless)
                }
            }
            Section("Center Toasts".localized(bundle: .module)) {
                ForEach(ToastType.centerToasts(), id: \.self.rawValue) { tosat in
                    Button {
                        selectedToast = tosat
                    } label: {
                        SimpleCell(tosat.rawValue, localizationBundle: .module)
                    }
                    .buttonStyle(.borderless)
                }
            }
            Section("Bottom Toasts".localized(bundle: .module)) {
                ForEach(ToastType.bottomToasts(), id: \.self.rawValue) { tosat in
                    Button {
                        selectedToast = tosat
                    } label: {
                        SimpleCell(tosat.rawValue, localizationBundle: .module)
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(title)
        .refreshable {
            loadingTest()
        }
        .simpleErrorToast(presentState: $simpleError, title: "发生了一个错误", subtitle: "请仔细检查网络连接")
        .simpleSuccessToast(presentState: $simpleSuccess, title: "保存数据成功", isDebug: true)
        .simpleLoadingToast(presentState: $simpleLoading, title: "正在载入...", isDebug: true)
        .simpleToast(presentState: $selectedToast, isDebug: true) {
            selectedToast?.toast(variableTitle: $toastTitle)
        }
    }
    
    func loadingTest() {
        selectedToast = .topLoading
        
        SimpleTimer().after(timeInterval: 2) {
            toastTitle = "第一次改变文字"
            SimpleTimer().after(timeInterval: 2) {
                toastTitle = "第二次改变文字"
                SimpleTimer().after(timeInterval: 2) {
                    toastTitle = nil
                    selectedToast = .centerSuccess
                }
            }
        }
    }
    
    enum ToastType: String, CaseIterable {
        case topSuccess, topError, topSystemImage, topImage, topLoading, topRegular
        case centerSuccess, centerError, centerSystemImage, centerImage, centerLoading, centerRegular
        case bottomSuccess, bottomError, bottomSystemImage, bottomImage, bottomLoading, bottomRegular
        
        var para: (mode: ToastView.DisplayMode,
                   type: ToastView.AlertType) {
            switch self {
            case .topSuccess:
                (.topToast, .success())
            case .topError:
                (.topToast, .error())
            case .topSystemImage:
                (.topToast, .systemImage("trash", .blue))
            case .topImage:
                (.topToast, .image("LAL_r"))
            case .topLoading:
                (.topToast, .loading)
            case .topRegular:
                (.topToast, .regular)
            case .centerSuccess:
                (.centerToast, .success())
            case .centerError:
                (.centerToast, .error())
            case .centerSystemImage:
                (.centerToast, .systemImage("trash", .brown))
            case .centerImage:
                (.centerToast, .image("LAL_r"))
            case .centerLoading:
                (.centerToast, .loading)
            case .centerRegular:
                (.centerToast, .regular)
            case .bottomSuccess:
                (.bottomToast, .success())
            case .bottomError:
                (.bottomToast, .error())
            case .bottomSystemImage:
                (.bottomToast, .systemImage("trash"))
            case .bottomImage:
                (.bottomToast, .image("LAL_r"))
            case .bottomLoading:
                (.bottomToast, .loading)
            case .bottomRegular:
                (.bottomToast, .regular)
            }
        }
        
        func toast(variableTitle: Binding<String?> = .constant(nil)) -> ToastView {
            ToastView(displayMode: para.mode,
                      type: para.type,
                      title: rawValue,
                      variableTitle: variableTitle,
                      subTitle: "I am content but not very long I am content but not very long I am content but not very long")
        }
        
        static func topToasts() -> [Self] {
            [.topSuccess, .topError, .topSystemImage, .topImage, .topLoading, .topRegular]
        }
        
        static func centerToasts() -> [Self] {
            [.centerSuccess, .centerError, .centerSystemImage, .centerImage, .centerLoading, .centerRegular]
        }
        
        static func bottomToasts() -> [Self] {
            [.bottomSuccess, .bottomError, .bottomSystemImage, .bottomImage, .bottomLoading, .bottomRegular]
        }
    }
}

#Preview {
    NavigationStack {
        DemoSimpleToast()
    }
    .environment(\.locale, .zhHans)
}
