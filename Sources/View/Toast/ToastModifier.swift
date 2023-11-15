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
public struct ToastModifier: ViewModifier{
    
    ///Presentation `Binding<Bool>`
    @Binding var isPresenting: Bool
    
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
    private var isToastPresent: Bool {
        toast() != nil && isPresenting
    }
    
    private func dismissToast() {
        if let workItem {
            workItem.perform()
        }
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
                    showToast = false
                    completion?()
                }
        }
    }
    
    @ViewBuilder
    public func body(content: Content) -> some View {
        content
        #if os(iOS)
            .fullScreenCover(isPresented: .constant(isToastPresent)) {
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
                        if !UIView.areAnimationsEnabled {
                            UIView.setAnimationsEnabled(true)
                            showToast = true
                        }
                    }
                    .onDisappear {
                        UIView.setAnimationsEnabled(true)
                    }
            }
        #else
            .overlay {
                main()
                    .offset(y: offsetY)
                    .animation(Animation.spring(), value: isPresenting)
            }
        #endif
            .onChange(of: toast(), perform: { newToast in
//                print("1.New Toast Changed")
//                print("1.Now Presenting State: \(isPresenting)")
                if newToast != nil {
                    #if os(watchOS) || os(macOS)
                    showToast = true
                    #elseif os(iOS)
                    UIView.setAnimationsEnabled(false)
                    #endif
                }
                // 已经有一个任务开启时结束前一个任务，开启新任务
                if newToast != nil, let workItem {
                    workItem.cancel()
                    self.workItem = nil
                    onAppearAction()
                }
            })
            .onChange(of: isPresenting, perform: { presenting in
//                print("2.New Presenting Changed: \(presenting)")
                // 使用两种方式都会改变
                if presenting {
                    #if os(watchOS) || os(macOS)
                    showToast = true
                    #elseif os(iOS)
                    UIView.setAnimationsEnabled(false)
                    #endif
                    onAppearAction()
                }
            })
    }
    
    private func onAppearAction(){
        guard let toastView = toast(),
              workItem == nil else {
            return
        }
        
        // 决定是否震动
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
        
        // 结束Toast的任务
        let dismissTask = DispatchWorkItem {
            #if os(iOS)
            UIView.setAnimationsEnabled(false)
            #endif
            withAnimation(Animation.spring()){
                showToast = false
                workItem = nil
                isPresenting = false
            }
        }
        
        // loading不会自动关闭，需手动结束
        workItem = dismissTask
        if duration > 0 && toastView.type != .loading{
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: dismissTask)
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

@available(iOS 13, macOS 11, *)
public extension View{
    /// 简单UI组件 -  Toast
    ///
    /// 使用不同的 Toast 类别传递时可以迭代，并重置关闭时间；
    ///
    /// loading 不会自动关闭，但是迭代为其他类型后会重置时间并关闭。
    ///
    /// iOS 端使用了 fullScreenCover 技术路线，其他平台是 overlay，但还是需要尽量放置在最根部的视图组件处。
    func simpleToast(isPresenting: Binding<Bool>,
                     duration: Double = 1.7,
                     tapToDismiss: Bool = true,
                     tapBackgroundToDismiss: Bool = false,
                     offsetY: CGFloat = 0,
                     transition: AnyTransition? = nil,
                     withHaptic: Bool = true,
                     @ViewBuilder toast: @escaping () -> ToastView?,
                     onTap: (() -> ())? = nil,
                     backgroundTap: (() -> ())? = nil,
                     completion: (() -> ())? = nil) -> some View{
        return modifier(ToastModifier(isPresenting: isPresenting,
                                      duration: duration,
                                      tapToDismiss: tapToDismiss,
                                      tapBackgroundToDismiss: tapBackgroundToDismiss,
                                      offsetY: offsetY,
                                      transition: transition,
                                      withHaptic: withHaptic,
                                      toast: toast,
                                      onTap: onTap,
                                      backgroundTap: backgroundTap,
                                      completion: completion))
    }
    
    /// 简单UI组件 - 顶部错误提示（可进一步定制）
    func simpleErrorToast(isPresenting: Binding<Bool>,
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
        return modifier(ToastModifier(isPresenting: isPresenting,
                                      withHaptic: withHaptic,
                                      toast: { errorToast },
                                      onTap: onTap,
                                      backgroundTap: backgroundTap,
                                      completion: completion))
    }
    
    /// 简单UI组件 - 中央成功动画提示（可进一步定制）
    func simpleSuccessToast(isPresenting: Binding<Bool>,
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
        return modifier(ToastModifier(isPresenting: isPresenting,
                                      withHaptic: withHaptic,
                                      toast: { errorToast },
                                      onTap: onTap,
                                      backgroundTap: backgroundTap,
                                      completion: completion))
    }
    
    /// 简单UI组件 - 中央载入提示（可进一步定制）
    ///
    /// 不会自动从屏幕消失，需要程序dismss或手动点击
    func simpleLoadingToast(isPresenting: Binding<Bool>,
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
        return modifier(ToastModifier(isPresenting: isPresenting,
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
