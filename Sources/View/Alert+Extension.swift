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
    func simpleAlert(
        type: SimpleAlertType = .singleConfirm,
        title: String?,
        message: LocalizedStringKey? = nil,
        isPresented: Binding<Bool>,
        confirmTap: @escaping () -> Void = {},
        cancelTap: @escaping () -> Void = {}
    ) -> some View {
        modifier(
            SimpleAlert(
                title: title,
                message: message,
                type: type,
                isPresented: isPresented,
                confirmTap: confirmTap,
                cancelTap: cancelTap
            )
        )
    }
    
    func simpleAlert<V: Identifiable>(
        type: SimpleAlertType = .singleConfirm,
        title: String?,
        message: LocalizedStringKey? = nil,
        item: Binding<V?>,
        confirmTap: @escaping (V?) -> Void = {_ in},
        cancelTap: @escaping () -> Void = {}
    ) -> some View {
        modifier(
            SimpleAlertItem(
                title: title,
                message: message,
                type: type,
                item: item,
                confirmTap: confirmTap,
                cancelTap: cancelTap
            )
        )
    }
    
    /// 简单UI组件 -  Alert错误提醒
    func simpleErrorAlert(
        error: Binding<Error?>,
        confirmTap: @escaping () -> Void = {}
    ) -> some View {
        if let simpleError = error.wrappedValue as? SimpleError,
            case let .customError(title, msg) = simpleError {
            return modifier(
                SimpleAlert(
                    title: title,
                    message: msg.toLocalizedKey(),
                    type: .singleConfirm,
                    isPresented: .isPresented(error),
                    confirmTap: confirmTap,
                    cancelTap: {}
                )
            )
        }else {
            return modifier(
                SimpleAlert(
                    title: error.wrappedValue.debugDescription,
                    message: nil,
                    type: .singleConfirm,
                    isPresented: .isPresented(error),
                    confirmTap: confirmTap,
                    cancelTap: {}
                )
            )
        }
    }
        
    
    /// 简单UI组件 -  Confirmation提醒，有四种形式，默认确认键取消
    ///
    /// 可自定义Title和Message，singleCancel, singleConfirm, ConfirmCancel, DestructiveCancel
    func simpleConfirmation(
        type: SimpleAlertType = .singleConfirm,
        title: String?,
        message: LocalizedStringKey? = nil,
        isPresented: Binding<Bool>,
        confirmTap: @escaping () -> Void = {},
        cancelTap: @escaping () -> Void = {}
    ) -> some View {
        modifier(
            SimpleConfirmation(
                title: title,
                message: message,
                type: type,
                isPresented: isPresented,
                confirmTap: confirmTap,
                cancelTap: cancelTap
            )
        )
    }
}

// MARK: - Confirmation
struct SimpleConfirmation: ViewModifier {
    let title: String
    let message: LocalizedStringKey?
    let type: SimpleAlertType
    let messageBundle: Bundle
    @Binding var isPresented: Bool
    
    let confirmTap: () -> Void
    let cancelTap: () -> Void
    
    init(title: String?,
         message: LocalizedStringKey?,
         type: SimpleAlertType,
         messageBundle: Bundle = .main,
         isPresented: Binding<Bool>,
         confirmTap: @escaping () -> Void,
         cancelTap: @escaping () -> Void) {
        self.title = title ?? "N/A"
        self.message = message
        self.type = type
        self.messageBundle = messageBundle
        self._isPresented = isPresented
        self.confirmTap = confirmTap
        self.cancelTap = cancelTap
    }
    
    func body(content: Content) -> some View {
        content
            .confirmationDialog(
                title.localized(
                    bundle: messageBundle
                ),
                isPresented: $isPresented,
                titleVisibility: .visible
            ) {
                switch type {
                case .singleCancel:
                    Button(role: .cancel, action: cancelTap, label: {
                        Text("Cancel", bundle: .module)
                    })
#if !os(watchOS)
    .keyboardShortcut(.escape)
#endif
                case .singleConfirm:
                    Button(role: .cancel, action: {
                        cancelTap()
                        confirmTap()
                    }, label: {
                        Text("Confirm", bundle: .module)
                    })
#if !os(watchOS)
    .keyboardShortcut(.return)
#endif
                case .confirmCancel:
                    Button(role: .none, action: confirmTap, label: {
                        Text("Confirm", bundle: .module)
                    })
#if !os(watchOS)
    .keyboardShortcut(.return)
#endif
                    Button(role: .cancel, action: cancelTap, label: {
                        Text("Cancel", bundle: .module)
                    })
#if !os(watchOS)
    .keyboardShortcut(.escape)
#endif
                case .destructiveCancel:
                    Button(role: .destructive, action: confirmTap, label: {
                        Text("Confirm", bundle: .module)
                    })
#if !os(watchOS)
    .keyboardShortcut(.return)
#endif
                    Button(role: .cancel, action: cancelTap, label: {
                        Text("Cancel", bundle: .module)
                    })
#if !os(watchOS)
    .keyboardShortcut(.escape)
#endif
                }
            } message: {
                if let message {
                    Text(message, bundle: messageBundle)
                }
            }
    }
}

// MARK: - Alert
struct SimpleAlert: ViewModifier {
    let title: String
    let message: LocalizedStringKey?
    let type: SimpleAlertType
    let messageBundle: Bundle
    @Binding var isPresented: Bool
    
    let confirmTap: () -> Void
    let cancelTap: () -> Void
    
    init(title: String?,
         message: LocalizedStringKey?,
         type: SimpleAlertType,
         messageBundle: Bundle = .main,
         isPresented: Binding<Bool>,
         confirmTap: @escaping () -> Void,
         cancelTap: @escaping () -> Void) {
        self.title = title ?? "N/A"
        self.message = message
        self.type = type
        self.messageBundle = messageBundle
        self._isPresented = isPresented
        self.confirmTap = confirmTap
        self.cancelTap = cancelTap
    }
    
    func body(content: Content) -> some View {
        content
            .alert(title.localized(bundle: messageBundle),
                   isPresented: $isPresented) {
                switch type {
                case .singleCancel:
                    Button(role: .cancel, action: cancelTap, label: {
                        Text("Cancel", bundle: .module)
                    })
                    #if !os(watchOS)
                        .keyboardShortcut(.escape)
                    #endif
                case .singleConfirm:
                    Button(role: .cancel, action: {
                        cancelTap()
                        confirmTap()
                    }, label: {
                        Text("Confirm", bundle: .module)
                    })
                    #if !os(watchOS)
                        .keyboardShortcut(.return)
                    #endif
                case .confirmCancel:
                    Button(role: .none, action: confirmTap, label: {
                        Text("Confirm", bundle: .module)
                    })
                    #if !os(watchOS)
                        .keyboardShortcut(.return)
                    #endif
                    Button(role: .cancel, action: cancelTap, label: {
                        Text("Cancel", bundle: .module)
                    })
                    #if !os(watchOS)
                        .keyboardShortcut(.escape)
                    #endif
                case .destructiveCancel:
                    Button(role: .destructive, action: confirmTap, label: {
                        Text("Confirm", bundle: .module)
                    })
                    #if !os(watchOS)
                    .keyboardShortcut(.return)
                    #endif
                    Button(role: .cancel, action: cancelTap, label: {
                        Text("Cancel", bundle: .module)
                    })
                    #if !os(watchOS)
                    .keyboardShortcut(.escape)
                    #endif
                }
            } message: {
                if let message {
                    Text(message, bundle: messageBundle)
                }
            }
    }
}

struct SimpleAlertItem<V: Identifiable>: ViewModifier {
    let title: String
    let message: LocalizedStringKey?
    let type: SimpleAlertType
    let messageBundle: Bundle
    @Binding var item: V?
    let passItem: V?
    
    let confirmTap: (V?) -> Void
    let cancelTap: () -> Void
    
    init(title: String?,
         message: LocalizedStringKey?,
         type: SimpleAlertType,
         messageBundle: Bundle = .main,
         item: Binding<V?>,
         confirmTap: @escaping (V?) -> Void,
         cancelTap: @escaping () -> Void) {
        self.title = title ?? "N/A"
        self.message = message
        self.type = type
        self.messageBundle = messageBundle
        self._item = item
        self.passItem = item.wrappedValue
        self.confirmTap = confirmTap
        self.cancelTap = cancelTap
    }
    
    func body(content: Content) -> some View {
        content
            .alert(title.localized(bundle: messageBundle),
                   isPresented: .isPresented($item)) {
                switch type {
                case .singleCancel:
                    Button(role: .cancel, action: cancelTap, label: {
                        Text("Cancel", bundle: .module)
                    })
                    #if !os(watchOS)
                        .keyboardShortcut(.escape)
                    #endif
                case .singleConfirm:
                    Button(role: .cancel, action: {
                        cancelTap()
                    }, label: {
                        Text("Confirm", bundle: .module)
                    })
                    #if !os(watchOS)
                        .keyboardShortcut(.return)
                    #endif
                case .confirmCancel:
                    Button(role: .none, action: {
                        confirmTap(passItem)
                    }, label: {
                        Text("Confirm", bundle: .module)
                    })
                    #if !os(watchOS)
                        .keyboardShortcut(.return)
                    #endif
                    Button(role: .cancel, action: cancelTap, label: {
                        Text("Cancel", bundle: .module)
                    })
                    #if !os(watchOS)
                        .keyboardShortcut(.escape)
                    #endif
                case .destructiveCancel:
                    Button(role: .destructive, action: {
                        confirmTap(passItem)
                    }, label: {
                        Text("Confirm", bundle: .module)
                    })
                    #if !os(watchOS)
                    .keyboardShortcut(.return)
                    #endif
                    Button(role: .cancel, action: cancelTap, label: {
                        Text("Cancel", bundle: .module)
                    })
                    #if !os(watchOS)
                    .keyboardShortcut(.escape)
                    #endif
                }
            } message: {
                if let message {
                    Text(message, bundle: messageBundle)
                }
            }
    }
}

#Preview(body: {
    DemoSimpleAlert()
})
