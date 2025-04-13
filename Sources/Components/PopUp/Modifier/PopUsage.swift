//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/4/13.
//

import Foundation
import SwiftUI

// MARK: - 场景应用方法
@MainActor
public extension View {
    func simpleErrorBanner(
        error: Binding<Error?>,
        isTop: Bool = true,
        hasHaptic: Bool = true,
        duration: Double = 2.0
    ) -> some View {
        self.popup(isPresented: .isPresented(error)) {
            if let simpleError = error.wrappedValue as? SimpleError,
               case let .customError(title, msg, _) = simpleError {
                PopBanner(mode: .error, title: title, subTitle: msg)
            }else {
                PopBanner(mode: .error, title: error.wrappedValue?.localizedDescription ?? "发生错误")
            }
        } customize: { content in
            content
                .type(.floater())
                .position(isTop ? .top : .bottom)
                .autohideIn(duration)
                .haptic(hasHaptic ? .failure : nil)
        }
    }
    
    func simpleNoInternetBanner(
        isPresented: Binding<Bool>,
        isBottom: Bool = true,
        duration: Double = 5.0
    ) -> some View {
        self.popup(isPresented: isPresented) {
            PopBanner(mode: .noInternet)
        } customize: { content in
            content
                .type(.floater())
                .position(isBottom ? .bottom : .top)
                .appearFrom(isBottom ? .bottomSlide : .topSlide)
                .autohideIn(duration)
                .closeOnTap(false)
        }
    }
    
    /// 成功的提醒
    /// - Parameters:
    ///   - isPresented: 是否显示
    ///   - title: 标题
    ///   - subTitle: 子标题
    ///   - isCenter: 是否居中（True：居中 HUD False：上方 Banner）
    ///   - hasBackground: 是否有背景
    ///   - dismissCallback: 关闭之后的回调
    func simpleSuccessBanner(
        isPresented: Binding<Bool>,
        title: String? = nil,
        subTitle: String? = nil,
        isCenter: Bool = true,
        hasHaptic: Bool = true,
        duration: Double = 1.6,
        dismissCallback: @escaping (DismissSource)->() = {_ in}
    ) -> some View {
        self.popup(isPresented: isPresented) {
            if isCenter {
                PopHud(mode: .success, title: title, subTitle: subTitle)
            }else {
                PopBanner(mode: .success, title: title, subTitle: title)
            }
        } customize: {
            var content = $0
            content.type = isCenter ? .default : .floater()
            content.position = isCenter ? .center : .top
            content.appearFrom = isCenter ? .centerScale : .topSlide
            content.autohideIn = duration
            content.haptic = hasHaptic ? .success : nil
            content.dismissCallback = dismissCallback
            
            return content
        }
    }
    
    /// 加载的提醒
    /// - Parameters:
    ///   - isPresented: 是否显示
    ///   - title: 标题（空则默认“正在载入...”）
    ///   - subTitle: 子标题
    ///   - isCenter: 是否居中（True：居中 HUD False：上方 Banner）
    ///   - hasBackground: 是否有背景
    ///   - dismissCallback: 关闭回调
    func simpleLoadingBanner(
        isPresented: Binding<Bool>,
        title: String? = nil,
        subTitle: String? = nil,
        isCenter: Bool = true,
        closeOnTap: Bool = false,
        hasBackground: Bool = true,
        dismissCallback: @escaping (DismissSource)->() = {_ in}
    ) -> some View {
        self.popup(isPresented: isPresented) {
            if isCenter {
                PopHud(mode: .loading, title: title, subTitle: subTitle)
            }else {
                PopBanner(mode: .loading, title: title, subTitle: subTitle)
            }
        } customize: { content in
            var content = content
            content.type = isCenter ? .default : .floater()
            content.position = isCenter ? .center : .top
            content.appearFrom = isCenter ? .centerScale : .topSlide
            content.autohideIn = nil
            content.closeOnTap = closeOnTap
            if hasBackground {
                content.backgroundView = AnyView(PopBackgroundView())
            }
            content.dismissCallback = dismissCallback
            return content
        }
    }
    
    func simpleInputBanner(
        isPresented: Binding<Bool>,
        pageName: String = "",
        title: String = "",
        content: String = "",
        titlePrompt: String? = nil,
        contentPrompt: String? = nil,
        isTitleRequired: Bool = false,
        isContentRequired: Bool = false,
        showTitle: Bool = true,
        showContent: Bool = false,
        tintColor: Color = .accentColor,
        cornerRadius: CGFloat = 15,
        showBackground: Bool = true,
        dismissTap: Binding<Bool>,
        saveAction: @escaping (SimpleTextInputView.inputResult)->Void
    ) -> some View {
        self.popup(isPresented: isPresented) {
            SimpleTextInputView(
                pageName: pageName,
                title: title,
                content: content,
                titlePrompt: titlePrompt,
                contentPrompt: contentPrompt,
                isTitleRequired: isTitleRequired,
                isContentRequired: isContentRequired,
                showTitle: showTitle,
                showContent: showContent,
                tintColor: tintColor,
                cornerRadius: cornerRadius,
                dismissTap: dismissTap,
                saveAction: saveAction
            )
            .padding(.horizontal)
            .frame(maxHeight: showContent ? 370 : 190)
            .modifier(ShadowModifier())
        } customize: {
            var content = $0
            content.type = .floater()
            content.position = .bottom
            content.closeOnTap = false
            content.appearFrom = .bottomSlide
            content.useKeyboardSafeArea = true
            if showBackground {
                content.backgroundView = AnyView(PopBackgroundView())
            }
            return content
        }
    }
}
