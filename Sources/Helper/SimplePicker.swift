//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2024/4/4.
//

import SwiftUI

public protocol PickerValueModel: Identifiable, Hashable {
    var title: String { get }
    var iconName: String? { get }
    var systemImage: String? { get }
    var contentSystemImage: String? { get }
    var content: String? { get }
}

//@available(iOS 16, macOS 13, watchOS 9, *)
public struct SimplePicker<Value: PickerValueModel>: View {
    @Environment(\.dismiss) private var dismissPage
    // Picker属性
    let title: String
    let maxSelectCount: Int
    let themeColor: Color
    let dismissAfterTap: Bool // 点击就退出
    let isPushin: Bool // 是否使用费Link进入
    // 选择范围
    let allValue: [Value]
    // 已选的值
    @State private var selectValues: Set<Value>
    // 保存值的回调（并不直接保存结果）
    let singleSaveAction: (Value) -> Void
    let multipleSaveAction: (Set<Value>) -> Void
    
    public init(title: String,
                maxSelectCount: Int? = 1,
                themeColor: Color = .green,
                dismissAfterTap: Bool = false,
                isPushin: Bool = true,
                allValue: [Value],
                selectValues: Set<Value>,
                singleSaveAction: @escaping (Value) -> Void = {_ in},
                multipleSaveAction: @escaping (Set<Value>) -> Void = {_ in}) {
        self.title = title
        if let maxSelectCount {
            self.maxSelectCount = maxSelectCount
        }else {
            self.maxSelectCount = allValue.count
        }
        self.themeColor = themeColor
        self.dismissAfterTap = dismissAfterTap
        self.isPushin = isPushin
        self.allValue = allValue
        self._selectValues = State(initialValue: selectValues)
        self.singleSaveAction = singleSaveAction
        self.multipleSaveAction = multipleSaveAction
    }
    
    public var body: some View {
        if isPushin {
            contentView()
        }else {
            NavigationView {
                contentView()
            }
            #if canImport(UIKit)
            .navigationViewStyle(.stack)
            #endif
        }
    }
    
    private func select(_ value: Value) {
        if hasSelected(value) {
            // 取消选择
            selectValues.remove(value)
        } else {
            if maxSelectCount == 1 {
                // 单选
                selectValues.removeAll()
                selectValues.insert(value)
            } else if selectValues.count < maxSelectCount {
                // 多选
                selectValues.insert(value)
            }
        }
        
        // 单选直接退出
        if maxSelectCount == 1 && dismissAfterTap {
            if let first = selectValues.first,
               selectValues.count == maxSelectCount {
                singleSaveAction(first)
                dismissPage()
            }
        }
    }
    
    private func hasSelected(_ value: Value) -> Bool {
        selectValues.contains(value)
    }
    
    private func contentView() -> some View {
        Form {
            ForEach(allValue) { value in
                Button {
                    select(value)
                } label: {
                    SimpleCell(
                        value.title,
                        titleColor: hasSelected(value) ? .primary : .secondary,
                        iconName: value.iconName,
                        systemImage: value.systemImage,
                        contentSystemImage: value.contentSystemImage,
                        content: value.content
                    ) {
                        if hasSelected(value) {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .foregroundStyle(themeColor)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle(title)
        .buttonCircleNavi(role: .cancel, isPresent: !isPushin) {dismissPage()}
        .buttonCircleNavi(role: .destructive, isPresent: !dismissAfterTap) {
            if let first = selectValues.first {
                singleSaveAction(first)
            }
            multipleSaveAction(selectValues)
            dismissPage()
        }
    }
}

//#Preview {
//    SimplePicker()
//}
