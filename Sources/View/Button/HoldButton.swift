//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/3/14.
//

import SwiftUI

public struct SimpleHoldButton<V: View>: View {
    @State private var progress: CGFloat = 0 // 当前进度，范围 0-1
    @State private var isPressing: Bool = false // 是否正在按住
    @State private var isCompleted: Bool = false // 是否完成

    let haptic: SimpleHaptic = .shared
    
    let isDisabled: Bool
    
    let duration: Double // 进度条完成所需时间
    let dismissDuration: Double // 进度条消失所需时间
    
    let coverColor: Color // 进度条覆盖的颜色
    let coverRadius: CGFloat // 进度条覆盖的圆角
    
    let isHaptic: Bool
    let minIntensity: Float
    let maxIntensity: Float
    let sharpness: Float
    
    @ViewBuilder let buttonView: () -> V
    let onPressingChanged: (Bool) -> Void
    let onCompletion: () -> Void // 完成时的回调

    public init(
        isDisabled: Bool = false,
        duration: Double = 1.0,
        dismissDuration: Double = 0.3,
        coverColor: Color = .white.opacity(0.5),
        coverRadius: CGFloat = 10,
        isHaptic: Bool = true,
        minIntensity: Float = 0.3,
        maxIntensity: Float = 0.9,
        sharpness: Float = 0.3,
        @ViewBuilder buttonView: @escaping () -> V,
        onPressingChanged: @escaping (Bool) -> Void = { _ in },
        onCompletion: @escaping () -> Void = {}
    ) {
        self.isDisabled = isDisabled
        self.duration = duration
        self.dismissDuration = dismissDuration
        self.coverColor = coverColor
        self.coverRadius = coverRadius
        self.isHaptic = isHaptic
        self.minIntensity = minIntensity
        self.maxIntensity = maxIntensity
        self.sharpness = sharpness
        self.buttonView = buttonView
        self.onPressingChanged = onPressingChanged
        self.onCompletion = onCompletion
    }
    
    var floatingAnimation: Animation {
        if progress == 1 {
            return Animation.linear(duration: duration)
        }else {
            return Animation.easeOut(duration: dismissDuration)
        }
    }
    
    var opacityAnimation: Animation? {
        if isCompleted {
            return Animation.easeOut(duration: 0.2)
        }else {
            return nil
        }
    }

    public var body: some View {
        // 按钮
        buttonView()
            .overlay(alignment: .leading) {
                GeometryReader { geometry in
                    // 半透明进度条覆盖
                    RoundedRectangle(cornerRadius: coverRadius)
                        .fill(coverColor)
                        .frame(
                            width: geometry.size.width * progress,
                            height: geometry.size.height
                        )
                        .opacity(isCompleted ? 0 : 1)
                        .animation(floatingAnimation, value: progress)
                        .animation(opacityAnimation, value: isCompleted)
                }
            }
            .contentShape(Rectangle())
            .onLongPressGesture(minimumDuration: duration, perform: {
                guard !isDisabled else { return }
                
                isCompleted = true
                if isHaptic {
                    haptic.stopHaptic()
                }
                onCompletion()
            }, onPressingChanged: { isPressing in
                guard !isDisabled else { return }
                
                self.isPressing = isPressing
                onPressingChanged(isPressing)
//                print("isPressing: \(isPressing)")
            })
            .onChange(of: isPressing) {
                // 手势状态改变时更新进度
                if isPressing {
                    isCompleted = false
                    progress = 1.0
                    if isHaptic {
                        haptic.playIncreasingHaptic(
                            minIntensity: minIntensity,
                            maxIntensity: maxIntensity,
                            sharpness: sharpness,
                            duration: duration
                        )
                    }
                }else {
                    progress = 0.0
                    if isHaptic {
                        haptic.stopHaptic()
                    }
                    if isCompleted {
                        Timer.scheduledTimer(withTimeInterval: dismissDuration * 1.5, repeats: false) { _ in
                            isCompleted = false
                        }
                    }
                }
        }
    }
}

#Preview {
    @Previewable @State var buttonColor: Color = .blue
    SimpleHoldButton(
        isDisabled: true,
        buttonView: {
            Text("按住")
                .foregroundColor(.white)
                .font(.headline)
                .frame(maxWidth: .infinity) // 确保文字居中
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(buttonColor)
                        .frame(width: 200, height: 50)
                }
                .frame(width: 200, height: 50)
        }, onPressingChanged: { isPressing in
            buttonColor = isPressing ? .red : .blue
        }, onCompletion: {
            print("完成")
        })
}
