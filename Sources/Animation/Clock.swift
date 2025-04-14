//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/4/14.
//

import SwiftUI
import Combine

// MARK: - Data
class ClockHelper: ObservableObject {
    @Published var currentDate = Date()
    
    private var timer: AnyCancellable?
        
    init(interval: TimeInterval = 0.01) {
        timer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .assign(to: \.currentDate, on: self)
    }
}

// MARK: - View
struct Clock: View {
    @State private var adjustedDate: Date
    // 每次手势调节使用的临时时间
    @State private var setDate: Date? = nil
    let isAdjustable: Bool
    let setAction: (Date) -> Void
    
    let sizeLength: CGFloat
    
    let clockColor: Color
    let backgroundColor: Color
    let numberColor: Color
    
    let hourHandColor: Color
    let minuteHandColor: Color
    let secondHandColor: Color
    
    let showNumbers: Bool
    let showSecondHand: Bool
    
    let customDate: Date
    let timeZone: TimeZone
    
    
    init(
        customDate: Date = .now,
        isAdjustable: Bool = false,
        timeZone: TimeZone = .beijin,
        clockColor: Color = .primary,
        backgroundColor: Color = .clear,
        numberColor: Color = .primary,
        hourHandColor: Color = .primary.opacity(0.86),
        minuteHandColor: Color = .primary,
        secondHandColor: Color = .red,
        showNumbers: Bool = true,
        showSecondHand: Bool = true,
        sizeLength: CGFloat = 300,
        setAction: @escaping (Date) -> Void = {_ in}
    ) {
        self.clockColor = clockColor
        self.isAdjustable = isAdjustable
        self._adjustedDate = State(initialValue: customDate)
        self.backgroundColor = backgroundColor
        self.timeZone = timeZone
        self.hourHandColor = hourHandColor
        self.minuteHandColor = minuteHandColor
        self.secondHandColor = secondHandColor
        self.numberColor = numberColor
        self.customDate = customDate
        self.showNumbers = showNumbers
        self.showSecondHand = showSecondHand
        self.sizeLength = sizeLength
        self.setAction = setAction
    }
    
    // 提取调整后时间的组件
    private var timeComponents: DateComponents {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        let customDate = isAdjustable ? adjustedDate : customDate
        return calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: customDate)
    }

    // 计算秒、分、时，用于指针角度
    private var seconds: Double {
        let seconds = Double(timeComponents.second ?? 0)
        let nanoseconds = Double(timeComponents.nanosecond ?? 0) / 1_000_000_000
        return seconds + nanoseconds
    }

    private var minutes: Double {
        Double(timeComponents.minute ?? 0) + seconds / 60
    }

    private var hours: Double {
        let hour = Double(timeComponents.hour ?? 0) + minutes / 60
        return hour / 12
    }
    
    var body: some View {
        GeometryReader { geometry in
            let scale = min(geometry.size.width, geometry.size.height) / 300
            let lineWidth = 8 * scale
            let fontSize = 30 * scale
            let tickWidth = 2 * scale
            let majorTickHeight = 15 * scale
            let minorTickHeight = 7 * scale
            let secondHandWidth = 3 * scale
            let minuteHandWidth = 5 * scale
            let hourHandWidth = 7 * scale
            let centerCircleSize = 8 * scale
            let innerCircleSize = 4 * scale
            let numberPadding = 20 * scale
            let pixelsPerMinute: CGFloat = 3 * scale
            
            ZStack {
                // Outer circle
                Circle()
                    .foregroundStyle(backgroundColor)
                Circle()
                    .stroke(lineWidth: lineWidth)
                    .foregroundStyle(clockColor)
                
                // Ticks
                ForEach(0..<60) { tick in
                    VStack {
                        Rectangle()
                            .fill(.primary)
                            .opacity(1)
                            .frame(width: tickWidth, height: tick % 5 == 0 ? majorTickHeight : minorTickHeight)
                        Spacer()
                    }
                    .rotationEffect(.degrees(Double(tick)/60 * 360))
                    .foregroundStyle(clockColor)
                }
                
                // Numbers
                if showNumbers {
                    ForEach(1..<13) { tick in
                        VStack {
                            Text("\(tick)")
                                .font(.system(size: fontSize))
                                .rotationEffect(.degrees(-Double(tick)/12 * 360))
                            Spacer()
                        }
                        .rotationEffect(.degrees(Double(tick)/12 * 360))
                        .foregroundStyle(numberColor)
                    }
                    .padding(numberPadding)
                }
                
                // Hour hand
                ClockHand(
                    angleMultipler: hours,
                    scale: 0.5
                )
                .stroke(hourHandColor, style: .init(lineWidth: hourHandWidth, lineCap: .round))
                
                // Minute hand
                ClockHand(
                    angleMultipler: minutes / 60,
                    scale: 0.63
                )
                .stroke(minuteHandColor, style: .init(lineWidth: minuteHandWidth, lineCap: .round))
                
                // Second hand
                if showSecondHand {
                    ClockHand(
                        angleMultipler: seconds / 60,
                        scale: 0.79
                    )
                    .stroke(secondHandColor, style: .init(lineWidth: secondHandWidth, lineCap: .round))
                    .opacity(0.9)
                }
                
                // Center circle
                ZStack {
                    Circle()
                        .fill(.primary)
                        .frame(width: centerCircleSize, height: centerCircleSize)
                    Circle()
                        .fill(.background)
                        .frame(width: innerCircleSize, height: innerCircleSize)
                }
                .foregroundStyle(secondHandColor)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .contentShape(Circle())
            .gesture(setGesture(pixelsPerMinute))
            .allowsHitTesting(isAdjustable)
        }
        .frame(width: sizeLength, height: sizeLength)
        .animation(.linear(duration: 0.01), value: seconds)
        .onChange(of: customDate) {
            if !isAdjustable {
                adjustedDate = customDate
            }
        }
    }
    
    private func setGesture(_ pixelsPerMinute: CGFloat) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if setDate == nil {
                    setDate = adjustedDate
                }
                let currentLocation = value.translation
                // 计算增量：上/左（负值）减少分钟，下/右（正值）增加分钟
                let deltaY = currentLocation.height
                let deltaX = currentLocation.width
                // 合并垂直和水平位移，统一转换为分钟
                let deltaMinutes = (deltaY + deltaX) / pixelsPerMinute
                guard let newDate = Calendar.current.date(
                    byAdding: .minute,
                    value: Int(deltaMinutes.rounded()),
                    to: setDate!
                ) else { return }
                adjustedDate = newDate
                setAction(newDate)
            }
            .onEnded { _ in
                setDate = nil
            }
    }
}

struct ClockHand: Shape {
    let angleMultipler: CGFloat
    let scale: CGFloat
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let length = rect.width / 2
            let center = CGPoint(x: rect.midX, y: rect.midY)
            
            path.move(to: center)
            
            let angle = CGFloat.pi/2 - CGFloat.pi * 2 * angleMultipler
            
            path.addLine(to: CGPoint(
                x: rect.midX + cos(angle) * length * scale,
                y: rect.midY - sin(angle) * length * scale
            ))
        }
    }
}

struct ClockDemo: View {
    @ObservedObject var clockHelper = ClockHelper()
    @State private var isAdjustable: Bool = true
    @State private var adjustDate: Date = .now
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                if isAdjustable {
                    Text(adjustDate.toString(format: "hh:mm:ss:SSS")).monospaced()
                }else {
                    Text(clockHelper.currentDate.toString(format: "hh:mm:ss:SSS")).monospaced()
                }
                Toggle("是否可调", isOn: $isAdjustable)
                    .labelStyle()
                    .onChange(of: isAdjustable) {
                        if isAdjustable {
                            adjustDate = clockHelper.currentDate
                        }
                    }
            }
            clockView(timeZone: .beijin, length: 300, isAdjustable: isAdjustable)
            HStack(spacing: 20) {
                clockView(timeZone: .london, showNumbers: false, length: 200, isAdjustable: isAdjustable)
                clockView(timeZone: .newYork, showSecondHand: false, length: 100, isAdjustable: isAdjustable)
            }
        }
        .offset(y: -10)
    }
    
    private func clockView(
        timeZone: TimeZone,
        showNumbers: Bool = true,
        showSecondHand: Bool = true,
        length: CGFloat,
        isAdjustable: Bool = false
    ) -> some View {
        VStack(spacing: 15) {
            Clock(
                customDate: clockHelper.currentDate,
                isAdjustable: isAdjustable,
                timeZone: timeZone,
                showNumbers: showNumbers,
                showSecondHand: showSecondHand,
                sizeLength: length
            ) { newDate in
                self.adjustDate = newDate
            }
            Text(timeZone.identifier)
                .font(.callout)
        }
    }
}

#Preview {
    ClockDemo()
}
