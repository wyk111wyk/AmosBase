//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2024/6/7.
//

import SwiftUI

public struct SimpleSlider: View {
    public enum TextType: Equatable {
        case none, percent, value, custom(msg: String)
        
        func content(
            percent: CGFloat,
            value: CGFloat,
            fontSize: CGFloat
        ) -> String {
            let textContent: String =
            if self == .none || fontSize < 9 { "" }
            else if self == .percent { String(format: "%.0f %%",
                                             min(percent, 1.0)*100.0) }
            else if case let .custom(msg) = self { msg }
            else if self == .value { value.toString(digit: 1) }
            else { "" }
            return textContent
        }
    }
    
//    @State private var value: CGFloat
    @Binding var value: CGFloat
    let range: ClosedRange<CGFloat>
    let ratio: CGFloat
    
    let lineWidth: CGFloat
    let color: Color
    let backgroundColor: Color
    let textColor: Color
    let hasGradient: Bool
    
    let textType: TextType
    @State private var isGragging: Bool = false
    let isDragable: Bool
    
    public init(
        value: Binding<CGFloat>,
        range: ClosedRange<CGFloat> = 0...100,
        lineWidth: CGFloat = 38,
        color: Color = .accentColor,
        backgroundColor: Color? = nil,
        textColor: Color = .primary,
        hasGradient: Bool = true,
        textType: TextType = .percent,
        isDragable: Bool = true
    ) {
        // 数据
        self._value = value
//        self._value = State(initialValue: value.wrappedValue)
        self.range = range
        let totalValue = range.upperBound - range.lowerBound
        self.ratio = 100 / totalValue
        
        self.lineWidth = lineWidth
        self.color = color
        if let backgroundColor {
            self.backgroundColor = backgroundColor
        }else {
            self.backgroundColor = color.opacity(0.12)
        }
        self.textColor = textColor
        self.hasGradient = hasGradient
        self.textType = textType
        self.isDragable =
        if lineWidth > 10 { isDragable }
        else { false }
    }
    
    public var body: some View {
        // 0 - 1 之间的系数值
        let currentValue = Binding<CGFloat>(
            get: {
                if value < range.lowerBound { return 0 }
                else if value > range.upperBound { return 1 }
                else {
                    let temp = (value - range.lowerBound) * ratio / 100
                    return temp
                }
            }, set: {
                let temp = range.lowerBound + ($0 / ratio)
                debugPrint("新的值: \(temp)")
                value = temp
            })
        GeometryReader { geometry in
            // 进度条尺寸
            let totalWidth = geometry.size.width
            let fontSize = lineWidth / 2.2
            let cornerRadius = lineWidth / 4
            let textWidth = fontSize * 5
            // 文字内容
            let textContent: String = textType.content(
                percent: currentValue.wrappedValue,
                value: value,
                fontSize: fontSize
            )
            // 文字位置
            let blankWidth = totalWidth * (1 - currentValue.wrappedValue)
            let isTextFront: Bool = blankWidth > textWidth
            let offsetX: CGFloat =
            if isTextFront { totalWidth * currentValue.wrappedValue + 8 }
            else { totalWidth * currentValue.wrappedValue - 8 - textWidth }
            // 文字颜色
            let textColor_: Color =
            if isTextFront { textColor }
            else if hasGradient { color.darken(by: 0.13).textColor }
            else { color.textColor }
            // 进度条颜色
            let gradientColor: LinearGradient =
            if hasGradient {
                LinearGradient(
                    colors: [color.opacity(0.5), color.darken(by: 0.13)],
                    startPoint: .leading, endPoint: .trailing)
            }else {
                LinearGradient(colors: [color], startPoint: .leading, endPoint: .trailing)
            }
            
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundStyle(backgroundColor)
                    .frame(width: .infinity, height: lineWidth)
                
                // Bar Progress
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundStyle(gradientColor)
                    .frame(width: totalWidth * currentValue.wrappedValue,
                           height: lineWidth)
                    
                if textContent.isNotEmpty {
                    Text(textContent)
                        .lineLimit(1)
                        .frame(width: textWidth, alignment: isTextFront ? .leading : .trailing)
                        .font(.system(size: fontSize, weight: .bold))
                        .foregroundStyle(textColor_)
                        .offset(x: offsetX)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ dragValue in
                        isGragging = true
                        let start: Int = (dragValue.location.x / totalWidth * 100).toInt
                        if start >= 0, start <= 100, isDragable {
                            debugPrint("目前进度：\(start)%")
                            withAnimation {
                                currentValue.wrappedValue = CGFloat(start)
                            }
                        }
                    })
                    .onEnded({ endValue in
                        isGragging = false
                        let end: Int = (endValue.location.x / totalWidth * 100).toInt
                        if end >= 0, end <= 100, isDragable {
                            debugPrint("结束进度: \(end)%")
                        }
                    })
            )
        }
        .frame(height: lineWidth)
    }
}

public struct SimpleStarSlider: View {
    /// 范围：1 - 5
    @Binding var currentRating: Int
    
    let systemIcon: String?
    let title: String?
    let state: String?
    let tagConfig: SimpleTagConfig
    public init(
        currentRating: Binding<Int>,
        systemIcon: String? = nil,
        title: String? = nil,
        state: String? = nil,
        tagConfig: SimpleTagConfig = .border()
    ) {
        self._currentRating = currentRating
        self.systemIcon = systemIcon
        self.title = title
        self.state = state
        self.tagConfig = tagConfig
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 4) {
                if let systemIcon {
                    Image(systemName: systemIcon)
                }
                if let title {
                    Text(title)
                        .foregroundStyle(.secondary)
                        .font(.callout)
                }
            }
            
            if systemIcon != nil || title != nil {
                RoundedRectangle(cornerRadius: 1)
                    .frame(width: 1, height:  16)
                    .foregroundStyle(.secondary)
                    .opacity(0.4)
            }
            
            HStack(spacing: 12) {
                ForEach(1...5) { rate in
                    starButton(rate: rate,
                               isSelected: rate <= currentRating)
                }
            }
            Spacer()
            
            if let state {
                Text(state)
                    .simpleTagBorder(tagConfig)
            }
        }
    }
    
    private func starButton(rate: Int, isSelected: Bool) -> some View {
        Button {
            withAnimation {
                currentRating = rate
            }
        } label: {
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(isSelected ? .yellow : .secondary)
                .opacity(isSelected ? 1 : 0.3)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 20) {
        SimpleSlider(value: .constant(90),
                     range: 20...170)
        SimpleSlider(value: .constant(90),
                     range: 20...170,
                     textType: .value)
        SimpleStarSlider(
            currentRating: .constant(2),
            systemIcon: "moon.stars.fill",
            title: "经验",
            state: "Nice"
        )
    }
        .padding()
}
