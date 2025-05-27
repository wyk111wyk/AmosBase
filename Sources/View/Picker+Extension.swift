//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/4/15.
//

import SwiftUI

/// 创建一个可选的 Picker，允许选择 nil
/// - label: Picker 的标题
/// - selection: 绑定到可选的选择值
/// - options: 可选值的数组
/// - nilOptionText: nil 选项显示的文本
/// - content: 每个选项的显示视图
public struct OptionalPicker<
    SelectionValue: Hashable,
    Content: View
>: View {
    let label: String
    let selection: Binding<SelectionValue?>
    let options: [SelectionValue]
    let nilOptionText: String?
    let content: (SelectionValue) -> Content
    
    public init(
        _ label: String,
        selection: Binding<SelectionValue?>,
        options: [SelectionValue],
        nilOptionText: String? = nil,
        @ViewBuilder content: @escaping (SelectionValue) -> Content
    ) {
        self.label = label
        self.selection = selection
        self.options = options
        self.nilOptionText = nilOptionText
        self.content = content
    }
    
    public var body: some View {
        Picker(label.toLocalizedKey(), selection: Binding(
            get: { selection.wrappedValue },
            set: { newValue in selection.wrappedValue = newValue }
        )) {
            // 添加 nil 选项
            if let nilOptionText {
                Text(nilOptionText.toLocalizedKey()).tag(SelectionValue?.none)
            }else {
                Text("None", bundle: .module).tag(SelectionValue?.none)
            }
            
            // 添加其他选项
            ForEach(options, id: \.self) { option in
                content(option).tag(SelectionValue?.some(option))
            }
        }
    }
}

/// 创建一个可选的 Picker，允许选择 nil，支持自定义标签视图
/// - selection: 绑定到可选的选择值
/// - content: 每个选项的显示视图
/// - label: 自定义的标签视图（支持任意 SwiftUI 视图）
/// - options: 可选值的数组（可选参数）
/// - nilOptionText: nil 选项显示的文本（可选参数）
public struct OptionalLabelPicker<
    SelectionValue: Hashable,
    Content: View,
    Label: View
>: View {
    let label: Label
    let selection: Binding<SelectionValue?>
    let options: [SelectionValue]
    let nilOptionText: String?
    let content: (SelectionValue) -> Content
    
    public init(
        selection: Binding<SelectionValue?>,
        @ViewBuilder content: @escaping (SelectionValue) -> Content,
        @ViewBuilder label: () -> Label,
        options: [SelectionValue] = [],
        nilOptionText: String? = nil
    ) {
        self.selection = selection
        self.content = content
        self.label = label()
        self.options = options
        self.nilOptionText = nilOptionText
    }
    
    public var body: some View {
        Picker(selection: Binding(
            get: { selection.wrappedValue },
            set: { newValue in selection.wrappedValue = newValue }
        )) {
            if let nilOptionText {
                Text(nilOptionText).tag(SelectionValue?.none)
            }else {
                Text("None", bundle: .module).tag(SelectionValue?.none)
            }
            
            ForEach(options, id: \.self) { option in
                content(option).tag(SelectionValue?.some(option))
            }
        } label: {
            label
        }
    }
}

#Preview {
    @Previewable @State var selectedValue: String? = nil
    @Previewable @State var selectedColor: String? = nil
                
    Form {
        OptionalPicker(
            "选择选项",
            selection: $selectedValue,
            options: ["选项1", "选项2", "选项3"]
        ) { option in
            Text(option)
        }
        
        OptionalLabelPicker(
            selection: $selectedColor,
            content: { color in
                HStack {
                    Image(systemName: "paintpalette")
                    Text(color)
                }
            },
            label: {
                Label("选择颜色", systemImage: "circle.fill")
            },
            options: ["红色", "蓝色", "绿色"],
            nilOptionText: "无"
        )
    }
}
