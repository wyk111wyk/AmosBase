//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/6/7.
//

import Foundation
import SwiftUI

public extension ProgressView {
    /// 圆形进度条
    ///
    /// - Parameter height: 视图的高度（必填）
    /// - Parameter barHeight: 线宽（nil 则自动计算）
    /// - Parameter hasGradient: 根据主题颜色自动计算渐变色
    /// - Parameter showText: 在中央显示百分比
    /// - Parameter startPoint: 起始点 - 上、下、左、右
    func circularStyle(
        height: CGFloat,
        lineWidth: CGFloat? = nil,
        color: Color = .blue,
        backgroundColor: Color? = nil,
        textColor: Color = .primary,
        hasGradient: Bool = true,
        textType: SimpleSlider.TextType = .percent,
        startPoint: CircularProgressStyle.StartPoint = .top
    ) -> some View {
        self.progressViewStyle(
            CircularProgressStyle(
                height: height,
                lineWidth: lineWidth,
                color: color,
                backgroundColor: backgroundColor,
                textColor: textColor,
                hasGradient: hasGradient,
                textType: textType,
                startPoint: startPoint
            )
        )
    }
    
    /// 条形进度条
    ///
    /// - Parameter barHeight: 进度条的高度
    /// - Parameter hasGradient: 根据主题颜色自动计算渐变色
    /// - Parameter textType: 显示文字的类型
    func barStyle(
        barHeight: CGFloat = 38,
        cornerScale: CGFloat = 4,
        color: Color = .blue,
        backgroundColor: Color? = nil,
        textColor: Color = .primary,
        hasGradient: Bool = true,
        textType: SimpleSlider.TextType = .percent
    ) -> some View {
        self.progressViewStyle(
            BarProgressStyle(
                barHeight: barHeight,
                cornerScale: cornerScale,
                color: color,
                backgroundColor: backgroundColor,
                textColor: textColor,
                hasGradient: hasGradient,
                textType: textType
            )
        )
    }
}

public struct BarProgressStyle: ProgressViewStyle {
    let barHeight: CGFloat
    let cornerScale: CGFloat
    let color: Color
    let backgroundColor: Color
    let textColor: Color
    let hasGradient: Bool
    
    let textType: SimpleSlider.TextType
    
    public init(
        barHeight: CGFloat = 38,
        cornerScale: CGFloat = 4,
        color: Color = .accentColor,
        backgroundColor: Color? = nil,
        textColor: Color = .primary,
        hasGradient: Bool = true,
        textType: SimpleSlider.TextType = .percent
    ) {
        self.barHeight = barHeight
        self.cornerScale = cornerScale
        self.color = color
        if let backgroundColor {
            self.backgroundColor = backgroundColor
        }else {
            self.backgroundColor = color.opacity(0.12)
        }
        self.textColor = textColor
        self.hasGradient = hasGradient
        self.textType = textType
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        let currentValue = configuration.fractionCompleted ?? 0
        SimpleSlider(value: .constant(currentValue),
                     range: 0...1,
                     barHeight: barHeight,
                     cornerScale: cornerScale,
                     color: color,
                     backgroundColor: backgroundColor,
                     textColor: textColor,
                     hasGradient: hasGradient,
                     textType: textType,
                     isDragable: false)
    }
}

public struct CircularProgressStyle: ProgressViewStyle {
    public enum StartPoint {
        case top, bottom, leading, trailing
        var degress: CGFloat {
            switch self {
            case .top: 270
            case .bottom: 90
            case .leading: 180
            case .trailing: 0
            }
        }
    }
    
    let height: CGFloat
    let lineWidth: CGFloat?
    
    let color: Color
    let backgroundColor: Color
    let hasGradient: Bool
    let textColor: Color
    
    let textType: SimpleSlider.TextType
    let hasDoneMark: Bool
    let startPoint: StartPoint
    
    public init(
        height: CGFloat,
        lineWidth: CGFloat? = nil,
        color: Color = .accentColor,
        backgroundColor: Color? = nil,
        textColor: Color,
        hasGradient: Bool = true,
        textType: SimpleSlider.TextType = .percent,
        hasDoneMark: Bool = true,
        startPoint: StartPoint = .top
    ) {
        self.height = height
        self.lineWidth = lineWidth
        self.color = color
        if let backgroundColor {
            self.backgroundColor = backgroundColor
        }else {
            self.backgroundColor = color.opacity(0.26)
        }
        self.textColor = textColor
        self.hasGradient = hasGradient
        self.textType = textType
        self.hasDoneMark = hasDoneMark
        self.startPoint = startPoint
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let totalHeight = geometry.size.height
            let radius = min(totalWidth, totalHeight) / 2
            let lineWidth_ =
            if let lineWidth { lineWidth }
            else { min(radius / 4.8, 22) }
            let fontSize = min(radius / 2.2, 36)
            let currentValue = configuration.fractionCompleted ?? 0
            // 文字内容
            let textContent: String = textType.content(
                percent: currentValue,
                value: currentValue,
                fontSize: fontSize
            )
            let gradientColor: AngularGradient =
            if hasGradient {
                AngularGradient(
                    colors: [color.opacity(0.3), color.darken(by: 0.13)],
                    center: .center,
                    startAngle: .degrees(startPoint.degress+90),
                    endAngle: .degrees(startPoint.degress+90 + currentValue * 360)
                )
            }else {
                AngularGradient(colors: [color], center: .center)
            }
            
            ZStack {
                // Background Circle
                Circle()
                    .stroke(lineWidth: lineWidth_)
                    .foregroundStyle(backgroundColor)
                
                // Foreground Circle (Progress)
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(currentValue, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: lineWidth_,
                                               lineCap: .round,
                                               lineJoin: .round))
                    .foregroundStyle(gradientColor)
                    .rotationEffect(Angle(degrees: startPoint.degress))
                    .animation(.linear, value: configuration.fractionCompleted)
                
                // Progress Text
                if currentValue == 1 && hasDoneMark {
                    Image(systemName: "checkmark")
                        .font(.system(size: fontSize * 2.1, weight: .bold))
                        .foregroundStyle(color)
                }else if textContent.isNotEmpty {
                    Text(textContent)
                        .font(.system(size: fontSize, weight: .bold))
                        .lineLimit(1)
                        .foregroundStyle(textColor)
                }
            }
            .padding(radius/8)
        }
        .frame(width: height, height: height)
    }
}

#Preview("Progress") {
    ScrollView {
        VStack {
            Text("Circular Progress")
                .font(.title)
            HStack(spacing: 30) {
                ProgressView(value: 70, total: 100)
                    .circularStyle(
                        height: 160,
                        color: .green,
                        hasGradient: true,
                        startPoint: .top
                    )
                ProgressView(value: 100, total: 100)
                    .circularStyle(
                        height: 110,
                        color: .red,
                        hasGradient: false,
                        textType: .value,
                        startPoint: .top
                    )
                ProgressView(value: 100, total: 100)
                    .circularStyle(
                        height: 18,
                        color: .red,
                        hasGradient: false,
                        textType: .none,
                        startPoint: .top
                    )
            }
        }
        VStack {
            Text("Bar Progress")
                .font(.title)
            ProgressView(value: 1, total: 100)
                .barStyle()
            ProgressView(value: 10, total: 100)
                .barStyle()
            ProgressView(value: 20, total: 100)
                .barStyle()
            ProgressView(value: 60, total: 100)
                .barStyle()
            ProgressView(value: 100, total: 100)
                .barStyle()
            ProgressView(value: 0, total: 100)
                .barStyle(textType: .custom(msg: "Icon Man"))
            ProgressView(value: 100, total: 100)
                .barStyle(textType: .custom(msg: "Icon Man"))
            ProgressView(value: 80, total: 100)
                .barStyle(barHeight: 20)
        }
        .padding(.horizontal)
    }
    .padding()
    #if os(macOS)
    .frame(height: 800)
    #endif
}
