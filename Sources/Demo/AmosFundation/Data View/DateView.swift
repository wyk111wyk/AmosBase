//
//  DateArray.swift
//  AmosFundation
//
//  Created by AmosFitness on 2023/11/14.
//

import SwiftUI
import AmosBase

struct DateView: View {
    let title: String
    init(_ title: String = "Date") {
        self.title = title
    }
    
    let now = Date()
    
    var body: some View {
        Form {
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
                SimpleCell(now.toString_Distance())
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
    NavigationStack {
        DateView()
    }
}
