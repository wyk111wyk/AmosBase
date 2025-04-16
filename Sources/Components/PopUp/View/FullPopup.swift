//
//  FullscreenPopup.swift
//  Pods
//
//  Created by Alisa Mylnikova on 29.12.2022.
//

import Foundation
import SwiftUI

/// 弹窗的生命周期和相关视图的管理
@MainActor
public struct FullscreenPopup<Item: Equatable, PopupContent: View>: ViewModifier {

    // MARK: - Presentation

    @State var id = UUID()

    @Binding var isPresented: Bool
    @Binding var item: Item?

    var isBoolMode: Bool

    var popupPresented: Bool {
        item != nil || isPresented
    }

    // MARK: - Parameters

    /// Haptic feedback
    var haptic: Popup<PopupContent>.HapticType?
    
    /// If nil - never hides on its own
    var autohideIn: Double?

    /// Should close on tap outside - default is `false`
    var closeOnTapOutside: Bool

    /// Background color for outside area - default is `Color.clear`
    var backgroundColor: Color

    /// Custom background view for outside area
    var backgroundView: AnyView?

    /// If opaque - taps do not pass through popup's background color
    var displayMode: Popup<PopupContent>.DisplayMode

    /// called when when dismiss animation starts
    var userWillDismissCallback: (DismissSource) -> ()

    /// called when when dismiss animation ends
    var userDismissCallback: (DismissSource) -> ()

    var params: Popup<PopupContent>.PopupParameters

    var view: (() -> PopupContent)!
    var itemView: ((Item) -> PopupContent)!

    // MARK: - Presentation animation

    /// Trigger popup showing/hiding animations and...
    @State private var shouldShowContent = false

    /// ... once hiding animation is finished remove popup from the memory using this flag
    @State private var showContent = false

    /// keep track of closing state to avoid unnecessary showing bug
    @State private var closingIsInProcess = false

    /// show transparentNonAnimatingFullScreenCover
    @State private var showSheet = false

    /// opacity of background color
    @State private var animatableOpacity: CGFloat = 0

    /// A temporary variable to hold a copy of the `itemView` when the item is nil (to complete `itemView`'s dismiss animation)
    @State private var tempItemView: PopupContent?

    // MARK: - Autohide

    /// Class reference for capturing a weak reference later in dispatch work holder.
    private var isPresentedRef: ClassReference<Binding<Bool>>?
    private var itemRef: ClassReference<Binding<Item?>>?

    /// holder for autohiding dispatch work (to be able to cancel it when needed)
    @State private var autohidingWorkHolder = DispatchWorkHolder()

    /// holder for `dismissibleIn` dispatch work (to be able to cancel it when needed)
    @State private var dismissibleInWorkHolder = DispatchWorkHolder()

    // MARK: - Autohide With Dragging
    /// If user "grabbed" the popup to drag it around, put off the autohiding until he lifts his finger up

    /// is user currently holding th popup with his finger
    @State private var isDragging = false

    /// if autohide time was set up, shows that timer has come to an end already
    @State private var timeToHide = false

    // MARK: - Internal

    /// Set dismiss source to pass to dismiss callback
    @State private var dismissSource: DismissSource?

    /// Synchronize isPresented changes and animations
    private let eventsQueue = DispatchQueue(label: "eventsQueue", qos: .utility)
    // 确保同一时间只有一个任务在执行关键代码块
    @State private var eventsSemaphore = DispatchSemaphore(value: 1)

    init(isPresented: Binding<Bool> = .constant(false),
         item: Binding<Item?> = .constant(nil),
         isBoolMode: Bool,
         params: Popup<PopupContent>.PopupParameters,
         view: (() -> PopupContent)?,
         itemView: ((Item) -> PopupContent)?) {
        self._isPresented = isPresented
        self._item = item
        self.isBoolMode = isBoolMode

        self.params = params
        self.haptic = params.haptic
        self.autohideIn = params.autohideIn
        self.closeOnTapOutside = params.closeOnTapOutside
        self.backgroundColor = params.backgroundColor
        self.backgroundView = params.backgroundView
        self.displayMode = params.displayMode
        self.userDismissCallback = params.dismissCallback
        self.userWillDismissCallback = params.willDismissCallback

        if let view = view {
            self.view = view
        }
        if let itemView = itemView {
            self.itemView = itemView
        }

        self.isPresentedRef = ClassReference(self.$isPresented)
        self.itemRef = ClassReference(self.$item)
    }

    public func body(content: Content) -> some View {
        if isBoolMode {
            main(content: content)
                .onChange(of: isPresented) {
                    eventsQueue.async { [eventsSemaphore] in
                        // 但如果信号量没有被正确释放（通过 signal()），后续任务会一直等待
                        // 检查代码中是否有 eventsSemaphore.signal() 的调用，用于在任务完成后释放信号量
                        eventsSemaphore.wait()
                        DispatchQueue.main.async {
                            closingIsInProcess = !isPresented
                            appearAction(popupPresented: isPresented)
                        }
                    }
                }
                .onAppear {
                    if isPresented {
                        appearAction(popupPresented: true)
                    }
                }
        } else {
            main(content: content)
                .onChange(of: item) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                        self.closingIsInProcess = item == nil
                        if let item {
                            /// copying `itemView`
                            self.tempItemView = itemView(item)
                        }
                        appearAction(popupPresented: item != nil)
                    }
                }
                .onAppear {
                    if let item {
                        self.tempItemView = itemView(item)
                        appearAction(popupPresented: true)
                    }
                }
        }
    }

    @ViewBuilder
    public func main(content: Content) -> some View {
#if os(iOS)
        switch displayMode {
        case .overlay:
            ZStack {
                content
                constructPopup()
            }

        case .sheet:
            content.transparentNonAnimatingFullScreenCover(
                isPresented: $showSheet,
                dismissSource: dismissSource,
                userDismissCallback: userDismissCallback
            ) {
                constructPopup()
            }

        case .window:
            content
                .onChange(of: showSheet) {
                    if showSheet {
                        WindowManager.showInNewWindow(id: id, dismissClosure: {
                            dismissSource = .binding
                            isPresented = false
                            item = nil
                        }) {
                            constructPopup()
                        }
                    } else {
                        WindowManager.closeWindow(id: id)
                    }
                }
        }
#else
            ZStack {
                content
                constructPopup()
            }
#endif
    }
    
    @MainActor
    func dismissPopup() {
        if !isPresented {
            eventsQueue.async { [eventsSemaphore] in
                // 但如果信号量没有被正确释放（通过 signal()），后续任务会一直等待
                // 检查代码中是否有 eventsSemaphore.signal() 的调用，用于在任务完成后释放信号量
                eventsSemaphore.wait()
                DispatchQueue.main.async {
                    closingIsInProcess = true
                    appearAction(popupPresented: false)
                }
            }
        }else if item == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                self.closingIsInProcess = true
                if let item {
                    /// copying `itemView`
                    self.tempItemView = itemView(item)
                }
                appearAction(popupPresented: false)
            }
        }
    }
    
    /// 背景 + 弹窗的构造
    @ViewBuilder
    func constructPopup() -> some View {
        if showContent {
            PopupBackgroundView(
                id: $id,
                isPresented: $isPresented,
                item: $item,
                animatableOpacity: $animatableOpacity,
                dismissSource: $dismissSource,
                backgroundColor: backgroundColor,
                backgroundView: backgroundView,
                closeOnTapOutside: closeOnTapOutside
            )
            .modifier(getModifier())
        }
    }

    var viewForItem: (() -> PopupContent)? {
        if let item = item {
            return { itemView(item) }
        } else if let tempItemView {
            return { tempItemView }
        }
        return nil
    }

    /// 生成不同类型的弹窗
    private func getModifier() -> Popup<PopupContent> {
        Popup(
            params: params,
            view: viewForItem != nil ? viewForItem! : view,
            shouldShowContent: $shouldShowContent,
            showContent: showContent,
            isDragging: $isDragging,
            timeToHide: $timeToHide,
            positionIsCalculatedCallback: {
                // 关闭开始后，不允许重新计算位置触发再次显示弹窗
                if !closingIsInProcess {
                    DispatchQueue.main.async {
                        // 这将导致currentOffset改变，从而触发滑动显示动画
                        shouldShowContent = true
                        withAnimation(.linear(duration: 0.2)) {
                            animatableOpacity = 1 // 这将导致背景颜色/视图的交叉溶解动画
                        }
                        performWithDelay(0.3) {
                            eventsSemaphore.signal()
                        }
                    }
                    setupAutohide()
                }
            },
            dismissCallback: { source in
//                print("dismissCallback")
                
                dismissSource = source
                isPresented = false
                item = nil
                dismissPopup()
            }
        )
    }
    
    /// 配置自动延时关闭的程序
    func setupAutohide() {
        // if needed, dispatch autohide and cancel previous one
        if let autohideIn = autohideIn {
            autohidingWorkHolder.work?.cancel()

            // Weak reference to avoid the work item capturing the struct,
            // which would create a retain cycle with the work holder itself.

            // 自动结束提醒的方法
            autohidingWorkHolder.work = DispatchWorkItem(block: { [weak isPresentedRef, weak itemRef] in
                if isDragging {
                    timeToHide = true // raise this flag to hide the popup once the drag is over
                    return
                }
//                print("autohidingWorkHolder.work")
                
                dismissSource = .autohide
                isPresentedRef?.value.wrappedValue = false
                itemRef?.value.wrappedValue = nil
                autohidingWorkHolder.work = nil
                dismissPopup()
            })
            if popupPresented, let work = autohidingWorkHolder.work {
                DispatchQueue.main.asyncAfter(deadline: .now() + autohideIn, execute: work)
            }
        }
    }

    func appearAction(popupPresented: Bool) {
        if popupPresented {
//            print("开始 Popup")
            dismissSource = nil
            showSheet = true // show transparent fullscreen sheet
            showContent = true // immediately load popup body
            playHaptic()
        } else {
//            print("Popup 关闭")
            closingIsInProcess = true
            userWillDismissCallback(dismissSource ?? .binding)
            autohidingWorkHolder.work?.cancel()
            dismissibleInWorkHolder.work?.cancel()
            shouldShowContent = false // this will cause currentOffset change thus triggering the sliding hiding animation
            animatableOpacity = 0
            // 等待0.3秒让动画结束后再进行 deinit 的工作
            performWithDelay(0.3) {
                onAnimationCompleted()
            }
        }
    }
    
    func playHaptic() {
        if let haptic {
            switch haptic {
            case .success:
                SimpleHaptic.playSuccessHaptic()
            case .failure:
                SimpleHaptic.playFailureHaptic()
            }
        }
    }

    /// 配置动画结束之后的回调
    func onAnimationCompleted() {
//        print("pop 动画结束")
        showContent = false // unload popup body after hiding animation is done
        tempItemView = nil
        
        performWithDelay(0.01) {
            showSheet = false
            #if !os(watchOS)
            // 当显示弹窗时页面导航变化，.onChange 方法将不再响应
            // 检测到有显示的弹窗，则进行正常关闭
            if displayMode == .window {
                if WindowManager.shared.windows[id]?.isHidden == false {
                    WindowManager.closeWindow(id: id)
                }
            }
            #endif
        }
        if displayMode != .sheet { // for .sheet this callback is called in fullScreenCover's onDisappear
            userDismissCallback(dismissSource ?? .binding)
        }

        eventsSemaphore.signal()
    }

    func performWithDelay(_ delay: Double, block: @escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            block()
        }
    }
}
