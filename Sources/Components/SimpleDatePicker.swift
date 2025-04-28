//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/4/24.
//

import SwiftUI

public struct SimpleDatePicker: View {
    @Binding var selectedDate: Date
    public let title: LocalizedStringKey?
    
    public init(
        selectedDate: Binding<Date>,
        title: LocalizedStringKey? = nil
    ) {
        self._selectedDate = selectedDate
        self.title = title
    }
    
    public var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "clock")
                if let title {
                    Text(title)
                }
                Spacer()
                #if os(watchOS)
                Text(selectedDate.toString_Time())
                #else
                DatePicker("", selection: $selectedDate, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
                #endif
            }
            Divider()
            HStack {
                Clock(
                    customDate: $selectedDate,
                    isAdjustable: true,
                    showSecondHand: false,
                    sizeLength: 130
                )
                CustomTimePicker(date: $selectedDate)
            }
        }
    }
}

struct CustomTimePicker: View {
    // 绑定外部传入的 Date
    @Binding var date: Date
    let height: CGFloat
    
    init(
        date: Binding<Date>,
        height: CGFloat = 180
    ) {
        self._date = date
        self.height = height
    }
    
    // 可选择的小时和分钟范围
    let hours = Array(0...23)
    let minutes = stride(from: 0, to: 60, by: 5).map { $0 }
    
    // 从 Date 中提取小时和分钟
    private var hour: Int {
        get {
            Calendar.current.component(.hour, from: date)
        }
        set {
            updateDate(hour: newValue, minute: minute)
        }
    }
    
    private var minute: Int {
        get {
            Calendar.current.component(.minute, from: date)
        }
        set {
            updateDate(hour: hour, minute: newValue)
        }
    }
    
    // 更新 Date 的辅助方法
    private func updateDate(hour: Int, minute: Int) {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        components.hour = hour
        let adjustedMinute = (minute + 2) / 5 * 5
        components.minute = min(adjustedMinute, 55) // 确保不超过55
        if let newDate = calendar.date(from: components) {
            date = newDate
        }
    }
    
    var body: some View {
        HStack(spacing: -10) {
            // 小时 Picker
            Picker("", selection: Binding(
                get: { hour },
                set: { newHour in updateDate(hour: newHour, minute: minute) }
            )) {
                ForEach(hours, id: \.self) { hour in
                    Text(String(format: "%02d", hour))
                        .tag(hour)
                }
            }
            .frame(width: 85, height: height)
            .compositingGroup()
            .clipped()
            #if os(macOS)
            .pickerStyle(.menu)
            #else
            .pickerStyle(.wheel)
            #endif
            
            // 分钟 Picker
            Picker("", selection: Binding(
                get: { (minute + 2) / 5 * 5 },
                set: { newMinute in updateDate(hour: hour, minute: newMinute) }
            )) {
                ForEach(minutes, id: \.self) { minute in
                    Text(String(format: "%02d", minute))
                        .tag(minute)
                }
            }
            .frame(width: 85, height: height)
            .compositingGroup()
            .clipped()
            #if os(macOS)
            .pickerStyle(.menu)
            #else
            .pickerStyle(.wheel)
            #endif
        }
    }
}

#Preview {
    @Previewable @State var selectedDate: Date = .now
    Form {
        SimpleDatePicker(selectedDate: $selectedDate, title: nil)
    }
    .formStyle(.grouped)
}
