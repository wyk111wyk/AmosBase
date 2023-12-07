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
    func simpleConfirmation(type: SimpleAlertType = .singleConfirm,
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

