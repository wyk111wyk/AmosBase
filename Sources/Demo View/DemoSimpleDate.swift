//
//  File.swift
//  
//
//  Created by AmosFitness on 2023/12/7.
//

import Foundation
import SwiftUI

public struct DemoSimpleDate: View {
    let title: String
    public init(_ title: String = "Date 日期") {
        self.title = title
    }
    
    let now = Date()
    
    public var body: some View {
        Form {
            Section("当前时间") {
                SimpleCell(now.toString_ISO8601())
            }
            Section("语义描述") {
                SimpleCell("时间差别(数字)", stateText: now.toString_Relative(
                    to: .now.add(hour: 5, day: 12, month: 1),
                    locale: .zhHans,
                    timeStyle: .numeric,
                    style: .full))
                SimpleCell("时间差别(文字)", stateText: now.toString_Relative(
                    to: .now.add(hour: 5, day: 12, month: 1),
                    locale: .zhHans,
                    timeStyle: .named,
                    style: .full))
                SimpleCell("时间差别(文字)", stateText: now.toString_Relative(
                    to: .now.add(day: 2),
                    locale: .zhHans,
                    timeStyle: .named,
                    style: .full,
                    context: .listItem))
            }
            Section("时间拆解") {
                SimpleCell("获取年份", stateText: now.getYear().toString())
                SimpleCell("获取月份", stateText: now.getMonth().toString())
                SimpleCell("获取天", stateText: now.getDay().toString())
                SimpleCell("获取小时", stateText: now.getHour().toString())
                SimpleCell("获取分钟", stateText: now.getMonth().toString())
                SimpleCell("获取星期几", stateText: now.getWeekday().toString())
                SimpleCell("是否今天", stateText: now.isToday().toString())
            }
            Section("转换为文字") {
                SimpleCell(now.toDateKey())
                SimpleCell(now.toString_Time())
                SimpleCell(now.toString_Date())
                SimpleCell(now.toString_DateTime())
                SimpleCell(now.toString_YearDate())
                SimpleCell(now.toString_YearDateTime())
                SimpleCell(now.toString_YearDateWeekTime())
                SimpleCell(now.toString_ISO8601())
            }
            Section("获取时间") {
                SimpleCell("今天初始", stateText: now.toStartOfDay().toString_DateTime())
                SimpleCell("本周初始", stateText: now.toStartOfWeek().toString_DateTime())
                SimpleCell("本月初始", stateText: now.toStartOfMonth().toString_DateTime())
                SimpleCell("季度初始", stateText: now.toStartOfQuarter().toString_DateTime())
                SimpleCell("今年初始", stateText: now.toStartOfYear().toString_DateTime())
            }
        }
        .navigationTitle(title)
    }
}

#Preview {
    NavigationView {
        DemoSimpleDate()
    }
#if canImport(UIKit)
    .navigationViewStyle(.stack)
#endif
}
