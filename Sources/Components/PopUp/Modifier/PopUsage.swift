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
    func simpleBanner(
        isPresented: Binding<Bool>,
        title: String? = nil,
        subTitle: String? = nil,
        systemImage: String? = nil,
        isCenter: Bool = false,
        bgColor: Color? = nil,
        duration: Double = 1.6,
        dismissCallback: @escaping (DismissSource)->() = {_ in}
    ) -> some View {
        self.popup(isPresented: isPresented) {
            if isCenter {
                PopHud(mode: .text, title: title, subTitle: subTitle, systemImage: systemImage, bgColor: bgColor)
            }else {
                PopBanner(mode: .text, title: title, subTitle: subTitle, systemImage: systemImage, bgColor: bgColor)
            }
        } customize: { content in
            content
                .type(isCenter ? .default : .floater())
                .position(isCenter ? .center : .top)
                .appearFrom(isCenter ? .centerScale : .topSlide)
                .autohideIn(duration)
                .dismissCallback(dismissCallback)
        }
    }
    
    /// 失败的提醒
    func simpleErrorBanner(
        error: Binding<Error?>,
        systemImage: String? = nil,
        isTop: Bool = true,
        bgColor: Color? = nil,
        hasHaptic: Bool = true,
        duration: Double = 2.2
    ) -> some View {
        self.popup(isPresented: .isPresented(error)) {
            if let simpleError = error.wrappedValue as? SimpleError,
               case let .customError(title, msg, _) = simpleError {
                PopBanner(mode: .error, title: title, subTitle: msg, systemImage: systemImage, bgColor: bgColor)
            }else {
                PopBanner(mode: .error, title: error.wrappedValue?.localizedDescription ?? "An error occurred", systemImage: systemImage, bgColor: bgColor)
            }
        } customize: { content in
            content
                .type(.floater())
                .position(isTop ? .top : .bottom)
                .autohideIn(duration)
                .haptic(hasHaptic ? .failure : nil)
        }
    }
    
    /// 无法联网的提醒
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
        systemImage: String? = nil,
        isCenter: Bool = false,
        bgColor: Color? = nil,
        hasHaptic: Bool = true,
        duration: Double = 1.6,
        dismissCallback: @escaping (DismissSource)->() = {_ in}
    ) -> some View {
        self.popup(isPresented: isPresented) {
            if isCenter {
                PopHud(mode: .success, title: title, subTitle: subTitle, bgColor: bgColor)
            }else {
                PopBanner(mode: .success, title: title, subTitle: subTitle, systemImage: systemImage, bgColor: bgColor)
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
    
    func simpleSuccessBanner(
        subTitle: Binding<String?>,
        title: String? = nil,
        bundle: Bundle = .main,
        systemImage: String? = nil,
        isCenter: Bool = false,
        bgColor: Color? = nil,
        hasHaptic: Bool = true,
        duration: Double = 1.6,
        dismissCallback: @escaping (DismissSource)->() = {_ in}
    ) -> some View {
        self.popup(item: subTitle) { subTitle in
            if isCenter {
                PopHud(mode: .success, title: title, subTitle: subTitle, bundle: bundle, bgColor: bgColor)
            }else {
                PopBanner(mode: .success, title: title, subTitle: subTitle, bundle: bundle, systemImage: systemImage, bgColor: bgColor)
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
    
    /// 成功复制的提醒
    func simpleCopyBanner(
        subTitle: Binding<String?>,
        isCenter: Bool = false,
        bgColor: Color? = .indigo_07) -> some View {
            self.simpleSuccessBanner(
                subTitle: subTitle,
                title: .copied,
                bundle: .module,
                systemImage: "list.bullet.clipboard",
                isCenter: isCenter,
                bgColor: bgColor
            )
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
        systemImage: String? = nil,
        isCenter: Bool = true,
        closeOnTap: Bool = false,
        hasBackground: Bool = true,
        dismissCallback: @escaping (DismissSource)->() = {_ in}
    ) -> some View {
        self.popup(isPresented: isPresented) {
            if isCenter {
                PopHud(mode: .loading, title: title, subTitle: subTitle, systemImage: systemImage)
            }else {
                PopBanner(mode: .loading, title: title, subTitle: subTitle, systemImage: systemImage)
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
    
    func simpleInputSheet(
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
        showBackground: Bool = true,
        saveAction: @escaping (SimpleTextInputView.inputResult)->Void
    ) -> some View {
        self.sheet(isPresented: isPresented) {
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
                dismissTap: isPresented,
                saveAction: saveAction
            )
            .presentationDetents([.height(showContent ? 380 : 200)])
            .presentationDragIndicator(.hidden)
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
                dismissTap: isPresented,
                saveAction: saveAction
            )
            .padding(.horizontal, 10)
            .frame(maxHeight: showContent ? 370 : 190)
            .modifier(ShadowModifier())
        } customize: {
            var content = $0
            content.type = .floater()
            content.position = .bottom
            content.closeOnTap = false
            content.appearFrom = .bottomSlide
            if showBackground {
                content.backgroundView = AnyView(PopBackgroundView())
            }
            return content
        }
    }
}
