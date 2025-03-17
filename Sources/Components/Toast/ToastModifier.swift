
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


fileprivate struct ClearBackground: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(watchOS 9.4, iOS 16.4, macOS 13.3, *) {
            content
                .presentationBackground(.black.opacity(0.1))
                .presentationBackgroundInteraction(.enabled)
                .allowsHitTesting(false)
        }else {
            content
                .background(BackgroundTransparentView())
        }
    }
}
#endif

public struct ToastModifier<Item: Equatable>: ViewModifier{
    
    //    @Binding var isPresenting: Bool
    @Binding var presentState: Item?
    
    ///Duration time to display the alert
    var duration: Double = 1.7
    
    ///Tap to dismiss alert
    @State var tapToDismiss: Bool = true
    @State var tapBackgroundToDismiss: Bool = false
    
    var offsetY: CGFloat = 0
    var transition: AnyTransition? = nil
    var withHaptic: Bool = true
    var isDebug: Bool = false
    
    ///Init `AlertToast` View
    var toast: () -> ToastView?
    
    ///Completion block returns `true` after dismiss
    var onTap: (() -> ())? = nil
    var backgroundTap: (() -> ())? = nil
    var completion: (() -> ())? = nil
    
    @State private var workItem: DispatchWorkItem?
    @State private var showToast = false
    
    public init(
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
        completion: (() -> ())? = nil
    ) {
        self._presentState = presentState
        self.duration = duration
        self.tapToDismiss = tapToDismiss
        self.tapBackgroundToDismiss = tapBackgroundToDismiss
        self.offsetY = offsetY
        self.transition = transition
        self.withHaptic = withHaptic
        self.isDebug = isDebug
        self.toast = toast
        self.onTap = onTap
        self.backgroundTap = backgroundTap
        self.completion = completion
    }
    
    @ViewBuilder
    public func main() -> some View{
        if showToast, let toastView = toast() {
            toastView
                .modifier(
                    ToastTransition(
                        mode: toast()?.displayMode,
                        transition: transition
                    )
                )
                .onTapGesture {
                    if isDebug{ debugPrint("Toast onTap action") }
                    onTap?()
                    if tapToDismiss {
                        dismissToast()
                    }
                }
                .onDisappear {
                    // 即使迭代，仅在最后一个dismiss后回调
                    if isDebug{ debugPrint("Toast completion action") }
                    completion?()
                }
        }
    }
    
    @ViewBuilder
    public func body(content: Content) -> some View {
        content
            .overlay {
                main()
                    .offset(y: offsetY)
                    .animation(Animation.spring(), value: showToast)
            }
            .onChange(of: presentState) {
                if isDebug{ debugPrint("Toast State改变:\(String(describing: presentState))") }
                
                // View必须被设置
                guard toast() != nil else {
                    dismissToast()
                    return
                }
                // nil, Bool, Item
                // 开启Toast，或者迭代一个Toast
                var isToastPresent = false
                if let isPresent = presentState.toBool() {
                    isToastPresent = isPresent
                }else {
                    // state 可能进行迭代
                    isToastPresent = presentState != nil
                }
                
                if isDebug{ debugPrint("Toast是否开启: \(isToastPresent.toString())") }
                if isToastPresent {
                    DispatchQueue.main.async {
                        showToast = true
                        if showToast {
                            if isDebug{ debugPrint("Toast开启 Haptic 震动") }
                            playHaptic()
                        }
                    }
                    if let workItem {
                        // 对已经呈现的 Toast 进行迭代
                        workItem.cancel()
                        self.workItem = nil
                    }
                    onAppearAction()
                }else {
                    dismissToast()
                }
            }
    }
    
    private func dismissToast() {
        if let workItem {
            workItem.perform()
        }
    }
    
    private func dismissBackground() {
        //        print("4.Toast视图准备关闭，开始关闭背景")
        // 3. 在 toast 消失后关闭动画，再dismiss背景
        if isDebug{ debugPrint("Toast dismiss消失") }
        DispatchQueue.main.async {
            presentState = nil
        }
    }
    
    private func onAppearAction(){
        guard let toastView = toast(),
              workItem == nil else {
            return
        }
        
        //        print("2.设置定时结束的任务")
        
        // 结束Toast的任务
        let dismissToastTask = DispatchWorkItem {
            withAnimation {
                showToast = false
                workItem = nil
            } completion: {
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
                SimpleHaptic.playSuccessHaptic()
            case .error:
                SimpleHaptic.playFailureHaptic()
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

#Preview("Alert") {
    DemoSimpleToast()
}
