//
//  Constructors.swift
//  Pods
//
//  Created by Alisa Mylnikova on 11.10.2022.
//

import SwiftUI

public typealias SendableClosure = @Sendable @MainActor () -> Void

struct PopupDismissKey: EnvironmentKey {
    static let defaultValue: SendableClosure? = nil
}

public extension EnvironmentValues {
    var popupDismiss: SendableClosure? {
        get { self[PopupDismissKey.self] }
        set { self[PopupDismissKey.self] = newValue }
    }
}

// MARK: - 基础应用方法
@MainActor
extension View {
    public func popup<PopupContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder view: @escaping () -> PopupContent,
        customize: @escaping (Popup<PopupContent>.PopupParameters) -> Popup<PopupContent>.PopupParameters
        ) -> some View {
            self.modifier(
                FullscreenPopup<Int, PopupContent>(
                    isPresented: isPresented,
                    isBoolMode: true,
                    params: customize(Popup<PopupContent>.PopupParameters()),
                    view: view,
                    itemView: nil)
            )
            .environment(\.popupDismiss) {
                isPresented.wrappedValue = false
            }
        }

    public func popup<Item: Equatable, PopupContent: View>(
        item: Binding<Item?>,
        @ViewBuilder itemView: @escaping (Item) -> PopupContent,
        customize: @escaping (Popup<PopupContent>.PopupParameters) -> Popup<PopupContent>.PopupParameters
        ) -> some View {
            self.modifier(
                FullscreenPopup<Item, PopupContent>(
                    item: item,
                    isBoolMode: false,
                    params: customize(Popup<PopupContent>.PopupParameters()),
                    view: nil,
                    itemView: itemView)
            )
            .environment(\.popupDismiss) {
                item.wrappedValue = nil
            }
        }

    public func popup<PopupContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder view: @escaping () -> PopupContent) -> some View {
            self.modifier(
                FullscreenPopup<Int, PopupContent>(
                    isPresented: isPresented,
                    isBoolMode: true,
                    params: Popup<PopupContent>.PopupParameters(),
                    view: view,
                    itemView: nil)
            )
            .environment(\.popupDismiss) {
                isPresented.wrappedValue = false
            }
        }

    public func popup<Item: Equatable, PopupContent: View>(
        item: Binding<Item?>,
        @ViewBuilder itemView: @escaping (Item) -> PopupContent) -> some View {
            self.modifier(
                FullscreenPopup<Item, PopupContent>(
                    item: item,
                    isBoolMode: false,
                    params: Popup<PopupContent>.PopupParameters(),
                    view: nil,
                    itemView: itemView)
            )
            .environment(\.popupDismiss) {
                item.wrappedValue = nil
            }
        }
}
