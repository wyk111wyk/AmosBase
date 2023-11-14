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
    @State private var simpleError = false
    @State private var simpleLoading = false
    @State private var simpleSuccess = false
    
    init() {}
    
    var body: some View {
        NavigationView {
            Form {
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
                
                Section("Toast") {
                    ForEach(ToastType.allCases, id: \.self.rawValue) { tosat in
                        Button("Toast - \(tosat.rawValue)") {
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
                    .simpleAlert(type: selectedAlert,
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
                    .simpleConfirmation(type: selectedConfirmation,
                                        title: LocalizedStringKey(selectedConfirmation?.rawValue ?? "N/A"),
                                        message: nil,
                                        isPresented: .isPresented($selectedConfirmation)) {
                        print("Confirm Tap")
                    } cancelTap: {
                        print("Cancel Tap")
                    }
                }
            }
        }
        .simpleToast(isPresenting: .isPresented($selectedToast)) {
            return selectedToast?.toast()
        }
        .simpleErrorToast(isPresenting: $simpleError, title: "发生了一个错误", subtitle: "请仔细检查网络连接")
        .simpleSuccessToast(isPresenting: $simpleSuccess, title: "保存数据成功")
        .simpleLoadingToast(isPresenting: $simpleLoading, title: "正在载入...")
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
    }
}

public enum SimpleAlertType: String, CaseIterable {
    case singleCancel, singleConfirm, confirmCancel, destructiveCancel
}

extension View {
    /// 简单UI组件 -  Alert提醒，有四种形式
    ///
    /// 可自定义Title和Message，singleCancel, singleConfirm, ConfirmCancel, DestructiveCancel
    public func simpleAlert(type: SimpleAlertType?,
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
    
    /// 简单UI组件 -  Confirmation提醒，有四种形式
    ///
    /// 可自定义Title和Message，singleCancel, singleConfirm, ConfirmCancel, DestructiveCancel
    public func simpleConfirmation(type: SimpleAlertType?,
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
         type: SimpleAlertType?,
         isPresented: Binding<Bool>,
         confirmTap: @escaping () -> Void,
         cancelTap: @escaping () -> Void) {
        self.title = title ?? "N/A"
        self.message = message
        self.type = type ?? .singleCancel
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
         type: SimpleAlertType?,
         isPresented: Binding<Bool>,
         confirmTap: @escaping () -> Void,
         cancelTap: @escaping () -> Void) {
        self.title = title ?? "N/A"
        self.message = message
        self.type = type ?? .singleCancel
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
