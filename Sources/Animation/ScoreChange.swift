//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/3/15.
//

import SwiftUI

// 点击后跳跃、升起文字的动画
public struct ScoreChangeAnimationConfig {
    let scaleEffect: CGFloat
    
    let maxPlusScale: CGFloat
    let minPlusScale: CGFloat
    let plusTextFont: Font
    let plusTextColor: Color
    let plusTextOffsetY: CGFloat
    let plusShowDuration: Double
    let plusHideDuration: Double
    
    public init(scaleEffect: CGFloat, maxPlusScale: CGFloat, minPlusScale: CGFloat, plusTextFont: Font, plusTextColor: Color, plusTextOffsetY: CGFloat, plusShowDuration: Double, plusHideDuration: Double) {
        self.scaleEffect = scaleEffect
        self.maxPlusScale = maxPlusScale
        self.minPlusScale = minPlusScale
        self.plusTextFont = plusTextFont
        self.plusTextColor = plusTextColor
        self.plusTextOffsetY = plusTextOffsetY
        self.plusShowDuration = plusShowDuration
        self.plusHideDuration = plusHideDuration
    }
    
    public static var defaultConfig: ScoreChangeAnimationConfig {
        .init(
            scaleEffect: 1.3,
            maxPlusScale: 1.0,
            minPlusScale: 0.8,
            plusTextFont: .title,
            plusTextColor: .blue,
            plusTextOffsetY: -36,
            plusShowDuration: 0.07,
            plusHideDuration: 0.5
        )
    }
    
    /// 时间志2 计数任务动画参数
    public static func timeCountConfig(plusColor: Color) -> ScoreChangeAnimationConfig {
        ScoreChangeAnimationConfig(
            scaleEffect: 1.3,
            maxPlusScale: 1.1,
            minPlusScale: 0.8,
            plusTextFont: .body,
            plusTextColor: plusColor,
            plusTextOffsetY: -25,
            plusShowDuration: 0.07,
            plusHideDuration: 0.5
        )
    }
}

struct ScoreChangeModifier: ViewModifier {
    let currentScore: Int
    let config: ScoreChangeAnimationConfig
    
    @State private var oldScore: Int?
    @State private var isBounce = false
    @State private var showPlusOne = false
    
    init(
        currentScore: Int,
        config: ScoreChangeAnimationConfig
    ) {
        self.currentScore = currentScore
        self.config = config
    }
    
    // 计算增减的数量并显示
    var gapScore: Int {
        currentScore - (oldScore ?? 0)
    }
    
    var plusText: String {
        if gapScore >= 0 {
            return "+\(gapScore)"
        }else {
            return "-\(abs(gapScore))"
        }
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(isBounce ? config.scaleEffect : 1.0)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.3),
                value: isBounce
            )
            .onChange(of: currentScore) {
                withAnimation {
                    showPlusOne = true
                    isBounce = true
                }
                Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false, block: { _ in
                    withAnimation {
                        isBounce = false
                    }
                })
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
                    withAnimation {
                        showPlusOne = false
                    }
                })
                Timer.scheduledTimer(withTimeInterval: (0.5 + config.plusHideDuration), repeats: false, block: { _ in
                    withAnimation {
                        oldScore = currentScore
                    }
                })
            }
            .overlay(alignment: .top) {
                if gapScore != 0 {
                    Text(plusText)
                        .font(config.plusTextFont)
                        .foregroundColor(config.plusTextColor)
                        .frame(minWidth: 36, minHeight: 30)
                        .minimumScaleFactor(0.8)
                        .offset(y: showPlusOne ? config.plusTextOffsetY : 0)
                        .opacity(showPlusOne ? 1 : 0)
                        .scaleEffect(showPlusOne ? config.maxPlusScale : config.minPlusScale)
                        .animation(showPlusOne ? .easeIn(duration: config.plusShowDuration) : .easeInOut(duration: config.plusHideDuration), value: showPlusOne)
                }
            }
            .onAppear {
                if oldScore == nil {
                    oldScore = currentScore
                }
            }
    }
}

public extension View {
    func scoreChangeAnimation(
        currentScore: Int,
        config: ScoreChangeAnimationConfig = .defaultConfig
    ) -> some View {
        self.modifier(
            ScoreChangeModifier(
                currentScore: currentScore,
                config: config
            )
        )
    }
}

// MARK: - 预览画面
struct ContentView: View {
    @State private var score = 10

    var body: some View {
        VStack(spacing: 20) {
            Text("Score: \(score)")
                .simpleTag(.bg(contentFont: .body))
                .scoreChangeAnimation(
                    currentScore: score
                )
                .padding(.top, 30)

            Button("点击增加数字") {
                score += Int.random(in: 2...10)
            }
            .buttonStyle(.bordered)
        }
    }
}

#Preview {
    ContentView()
}
