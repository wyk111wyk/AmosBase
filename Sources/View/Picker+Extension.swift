//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2024/4/4.
//

import SwiftUI

public protocol SimplePickerItem: Identifiable, Hashable {
    var title: String { get }
    var titleColor: Color? { get }
    var iconName: String? { get }
    var systemImage: String? { get }
    var contentSystemImage: String? { get }
    var content: String? { get }
}

public struct SimplePicker<Value: SimplePickerItem, V: View>: View {
    @Environment(\.dismiss) private var dismissPage
    // Picker属性
    let title: String
    let maxSelectCount: Int
    let themeColor: Color
    // 点击就退出
    let dismissAfterTap: Bool
    // 点击就保存
    let saveAfterTap: Bool
    
    let isPushin: Bool
    // 选择范围
    let allValue: [Value]
    let disabledValues: [Value]
    // 已选的值
    @State private var selectValues: Set<Value>
    // 保存值的回调（并不直接保存结果）
    let singleSaveAction: (Value) -> Void
    let multipleSaveAction: (Set<Value>) -> Void
    // 自定义Cell的样式
    @ViewBuilder let customCell: (any SimplePickerItem) -> V
    
    @State private var searchKey = ""
    
    public init(
        title: String,
        maxSelectCount: Int? = 1,
        themeColor: Color = .green,
        dismissAfterTap: Bool = false,
        saveAfterTap: Bool = false,
        isPushin: Bool = true,
        allValue: [Value],
        disabledValues: [Value] = [],
        selectValues: Set<Value>,
        singleSaveAction: @escaping (Value) -> Void = {_ in},
        multipleSaveAction: @escaping (Set<Value>) -> Void = {_ in},
        @ViewBuilder customCell: @escaping (any SimplePickerItem) -> V = {_ in EmptyView()}
    ) {
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
        self.disabledValues = disabledValues
        self.saveAfterTap = saveAfterTap
        self._selectValues = State(initialValue: selectValues)
        self.singleSaveAction = singleSaveAction
        self.multipleSaveAction = multipleSaveAction
        self.customCell = customCell
    }
    
    public var body: some View {
        if isPushin {
            contentView()
        }else {
            NavigationStack {
                contentView()
            }
        }
    }
    
    private var filterValue: [Value] {
        guard searchKey.isNotEmpty else {
            return allValue
        }
        
        return allValue.filter { value in
            value.title.contains(searchKey)
        }
    }
    
    private func select(_ value: Value) {
        guard !isDisabled(value) else {
            return
        }
        
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
        }else if saveAfterTap {
            if let first = selectValues.first,
               selectValues.count == maxSelectCount {
                singleSaveAction(first)
            }
        }
    }
    
    private func hasSelected(_ value: Value) -> Bool {
        selectValues.contains(value)
    }
    
    private func isDisabled(_ value: Value) -> Bool {
        disabledValues.contains(value)
    }
    
    private func titleColor(_ value: Value) -> Color {
        if hasSelected(value) {
            if let titleColor = value.titleColor {
                return titleColor
            }else {
                return .primary
            }
        }else {
            return .secondary
        }
    }
    
    private func contentView() -> some View {
        Form {
            Section {
                ForEach(filterValue) { value in
                    Button {
                        select(value)
                    } label: {
                        if V.self == EmptyView.self {
                            SimpleCell(
                                value.title,
                                titleColor: titleColor(value),
                                iconName: value.iconName,
                                systemImage: isDisabled(value) ? "xmark.circle" : value.systemImage,
                                content: value.content,
                                contentColor: hasSelected(value) ? .primary : .secondary,
                                contentSystemImage: value.contentSystemImage
                            ) {
                                if hasSelected(value) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .imageScale(.large)
                                        .foregroundStyle(themeColor)
                                }
                            }
                            .contentShape(Rectangle())
                        }else {
                            HStack {
                                customCell(value)
                                Spacer()
                                if hasSelected(value) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .imageScale(.large)
                                        .foregroundStyle(themeColor)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                if maxSelectCount > 1 {
                    Text("已选：\(selectValues.count) / \(maxSelectCount)")
                }
            }
            
            #if os(macOS)
            Section {
                SimpleMiddleButton("完成") {
                    save()
                }.tint(.accentColor)
                SimpleMiddleButton("取消") {
                    dismissPage()
                }
            }
            #endif
        }
        .formStyle(.grouped)
        .navigationTitle(title)
        #if !os(watchOS)
        .simpleSearch(text: $searchKey, isAlwaysShow: false)
        .searchable(text: $searchKey, placement: SearchFieldPlacement.automatic)
        #endif
        #if os(iOS)
        .buttonCircleNavi(role: .cancel, isPresent: !isPushin) {dismissPage()}
        .buttonCircleNavi(
            role: .destructive,
            isPresent: !dismissAfterTap
        ) {
            save()
        }
        #endif
    }
    
    private func save() {
        if let first = selectValues.first {
            singleSaveAction(first)
        }
        multipleSaveAction(selectValues)
        dismissPage()
    }
}

struct SimplePickerDemo: View {
    enum PageSelection: CaseIterable, Identifiable {
        case single, multiple
        var id: String { title }
        var title: String {
            switch self {
            case .single: "单选"
            case .multiple: "多选"
            }
        }
        var count: Int {
            switch self {
            case .single: 1
            case .multiple: 6
            }
        }
    }
    
    @State private var page: PageSelection = .single
    let allPickerContent = DemoPickerModel.allContent
    
    public var body: some View {
        NavigationStack {
            SimplePicker(
                title: "Picker",
                maxSelectCount: page.count,
                allValue: allPickerContent,
                disabledValues: [allPickerContent.randomElement()!],
                selectValues: [allPickerContent.randomElement()!]
            )
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Picker("", selection: $page) {
                        ForEach(PageSelection.allCases) {
                            Text($0.title).tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 180)
                }
            }
        }
    }
}

#Preview {
    SimplePickerDemo()
}
