//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/3/14.
//

import SwiftUI

public struct DemoSimpleHaptic: View {
    @Environment(\.dismiss) private var dismissPage
    @State private var isContinuePressing = false
    @State private var isIncreasePressing = false
    
    @State private var hapticIntensity: Float = 0.3
    @State private var hapticSharpness: Float = 0.3
    
    @State private var minIntensity: Float = 0.2
    @State private var maxIntensity: Float = 0.8
    @State private var hapticDuration: TimeInterval = 2
    
    let title: String
    let haptic: SimpleHaptic = .shared
    public init(_ title: String = "Haptic 震动") {
        self.title = title
    }
    
    public var body: some View {
        Form {
            continueSection()
            increasingSection()
            hapticSection()
        }
        .navigationTitle(title)
        .formStyle(.grouped)
    }
    
    private func continueSection() -> some View {
        Section("连续震动") {
            SimpleDetectButton(holdAction: { isPressing in
                self.isContinuePressing = isPressing
                if isPressing {
                    haptic.playContinuousHaptic(
                        intensity: hapticIntensity,
                        sharpness: hapticSharpness
                    )
                }else {
                    haptic.stopHaptic()
                }
            }) {
                HStack {
                    Image(systemName: "iphone.gen3.radiowaves.left.and.right")
                        .bounceEffect(isActive: isContinuePressing)
                    Text("Haptic - 长按连续震动")
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            
            HStack(spacing: 8) {
                Text("强度: \(hapticIntensity.toString(digit: 1))")
                    .font(.callout)
                Slider(value: $hapticIntensity, in: 0...1, step: 0.1)
            }
            HStack(spacing: 8) {
                Text("锐度: \(hapticSharpness.toString(digit: 1))")
                    .font(.callout)
                Slider(value: $hapticSharpness, in: 0...1, step: 0.1)
            }
        }
    }
    
    private func increasingSection() -> some View {
        Section("渐强震动") {
            SimpleDetectButton(holdAction: { isPressing in
                self.isIncreasePressing = isPressing
                if isPressing {
                    haptic.playIncreasingHaptic(
                        minIntensity: minIntensity,
                        maxIntensity: maxIntensity,
                        duration: hapticDuration
                    )
                }else {
                    haptic.stopHaptic()
                }
            }) {
                HStack {
                    Image(systemName: "iphone.gen3.radiowaves.left.and.right")
                        .bounceEffect(isActive: isIncreasePressing)
                    Text("Haptic - 长按渐强震动")
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            
            HStack(spacing: 8) {
                Text("初始强度: \(minIntensity.toString(digit: 1))")
                    .font(.callout)
                Slider(value: $minIntensity, in: 0...1, step: 0.1)
            }
            HStack(spacing: 8) {
                Text("最大强度: \(maxIntensity.toString(digit: 1))")
                    .font(.callout)
                Slider(value: $maxIntensity, in: 0...1, step: 0.1)
            }
            HStack(spacing: 8) {
                Text("持续时间: \(hapticDuration.toString(digit: 1))")
                    .font(.callout)
                Slider(value: $hapticDuration, in: 0...8, step: 0.1)
            }
        }
    }
    
    @ViewBuilder
    private func hapticSection() -> some View {
        #if os(iOS)
        Section("单次震动") {
            Button {
                SimpleHaptic.playNotificationHaptic(.success)
            } label: {
                SimpleCell("Haptic震动 - ✅ 成功", systemImage: "iphone.gen3.radiowaves.left.and.right")
            }
            Button {
                SimpleHaptic.playNotificationHaptic(.error)
            } label: {
                SimpleCell("Haptic震动 - ❎ 错误", systemImage: "iphone.gen3.radiowaves.left.and.right")
            }
            Button {
                SimpleHaptic.playNotificationHaptic(.warning)
            } label: {
                SimpleCell("Haptic震动 - ⚠️ 警告", systemImage: "iphone.gen3.radiowaves.left.and.right")
            }
            Button {
                SimpleHaptic.playFeedbackHaptic(.heavy)
            } label: {
                SimpleCell("Haptic震动 - 强烈", systemImage: "iphone.radiowaves.left.and.right.circle.fill")
            }
            Button {
                SimpleHaptic.playFeedbackHaptic(.rigid)
            } label: {
                SimpleCell("Haptic震动 - 较强", systemImage: "iphone.radiowaves.left.and.right.circle.fill")
            }
            Button {
                SimpleHaptic.playFeedbackHaptic(.medium)
            } label: {
                SimpleCell("Haptic震动 - 普通", systemImage: "iphone.radiowaves.left.and.right.circle.fill")
            }
            Button {
                SimpleHaptic.playFeedbackHaptic(.soft)
            } label: {
                SimpleCell("Haptic震动 - 柔软", systemImage: "iphone.radiowaves.left.and.right.circle.fill")
            }
            Button {
                SimpleHaptic.playFeedbackHaptic(.light)
            } label: {
                SimpleCell("Haptic震动 - 轻柔", systemImage: "iphone.radiowaves.left.and.right.circle.fill")
            }
        }
        #elseif os(watchOS)
        Section("设备操作") {
            Button {
                SimpleHaptic.playWatchHaptic(.success)
            } label: {
                SimpleCell("Haptic震动 - ✅ 成功", systemImage: "iphone.gen3.radiowaves.left.and.right")
            }
            Button {
                SimpleHaptic.playWatchHaptic(.failure)
            } label: {
                SimpleCell("Haptic震动 - ❎ 错误", systemImage: "iphone.gen3.radiowaves.left.and.right")
            }
            Button {
                SimpleHaptic.playWatchHaptic(.notification)
            } label: {
                SimpleCell("Haptic震动 - ⚠️ 警告", systemImage: "iphone.gen3.radiowaves.left.and.right")
            }
            Button {
                SimpleHaptic.playWatchHaptic(.directionUp)
            } label: {
                SimpleCell("Haptic震动 - ⬆️ 增加", systemImage: "iphone.gen3.radiowaves.left.and.right")
            }
            Button {
                SimpleHaptic.playWatchHaptic(.directionDown)
            } label: {
                SimpleCell("Haptic震动 - ⬇️ 减少", systemImage: "iphone.gen3.radiowaves.left.and.right")
            }
            Button {
                SimpleHaptic.playWatchHaptic(.retry)
            } label: {
                SimpleCell("Haptic震动 - 🔁 重试", systemImage: "iphone.gen3.radiowaves.left.and.right")
            }
            Button {
                SimpleHaptic.playWatchHaptic(.start)
            } label: {
                SimpleCell("Haptic震动 - ▶️ 开始", systemImage: "iphone.gen3.radiowaves.left.and.right")
            }
            Button {
                SimpleHaptic.playWatchHaptic(.stop)
            } label: {
                SimpleCell("Haptic震动 - 🛑 停止", systemImage: "iphone.gen3.radiowaves.left.and.right")
            }
        }
        #endif
    }
}

#Preview {
    NavigationStack {
        DemoSimpleHaptic()
    }
}
