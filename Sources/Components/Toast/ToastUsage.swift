//
//  File.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/10/10.
//

import Foundation
import SwiftUI

public extension View{
    /// 简单UI组件 -  Toast
    ///
    /// 使用不同的 Toast 类别传递时可以迭代，并重置关闭时间；
    ///
    /// loading 不会自动关闭，但是迭代为其他类型后会重置时间并关闭。
    ///
    /// iOS 端使用了 fullScreenCover 技术路线，其他平台是 overlay，但还是需要尽量放置在最根部的视图组件处。
    @available(*, deprecated, renamed: "popup", message: "Toast 已弃用，使用 Popup 作为新的提醒方法")
    func simpleToast<Item: Equatable>(
        presentState: Binding<Item?>,
        duration: Double = 1.7,
        tapToDismiss: Bool = true,
        tapBackgroundToDismiss: Bool = false,
        offsetY: CGFloat = 0,
        transition: AnyTransition? = nil,
        withHaptic: Bool = true,
        isDebug: Bool = false,
        @ViewBuilder toast: @escaping () -> ToastView?,
        onTap: (() -> ())? = nil,
        backgroundTap: (() -> ())? = nil,
        completion: (() -> ())? = nil) -> some View {
            return modifier(ToastModifier(
                presentState: presentState,
                duration: duration,
                tapToDismiss: tapToDismiss,
                tapBackgroundToDismiss: tapBackgroundToDismiss,
                offsetY: offsetY,
                transition: transition,
                withHaptic: withHaptic,
                isDebug: isDebug,
                toast: toast,
                onTap: onTap,
                backgroundTap: backgroundTap,
                completion: completion))}
    
    /// 简单UI组件 - 顶部错误提示（使用 Error）
    @available(*, deprecated, renamed: "simpleErrorBanner(error:)", message: "Toast 已弃用，使用 Popup 作为新的提醒方法")
    func simpleErrorToast(
        error: Binding<Error?>,
        displayMode: ToastView.DisplayMode = .topToast,
        duration: Double = 2.0
    ) -> some View {
        if let simpleError = error.wrappedValue as? SimpleError,
            case let .customError(title, msg, _) = simpleError {
            self.simpleErrorToast(
                presentState: .isOptionalPresented(error),
                duration: duration,
                displayMode: displayMode,
                title: title,
                subtitle: msg
            )
        }else {
            self.simpleErrorToast(
                presentState: .isOptionalPresented(error),
                duration: duration,
                displayMode: displayMode,
                title: error.wrappedValue?.localizedDescription ?? "发生错误"
            )
        }
    }
    
    /// 简单UI组件 - 顶部错误提示（可进一步定制）
    @available(*, deprecated, renamed: "simpleErrorBanner(error:)", message: "Toast 已弃用，使用 Popup 作为新的提醒方法")
    func simpleErrorToast<Item: Equatable>(
        presentState: Binding<Item?>,
        duration: Double = 2.0,
        displayMode: ToastView.DisplayMode = .topToast,
        title: String? = nil,
        subtitle: String? = nil,
        labelColor: Color = .red,
        bgColor: Color? = .red,
        withHaptic: Bool = true,
        isDebug: Bool = false,
        onTap: (() -> ())? = nil,
        backgroundTap: (() -> ())? = nil,
        completion: (() -> ())? = nil
    ) -> some View{
        let errorToast = ToastView(
            displayMode: displayMode,
            type: .error(labelColor),
            bgColor: bgColor,
            title: title,
            subTitle: subtitle
        )
        return modifier(
            ToastModifier(
                presentState: presentState,
                duration: duration,
                withHaptic: withHaptic,
                isDebug: isDebug,
                toast: {
                    errorToast
                },
                onTap: onTap,
                backgroundTap: backgroundTap,
                completion: completion)
        )
    }
    
    /// 简单UI组件 - 中央成功动画提示（可进一步定制）
    @available(*, deprecated, renamed: "simpleSuccessBanner(isPresented:)", message: "Toast 已弃用，使用 Popup 作为新的提醒方法")
    func simpleSuccessToast<Item: Equatable>(
        presentState: Binding<Item?>,
        displayMode: ToastView.DisplayMode = .centerToast,
        title: String? = nil,
        subtitle: String? = nil,
        labelColor: Color = .green,
        bgColor: Color? = nil,
        withHaptic: Bool = true,
        isDebug: Bool = false,
        onTap: (() -> ())? = nil,
        backgroundTap: (() -> ())? = nil,
        completion: (() -> ())? = nil
    ) -> some View{
        let errorToast = ToastView(
            displayMode: displayMode,
            type: .success(labelColor),
            bgColor: bgColor,
            title: title,
            subTitle: subtitle
        )
        return modifier(
            ToastModifier(
                presentState: presentState,
                withHaptic: withHaptic,
                isDebug: isDebug,
                toast: {
                    errorToast
                },
                onTap: onTap,
                backgroundTap: backgroundTap,
                completion: completion)
        )
    }
    
    /// 简单UI组件 - 中央载入提示（可进一步定制）
    ///
    /// 不会自动从屏幕消失，需要程序dismss或手动点击
    @available(*, deprecated, renamed: "simpleLoadingBanner(isPresented:)", message: "Toast 已弃用，使用 Popup 作为新的提醒方法")
    func simpleLoadingToast<Item: Equatable>(
        presentState: Binding<Item?>,
        displayMode: ToastView.DisplayMode = .centerToast,
        title: String? = nil,
        subtitle: String? = nil,
        withHaptic: Bool = true,
        isDebug: Bool = false,
        tapToDismiss: Bool = true,
        onTap: (() -> ())? = nil,
        backgroundTap: (() -> ())? = nil,
        completion: (() -> ())? = nil
    ) -> some View{
        let errorToast = ToastView(
            displayMode: displayMode,
            type: .loading,
            title: title,
            subTitle: subtitle
        )
        return modifier(
            ToastModifier(
                presentState: presentState,
                tapToDismiss: tapToDismiss,
                withHaptic: withHaptic,
                isDebug: isDebug,
                toast: {
                    errorToast
                },
                onTap: onTap,
                backgroundTap: backgroundTap,
                completion: completion)
        )
    }
}
