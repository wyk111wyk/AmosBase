//
//  ToastView.swift
//  AmosFundation
//
//  Created by AmosFitness on 2023/11/13.
//

import SwiftUI
import AmosBase
import Combine

struct ToastTestView: View {
    @State private var selectedToast: ToastType? = nil
    @State private var simpleError: Bool? = false
    @State private var simpleLoading: Bool? = false
    @State private var simpleSuccess: Bool? = false
    
    @State private var canceller: AnyCancellable?
    
    let title: String
    init(_ title: String = "Toast") {
        self.title = title
    }
    
    var body: some View {
        Form {
            Section("转换 Toast") {
                Button("Loading -> Success") {
                    selectedToast = .topLoading
                    SimpleTimer.after(timeInterval: 2) {
                        selectedToast = .topSuccess
                    }
                }
                Button("Loading -> Error") {
                    selectedToast = .topLoading
                    SimpleTimer.after(timeInterval: 2) {
                        selectedToast = .topError
                    }
                }
            }
            
            Section("Simple Toast") {
                Button("Simple Error") {
                    simpleError = true
                }
                Button("Simple Loading") {
                    simpleLoading = true
                }
                Button("Simple Success") {
                    simpleSuccess = true
                }
            }
            
            Section("Top Toasts") {
                ForEach(ToastType.topToasts(), id: \.self.rawValue) { tosat in
                    Button(tosat.rawValue) {
                        selectedToast = tosat
                    }
                }
            }
            Section("Center Toasts") {
                ForEach(ToastType.centerToasts(), id: \.self.rawValue) { tosat in
                    Button(tosat.rawValue) {
                        selectedToast = tosat
                    }
                }
            }
            Section("Bottom Toasts") {
                ForEach(ToastType.bottomToasts(), id: \.self.rawValue) { tosat in
                    Button(tosat.rawValue) {
                        selectedToast = tosat
                    }
                }
            }
        }
        .navigationTitle(title)
        .simpleToast(presentState: $selectedToast) {
            selectedToast?.toast()
        }
        .simpleErrorToast(presentState: $simpleError, title: "发生了一个错误", subtitle: "请仔细检查网络连接")
        .simpleSuccessToast(presentState: $simpleSuccess, title: "保存数据成功")
        .simpleLoadingToast(presentState: $simpleLoading, title: "正在载入...")
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
        
        func toast() -> ToastView {
            ToastView(displayMode: para.mode,
                          type: para.type,
                          title: rawValue,
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
        ToastTestView()
    }
}
