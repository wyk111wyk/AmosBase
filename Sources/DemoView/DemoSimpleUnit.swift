//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2023/12/7.
//

import SwiftUI

public struct DemoSimpleUnit: View {
    
    let title: String
    public init(_ title: String = "Unit 单位转换") {
        self.title = title
    }
    
    @State private var length: Double = 1200
    @State private var storage: Double = 5120
    @State private var speed: Double = 170
    @State private var temperature: Double = 18.7
    @State private var duration: Double = 22000
    @State private var disDate: Date = Date().add(minute: 33, hour: 2)
    
    public var body: some View {
        Form {
            Section("长度 Length") {
                textCell(title: "长度", unit: "米", value: $length)
                SimpleCell(length.toLength())
                SimpleCell(length.toLength(style: .long))
                SimpleCell(length.toLength(outUnit: .centimeters))
                SimpleCell(length.toLength(outUnit: .feet))
                SimpleCell(length.toLength(locale: .zhHans))
            }
            Section("储存 Storage") {
                textCell(title: "储存", unit: "byte", value: $storage)
                SimpleCell(storage.toStorage())
                SimpleCell(storage.toStorage(outUnit: .megabits, degit: 4))
            }
            Section("速度 Speed") {
                textCell(title: "速度", unit: "米/秒", value: $speed)
                SimpleCell(speed.toSpeed())
                SimpleCell(speed.toSpeed(outUnit: .milesPerHour))
                SimpleCell(speed.toSpeed(outUnit: .milesPerHour, locale: .zhHans))
            }
            Section("温度 Temperature") {
                textCell(title: "温度", unit: "摄氏度", value: $temperature)
                SimpleCell(temperature.toTemperature())
                SimpleCell(temperature.toTemperature(withUnit: false))
                SimpleCell(temperature.toTemperature(outUnit: .fahrenheit))
                SimpleCell(temperature.toTemperature(outUnit: .kelvin))
            }
            Section("时间长度 Duration") {
                textCell(title: "时长", unit: "秒", value: $duration)
                SimpleCell(duration.toDuration())
                SimpleCell(duration.toDuration(units: [.second]))
                SimpleCell(duration.toDuration(style: .abbreviated))
                SimpleCell(duration.toDuration(locale: .zhHans))
                SimpleCell(duration.toDuration(style: .spellOut, locale: .zhHans))
                SimpleCell(disDate.toString_Relative(locale: .zhHans, timeStyle: .numeric))
            }
        }
        .navigationTitle(title)
    }
    
    func textCell(title: String, 
                  unit: String,
                  value: Binding<Double>) -> some View {
        SimpleCell(title, content: "单位：\(unit)") {
            TextField(title, value: value, format: .number)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    NavigationStack {
        DemoSimpleUnit()
    }
}
