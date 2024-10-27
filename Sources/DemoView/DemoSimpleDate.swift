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
    
    @State private var theDate = Date()
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("当前时间") {
#if os(watchOS)
                    SimpleCell("时间") {
                        Text(theDate, style: .date)
                    }
#else
                    DatePicker(selection: $theDate) {
                        Text("选择时间")
                    }
#endif
                }
                Section("语义描述 - .toString_Relative") {
                    SimpleCell("时间差别(数字)", content: "1月12天5小时 - numeric", stateText: theDate.toString_Relative(
                        to: theDate.add(hour: 5, day: 12, month: 1),
                        locale: .zhHans,
                        timeStyle: .numeric,
                        style: .full))
                    SimpleCell("时间差别(文字)", content: "1月12天5小时 - named", stateText: theDate.toString_Relative(
                        to: theDate.add(hour: 5, day: 12, month: 1),
                        locale: .zhHans,
                        timeStyle: .named,
                        style: .full))
                    SimpleCell("时间差别(文字)", content: "2天 - named", stateText: theDate.toString_Relative(
                        to: theDate.add(day: 2),
                        locale: .zhHans,
                        timeStyle: .named,
                        style: .full,
                        context: .listItem))
                }
                Section("时间对比") {
                    SimpleCell("是否经过10秒", stateText: theDate.hasPassed(second: 10).toString())
                    SimpleCell("是否不到10秒", stateText: theDate.notPassed(second: 10).toString())
                    SimpleCell("天数差别", stateText: theDate.add(day: 3).distance().toString().addSubfix("天"))
                    SimpleCell("月数差别", stateText: theDate.add(day: 3, month: 1).distance(component: .month).toString().addSubfix("月"))
                }
                Section("时间拆解") {
                    SimpleCell("获取年份", stateText: theDate.getYear().toString())
                    SimpleCell("获取月份", stateText: theDate.getMonth().toString().addSubfix("月"))
                    SimpleCell("获取天", stateText: theDate.getDay().toString().addSubfix("日"))
                    SimpleCell("获取小时", stateText: theDate.getHour().toString().addSubfix("时"))
                    SimpleCell("获取分钟", stateText: theDate.getMonth().toString().addSubfix("分"))
                    SimpleCell("获取星期几", content: "1-周日 7-周六", stateText: theDate.getWeekday().toString())
                    SimpleCell("是否今天", stateText: theDate.isToday().toString())
                }
                Section("转换为文字") {
                    SimpleCell(theDate.toDateKey(), content: "YYYY-MM-dd")
                    SimpleCell(theDate.toString_Time(), content: "H:mm")
                    SimpleCell(theDate.toString_Date(), content: ".dateTime.month().day()")
                    SimpleCell(theDate.toString_DateTime(), content: ".month().day().hour().minute()")
                    SimpleCell(theDate.toString_YearDate(), content: ".year().month().day()")
                    SimpleCell(theDate.toString_YearDateTime(), content: ".year().month().day().hour().minute()")
                    SimpleCell(theDate.toString_YearDateWeekTime(), content: ".month().day().hour().minute().weekday()")
                    SimpleCell(theDate.toString_ISO8601(), content: "ISO8601Format")
                }
                Section("获取时间") {
                    SimpleCell("今天初始", stateText: theDate.toStartOfDay().toString_DateTime())
                    SimpleCell("本周初始", stateText: theDate.toStartOfWeek().toString_DateTime())
                    SimpleCell("本月初始", stateText: theDate.toStartOfMonth().toString_DateTime())
                    SimpleCell("季度初始", stateText: theDate.toStartOfQuarter().toString_DateTime())
                    SimpleCell("今年初始", stateText: theDate.toStartOfYear().toString_DateTime())
                }
            }
            .formStyle(.grouped)
            .navigationTitle(title)
        }
    }
}

#Preview {
    DemoSimpleDate()
}
