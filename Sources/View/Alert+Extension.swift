//
//  File.swift
//  
//
//  Created by AmosFitness on 2023/11/10.
//

import SwiftUI

public enum SimpleAlertType: String, CaseIterable {
    case singleCancel, singleConfirm, confirmCancel, destructiveCancel
}

public extension View {
    /// 简单UI组件 -  Alert提醒，有四种形式，默认确认键取消
    ///
    /// 可自定义Title和Message，singleCancel, singleConfirm, ConfirmCancel, DestructiveCancel
    func simpleAlert(type: SimpleAlertType = .singleConfirm,
                            title: String?,
                            message: String? = nil,
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
    func simpleConfirmation(type: SimpleAlertType = .singleConfirm,
                                   title: String?,
                                   message: String? = nil,
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
    let title: String
    let message: String?
    let type: SimpleAlertType
    @Binding var isPresented: Bool
    
    let confirmTap: () -> Void
    let cancelTap: () -> Void
    
    init(title: String?,
         message: String?,
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
            .confirmationDialog(title.localized(),
                                isPresented: $isPresented,
                                titleVisibility: .visible) {
                switch type {
                case .singleCancel:
                    Button("Cancel".localized(bundle: .module), role: .cancel, action: cancelTap)
#if !os(watchOS)
    .keyboardShortcut(.escape)
#endif
                case .singleConfirm:
                    Button("Confirm".localized(bundle: .module), role: .cancel) {
                        cancelTap()
                        confirmTap()
                    }
#if !os(watchOS)
    .keyboardShortcut(.return)
#endif
                case .confirmCancel:
                    Button("Confirm".localized(bundle: .module), role: .none, action: confirmTap)
#if !os(watchOS)
    .keyboardShortcut(.return)
#endif
                    Button("Cancel".localized(bundle: .module), role: .cancel, action: cancelTap)
#if !os(watchOS)
    .keyboardShortcut(.escape)
#endif
                case .destructiveCancel:
                    Button("Confirm".localized(bundle: .module), role: .destructive, action: confirmTap)
#if !os(watchOS)
    .keyboardShortcut(.return)
#endif
                    Button("Cancel".localized(bundle: .module), role: .cancel, action: cancelTap)
#if !os(watchOS)
    .keyboardShortcut(.escape)
#endif
                }
            } message: {
                if let message {
                    Text(message.localized())
                }
            }
    }
}

// MARK: - Alert
struct SimpleAlert: ViewModifier {
    let title: String
    let message: String?
    let type: SimpleAlertType
    @Binding var isPresented: Bool
    
    let confirmTap: () -> Void
    let cancelTap: () -> Void
    
    init(title: String?,
         message: String?,
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
            .alert(title.localized(),
                   isPresented: $isPresented) {
                switch type {
                case .singleCancel:
                    Button("Cancel".localized(bundle: .module), role: .cancel, action: cancelTap)
                    #if !os(watchOS)
                        .keyboardShortcut(.escape)
                    #endif
                case .singleConfirm:
                    Button("Confirm".localized(bundle: .module), role: .cancel) {
                        cancelTap()
                        confirmTap()
                    }
#if !os(watchOS)
    .keyboardShortcut(.return)
#endif
                case .confirmCancel:
                    Button("Confirm".localized(bundle: .module), role: .none, action: confirmTap)
#if !os(watchOS)
    .keyboardShortcut(.return)
#endif
                    Button("Cancel".localized(bundle: .module), role: .cancel, action: cancelTap)
#if !os(watchOS)
    .keyboardShortcut(.escape)
#endif
                case .destructiveCancel:
                    Button("Confirm".localized(bundle: .module), role: .destructive, action: confirmTap)
#if !os(watchOS)
    .keyboardShortcut(.return)
#endif
                    Button("Cancel".localized(bundle: .module), role: .cancel, action: cancelTap)
#if !os(watchOS)
    .keyboardShortcut(.escape)
#endif
                }
            } message: {
                if let message {
                    Text(message.localized())
                }
            }
    }
}

