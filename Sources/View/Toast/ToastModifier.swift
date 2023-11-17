//MIT License
//
//Copyright (c) 2021 Elai Zuberman
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import SwiftUI
import Combine

public enum LoadingState: String, Equatable {
    case loading, quietLoading
    case success
    case error
}

#if os(iOS)
private struct BackgroundTransparentView: UIViewRepresentable {
    func makeUIView(context _: Context) -> UIView {
        TransparentView()
    }
    
    func updateUIView(_: UIView, context _: Context) {}
    
    private class TransparentView: UIView {
        override func layoutSubviews() {
            super.layoutSubviews()
            superview?.superview?.backgroundColor = .clear
        }
    }
}
#endif

@available(iOS 13, macOS 11, *)
public struct ToastModifier<Item: Equatable>: ViewModifier{
    
//    @Binding var isPresenting: Bool
    @Binding var presentState: Item?
    
    ///Duration time to display the alert
    @State var duration: Double = 1.7
    
    ///Tap to dismiss alert
    @State var tapToDismiss: Bool = true
    @State var tapBackgroundToDismiss: Bool = false
    
    var offsetY: CGFloat = 0
    var transition: AnyTransition? = nil
    var withHaptic: Bool = true
    
    ///Init `AlertToast` View
    var toast: () -> ToastView?
    
    ///Completion block returns `true` after dismiss
    var onTap: (() -> ())? = nil
    var backgroundTap: (() -> ())? = nil
    var completion: (() -> ())? = nil
    
    @State private var workItem: DispatchWorkItem?
    @State private var showToast = false
    // 条件符合后首先开启背景，随后设置dismiss的任务
    private var isBackgroundPresent: Bool {
        var isPresent = false
        if toast() != nil, let presentState {
            if presentState is Bool {
                isPresent = presentState as! Bool
            }else {
                isPresent = true
            }
        }
        
        #if os(iOS)
        if isPresent {
//            print("1.开启Toast的背景")
            // 1. 开启背景无动画
            UIView.setAnimationsEnabled(false)
        }
        #endif
        
        return isPresent
    }
    
    @ViewBuilder
    public func main() -> some View{
        if showToast, let toastView = toast() {
            toastView
                .modifier(ToastTransition(mode: toast()?.displayMode,
                                          transition: transition))
                .onTapGesture {
                    onTap?()
                    if tapToDismiss {
                        dismissToast()
                    }
                }
                .onDisappear {
                    // 即使迭代，仅在最后一个dismiss后回调
                    completion?()
                }
        }
    }
    
    @ViewBuilder
    public func body(content: Content) -> some View {
        content
        #if os(iOS)
            .fullScreenCover(isPresented: .constant(isBackgroundPresent)) {
                Color.clear
                    .background(BackgroundTransparentView())
                    .onTapGesture {
                        backgroundTap?()
                        if tapBackgroundToDismiss {
                            dismissToast()
                        }
                    }
                    .overlay {
                        main()
                            .offset(y: offsetY)
                            .animation(Animation.spring(), value: showToast)
                    }
                    .onAppear {
//                        print("3.开启Toast视图")
                        // 2. 在背景开启后，开启动画并呈现 Toast 视图
                        UIView.setAnimationsEnabled(true)
                        showToast = true
                        playHaptic()
                    }
                    .onDisappear {
//                        print("5.背景关闭，开启视图动画")
                        // 4. 背景消失后，重新开启视图动画
                        UIView.setAnimationsEnabled(true)
                    }
            }
        #else
            .overlay {
                main()
                    .offset(y: offsetY)
                    .animation(Animation.spring(), value: showToast)
            }
        #endif
            .onChange(of: presentState, perform: { newState in
                // View必须被设置
                guard let _ = toast() else {
                    dismissToast()
                    return
                }
                // nil, Bool, Item
                // 开启Toast，或者迭代一个Toast
                var isToastPresent = false
                if let isPresent = newState.toBool() {
                    isToastPresent = isPresent
                }else {
                    // state 可能进行迭代
                    isToastPresent = newState != nil
                }
                
                if isToastPresent {
                    #if os(watchOS) || os(macOS)
                    showToast = true
                    #endif
                    if showToast {
                        playHaptic()
                    }
                    
                    if let workItem {
                        // 对已经呈现的 Toast 进行迭代
                        workItem.cancel()
                        self.workItem = nil
                    }
                    onAppearAction()
                }
            })
    }
    
    private func dismissToast() {
        if let workItem {
            workItem.perform()
        }
    }
    
    private func dismissBackground() {
//        print("4.Toast视图准备关闭，开始关闭背景")
        // 3. 在 toast 消失后关闭动画，再dismiss背景
        #if os(iOS)
        UIView.setAnimationsEnabled(false)
        #endif
        presentState = nil
    }
    
    private func onAppearAction(){
        guard let toastView = toast(),
              workItem == nil else {
            return
        }
        
//        print("2.设置定时结束的任务")
        
        // 结束Toast的任务
        let dismissToastTask = DispatchWorkItem {
            if #available(iOS 17.0, watchOS 10.0, macOS 14.0, *) {
                withAnimation {
                    showToast = false
                    workItem = nil
                } completion: {
                    dismissBackground()
                }
            } else {
                withAnimation(Animation.spring()){
                    showToast = false
                    workItem = nil
                }
                dismissBackground()
            }
        }
        
        // loading不会自动关闭，需手动结束
        workItem = dismissToastTask
        if duration > 0 && toastView.type != .loading {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: dismissToastTask)
        }
    }
    
    private func playHaptic() {
        if let toastView = toast(), withHaptic {
            switch toastView.type {
            case .success:
                #if os(iOS)
                DeviceInfo.playHaptic(.success)
                #elseif canImport(WatchKit)
                DeviceInfo.playWatchHaptic(.success)
                #endif
            case .error:
                #if os(iOS)
                DeviceInfo.playHaptic(.error)
                #elseif canImport(WatchKit)
                DeviceInfo.playWatchHaptic(.failure)
                #endif
            default:
                break
            }
        }
    }
}

fileprivate struct ToastTransition: ViewModifier {
    let mode: ToastView.DisplayMode?
    var transition: AnyTransition? = nil
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if let transition {
            content.transition(transition)
        }else {
            switch mode {
            case .centerToast:
                content
                    .transition(.scale(scale: 0.6).combined(with: .opacity))
            case .topToast:
                content
                    .transition(.move(edge: .top).combined(with: .opacity))
            case .bottomToast:
                content
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            case .none:
                content
            }
        }
    }
}

public extension View{
    /// 简单UI组件 -  Toast
    ///
    /// 使用不同的 Toast 类别传递时可以迭代，并重置关闭时间；
    ///
    /// loading 不会自动关闭，但是迭代为其他类型后会重置时间并关闭。
    ///
    /// iOS 端使用了 fullScreenCover 技术路线，其他平台是 overlay，但还是需要尽量放置在最根部的视图组件处。
    func simpleToast<Item: Equatable>(
        presentState: Binding<Item?>,
        duration: Double = 1.7,
        tapToDismiss: Bool = true,
        tapBackgroundToDismiss: Bool = false,
        offsetY: CGFloat = 0,
        transition: AnyTransition? = nil,
        withHaptic: Bool = true,
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
                toast: toast,
                onTap: onTap,
                backgroundTap: backgroundTap,
                completion: completion))}
    
    /// 简单UI组件 - 顶部错误提示（可进一步定制）
    func simpleErrorToast<Item: Equatable>(presentState: Binding<Item?>,
                          displayMode: ToastView.DisplayMode = .topToast,
                          title: String? = nil,
                          subtitle: String? = nil,
                          labelColor: Color = .red,
                          bgColor: Color? = .red,
                          withHaptic: Bool = true,
                          onTap: (() -> ())? = nil,
                          backgroundTap: (() -> ())? = nil,
                          completion: (() -> ())? = nil) -> some View{
        let errorToast = ToastView(displayMode: displayMode,
                                   type: .error(labelColor),
                                   bgColor: bgColor,
                                   title: title,
                                   subTitle: subtitle)
        return modifier(ToastModifier(presentState: presentState,
                                      withHaptic: withHaptic,
                                      toast: { errorToast },
                                      onTap: onTap,
                                      backgroundTap: backgroundTap,
                                      completion: completion))
    }
    
    /// 简单UI组件 - 中央成功动画提示（可进一步定制）
    func simpleSuccessToast<Item: Equatable>(presentState: Binding<Item?>,
                            displayMode: ToastView.DisplayMode = .centerToast,
                            title: String? = nil,
                            subtitle: String? = nil,
                            labelColor: Color = .green,
                            bgColor: Color? = nil,
                            withHaptic: Bool = true,
                            onTap: (() -> ())? = nil,
                            backgroundTap: (() -> ())? = nil,
                            completion: (() -> ())? = nil) -> some View{
        let errorToast = ToastView(displayMode: displayMode,
                                   type: .success(labelColor),
                                   bgColor: bgColor,
                                   title: title,
                                   subTitle: subtitle)
        return modifier(ToastModifier(presentState: presentState,
                                      withHaptic: withHaptic,
                                      toast: { errorToast },
                                      onTap: onTap,
                                      backgroundTap: backgroundTap,
                                      completion: completion))
    }
    
    /// 简单UI组件 - 中央载入提示（可进一步定制）
    ///
    /// 不会自动从屏幕消失，需要程序dismss或手动点击
    func simpleLoadingToast<Item: Equatable>(presentState: Binding<Item?>,
                            displayMode: ToastView.DisplayMode = .centerToast,
                            title: String? = nil,
                            subtitle: String? = nil,
                            withHaptic: Bool = true,
                            tapToDismiss: Bool = true,
                            onTap: (() -> ())? = nil,
                            backgroundTap: (() -> ())? = nil,
                            completion: (() -> ())? = nil) -> some View{
        let errorToast = ToastView(displayMode: displayMode,
                                   type: .loading,
                                   title: title,
                                   subTitle: subtitle)
        return modifier(ToastModifier(presentState: presentState,
                                      tapToDismiss: tapToDismiss,
                                      withHaptic: withHaptic,
                                      toast: { errorToast },
                                      onTap: onTap,
                                      backgroundTap: backgroundTap,
                                      completion: completion))
    }
}

#Preview("Alert") {
    AlertTestView()
}
