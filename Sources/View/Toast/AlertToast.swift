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

@available(iOS 13, macOS 11, *)
public struct AlertToastModifier: ViewModifier{
    
    ///Presentation `Binding<Bool>`
    @Binding var isPresenting: Bool
    
    ///Duration time to display the alert
    @State var duration: Double = 1.7
    
    ///Tap to dismiss alert
    @State var tapToDismiss: Bool = true
    
    var offsetY: CGFloat = 0
    
    var transition: AnyTransition? = nil
    var withHaptic: Bool = true
    
    ///Init `AlertToast` View
    var toast: () -> ToastView?
    
    ///Completion block returns `true` after dismiss
    var onTap: (() -> ())? = nil
    var completion: (() -> ())? = nil
    
    @State private var workItem: DispatchWorkItem?
    
    @ViewBuilder
    public func main() -> some View{
        if let toastView = toast(), isPresenting{
            toast()
                .onTapGesture {
                    onTap?()
                    if tapToDismiss{
                        withAnimation(Animation.spring()){
                            self.workItem?.cancel()
                            self.workItem = nil
                            isPresenting = false
                        }
                    }
                }
                .onDisappear(perform: {
                    completion?()
                })
                .modifier(ToastTransition(mode: toastView.displayMode,
                                          transition: transition))
        }
    }
    
    @ViewBuilder
    public func body(content: Content) -> some View {
        content
            .overlay {
                main()
                    .offset(y: offsetY)
                    .animation(Animation.spring(), value: isPresenting)
            }
            .onChange(of: toast(), perform: { newToast in
//                print("1.New Toast Changed")
//                print("1.Now Presenting State: \(isPresenting)")
                // 仅使用isPresenting开启时不变
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
                    onAppearAction()
                }
            })
    }
    
    private func onAppearAction(){
        guard let toastView = toast(),
              workItem == nil else {
            return
        }
        
        #if !os(watchOS)
        // 决定是否震动
        if let toastView = toast(), withHaptic {
            switch toastView.type {
            case .success:
                DeviceInfo.playHaptic(.success)
            case .error:
                DeviceInfo.playHaptic(.error)
            default:
                break
            }
        }
        #endif
        
        // 结束Toast的任务
        let dismissTask = DispatchWorkItem {
            withAnimation(Animation.spring()){
//                print("Toast dismiss task done!")
                isPresenting = false
                workItem = nil
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
    let mode: ToastView.DisplayMode
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
    func simpleToast(isPresenting: Binding<Bool>,
                     duration: Double = 1.7,
                     tapToDismiss: Bool = true,
                     offsetY: CGFloat = 0,
                     transition: AnyTransition? = nil,
                     withHaptic: Bool = true,
                     toast: @escaping () -> ToastView?,
                     onTap: (() -> ())? = nil,
                     completion: (() -> ())? = nil) -> some View{
        return modifier(AlertToastModifier(isPresenting: isPresenting,
                                           duration: duration,
                                           tapToDismiss: tapToDismiss,
                                           offsetY: offsetY,
                                           transition: transition,
                                           withHaptic: withHaptic,
                                           toast: toast,
                                           onTap: onTap,
                                           completion: completion))
    }
    
    /// 简单UI组件 - 顶部错误提示（可进一步定制）
    func simpleErrorToast(isPresenting: Binding<Bool>,
                          displayMode: ToastView.DisplayMode = .topToast,
                          title: String?,
                          subtitle: String? = nil,
                          labelColor: Color = .red,
                          bgColor: Color? = .red,
                          withHaptic: Bool = true,
                          onTap: (() -> ())? = nil,
                          completion: (() -> ())? = nil) -> some View{
        let errorToast = ToastView(displayMode: displayMode,
                                   type: .error(labelColor),
                                   bgColor: bgColor,
                                   title: title,
                                   subTitle: subtitle)
        return modifier(AlertToastModifier(isPresenting: isPresenting,
                                           withHaptic: withHaptic,
                                           toast: { errorToast },
                                           onTap: onTap,
                                           completion: completion))
    }
    
    /// 简单UI组件 - 中央成功动画提示（可进一步定制）
    func simpleSuccessToast(isPresenting: Binding<Bool>,
                            displayMode: ToastView.DisplayMode = .centerToast,
                            title: String,
                            subtitle: String? = nil,
                            labelColor: Color = .green,
                            bgColor: Color? = nil,
                            withHaptic: Bool = true,
                            onTap: (() -> ())? = nil,
                            completion: (() -> ())? = nil) -> some View{
        let errorToast = ToastView(displayMode: displayMode,
                                   type: .success(labelColor),
                                   bgColor: bgColor,
                                   title: title,
                                   subTitle: subtitle)
        return modifier(AlertToastModifier(isPresenting: isPresenting,
                                           withHaptic: withHaptic,
                                           toast: { errorToast },
                                           onTap: onTap,
                                           completion: completion))
    }
    
    /// 简单UI组件 - 中央载入提示（可进一步定制）
    ///
    /// 不会自动从屏幕消失，需要程序dismss或手动点击
    func simpleLoadingToast(isPresenting: Binding<Bool>,
                            displayMode: ToastView.DisplayMode = .centerToast,
                            title: String,
                            subtitle: String? = nil,
                            withHaptic: Bool = true,
                            tapToDismiss: Bool = true,
                            onTap: (() -> ())? = nil,
                            completion: (() -> ())? = nil) -> some View{
        let errorToast = ToastView(displayMode: displayMode,
                                   type: .loading,
                                   title: title,
                                   subTitle: subtitle)
        return modifier(AlertToastModifier(isPresenting: isPresenting,
                                           tapToDismiss: tapToDismiss,
                                           withHaptic: withHaptic,
                                           toast: { errorToast },
                                           onTap: onTap,
                                           completion: completion))
    }
}

#Preview("Alert") {
    AlertTestView()
}
