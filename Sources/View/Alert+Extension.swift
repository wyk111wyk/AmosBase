//
//  File.swift
//  
//
//  Created by AmosFitness on 2023/11/10.
//

import SwiftUI
import OSLog

private let mylog = Logger(subsystem: "Alert+Extension", category: "AmosBase")
struct AlertTestView: View {
    
    @State private var selectedAlert: SimpleAlertType? = nil
    @State private var selectedConfirmation: SimpleAlertType? = nil
    
    @State private var selectedToast: ToastType? = nil
    @State private var simpleError: Bool? = false
    @State private var simpleLoading: Bool? = false
    @State private var simpleSuccess: Bool? = false
    
    @State private var toastTitle: String? = nil
    
    init() {}
    
    var body: some View {
        NavigationView {
            Form {
                Section("转换 Toast") {
                    Button("Loading -> Success") {
                        selectedToast = .topLoading
                        SimpleTimer().after(timeInterval: 2) {
                            selectedToast = .centerSuccess
                        }
                    }
                    Button("Loading -> Error") {
                        selectedToast = .topLoading
                        SimpleTimer().after(timeInterval: 2) {
                            selectedToast = .topError
                        }
                    }
                    Button("Loading Title Change") {
                        loadingTest()
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
                
                Section("Alert") {
                    ForEach(SimpleAlertType.allCases, id: \.self.rawValue) { alert in
                        Button("Alert - \(alert.rawValue)") {
                            selectedAlert = alert
                        }
                    }
                    .simpleAlert(type: selectedAlert ?? .singleConfirm,
                                 title: LocalizedStringKey(selectedAlert?.rawValue ?? "N/A"),
                                 message: nil,
                                 isPresented: .isPresented($selectedAlert)) {
                        print("Confirm Tap")
                    } cancelTap: {
                        print("Cancel Tap")
                    }
                }
                
                Section("Confirmation") {
                    ForEach(SimpleAlertType.allCases, id: \.self.rawValue) { alert in
                        Button("Confirmation - \(alert.rawValue)") {
                            selectedConfirmation = alert
                        }
                    }
                    .simpleConfirmation(type: selectedConfirmation ?? .singleConfirm,
                                        title: LocalizedStringKey(selectedConfirmation?.rawValue ?? "N/A"),
                                        message: nil,
                                        isPresented: .isPresented($selectedConfirmation)) {
                        print("Confirm Tap")
                    } cancelTap: {
                        print("Cancel Tap")
                    }
                }
            }
            .refreshable {
                loadingTest()
            }
        }
        #if canImport(UIKit)
        .navigationViewStyle(.stack)
        #endif
        .simpleErrorToast(presentState: $simpleError, title: "发生了一个错误", subtitle: "请仔细检查网络连接")
        .simpleSuccessToast(presentState: $simpleSuccess, title: "保存数据成功")
        .simpleLoadingToast(presentState: $simpleLoading, title: "正在载入...")
        .simpleToast(presentState: $selectedToast) {
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

public enum SimpleAlertType: String, CaseIterable {
    case singleCancel, singleConfirm, confirmCancel, destructiveCancel
}

extension View {
    /// 简单UI组件 -  Alert提醒，有四种形式，默认确认键取消
    ///
    /// 可自定义Title和Message，singleCancel, singleConfirm, ConfirmCancel, DestructiveCancel
    public func simpleAlert(type: SimpleAlertType = .singleConfirm,
                            title: LocalizedStringKey?,
                            message: LocalizedStringKey? = nil,
                            isPresented: Binding<Bool>,
                            confirmTap: @escaping () -> Void = {},
                            cancelTap: @escaping () -> Void = {}) -> some View {
        modifier(SimpleAlert(title: title,
                             message: message,
                             type: type,
                             isPresented: isPresented,
                             confirmTap: confirmTap,
                             cancelTap: cancelTap))
    }
    
    /// 简单UI组件 -  Confirmation提醒，有四种形式，默认确认键取消
    ///
    /// 可自定义Title和Message，singleCancel, singleConfirm, ConfirmCancel, DestructiveCancel
    public func simpleConfirmation(type: SimpleAlertType = .singleConfirm,
                                   title: LocalizedStringKey?,
                                   message: LocalizedStringKey? = nil,
                                   isPresented: Binding<Bool>,
                                   confirmTap: @escaping () -> Void = {},
                                   cancelTap: @escaping () -> Void = {}) -> some View {
        modifier(SimpleConfirmation(title: title,
                                    message: message,
                                    type: type,
                                    isPresented: isPresented,
                                    confirmTap: confirmTap,
                                    cancelTap: cancelTap))
    }
}

// MARK: - Confirmation
struct SimpleConfirmation: ViewModifier {
    let title: LocalizedStringKey
    let message: LocalizedStringKey?
    let type: SimpleAlertType
    @Binding var isPresented: Bool
    
    let confirmTap: () -> Void
    let cancelTap: () -> Void
    
    init(title: LocalizedStringKey?,
         message: LocalizedStringKey?,
         type: SimpleAlertType,
         isPresented: Binding<Bool>,
         confirmTap: @escaping () -> Void,
         cancelTap: @escaping () -> Void) {
        self.title = title ?? "N/A"
        self.message = message
        self.type = type
        self._isPresented = isPresented
        self.confirmTap = confirmTap
        self.cancelTap = cancelTap
    }
    
    func body(content: Content) -> some View {
        content
            .confirmationDialog(title,
                                isPresented: $isPresented,
                                titleVisibility: .visible) {
                switch type {
                case .singleCancel:
                    Button("Cancel", role: .cancel, action: cancelTap)
                case .singleConfirm:
                    Button("Confirm", role: .cancel) {
                        cancelTap()
                        confirmTap()
                    }
                case .confirmCancel:
                    Button("Confirm", role: .none, action: confirmTap)
                    Button("Cancel", role: .cancel, action: cancelTap)
                case .destructiveCancel:
                    Button("Confirm", role: .destructive, action: confirmTap)
                    Button("Cancel", role: .cancel, action: cancelTap)
                }
            } message: {
                if let message {
                    Text(message)
                }
            }
    }
}

// MARK: - Alert
struct SimpleAlert: ViewModifier {
    let title: LocalizedStringKey
    let message: LocalizedStringKey?
    let type: SimpleAlertType
    @Binding var isPresented: Bool
    
    let confirmTap: () -> Void
    let cancelTap: () -> Void
    
    init(title: LocalizedStringKey?,
         message: LocalizedStringKey?,
         type: SimpleAlertType,
         isPresented: Binding<Bool>,
         confirmTap: @escaping () -> Void,
         cancelTap: @escaping () -> Void) {
        self.title = title ?? "N/A"
        self.message = message
        self.type = type
        self._isPresented = isPresented
        self.confirmTap = confirmTap
        self.cancelTap = cancelTap
    }
    
    func body(content: Content) -> some View {
        content
            .alert(title,
                   isPresented: $isPresented) {
                switch type {
                case .singleCancel:
                    Button("Cancel", role: .cancel, action: cancelTap)
                case .singleConfirm:
                    Button("Confirm", role: .cancel) {
                        cancelTap()
                        confirmTap()
                    }
                case .confirmCancel:
                    Button("Confirm", role: .none, action: confirmTap)
                    Button("Cancel", role: .cancel, action: cancelTap)
                case .destructiveCancel:
                    Button("Confirm", role: .destructive, action: confirmTap)
                    Button("Cancel", role: .cancel, action: cancelTap)
                }
            } message: {
                if let message {
                    Text(message)
                }
            }
    }
}

#Preview("Alert") {
    AlertTestView()
}
