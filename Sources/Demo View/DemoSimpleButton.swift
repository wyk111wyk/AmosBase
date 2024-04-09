//
//  SwiftUIView.swift
//  
//
//  Created by AmosFitness on 2023/12/7.
//

import SwiftUI

public struct DemoSimpleButton<V: View>: View {
    @State private var isTapDismiss = true
    @State private var input = ""
    @State private var showInput = false
    
    @State private var confirmShowPage = false
    @State private var showPage = false
    
    let allPickerContent = DemoPickerModel.allContent
    @State private var singleValue: DemoPickerModel
    @State private var mutipleValue: Set<DemoPickerModel>
    
    @ViewBuilder let stateView: () -> V
    public init(@ViewBuilder stateView: @escaping () -> V = { EmptyView() }) {
        self.stateView = stateView
        
        singleValue = allPickerContent.randomElement()!
        mutipleValue = [allPickerContent.randomElement()!]
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                cellSection()
                pickerSection()
                buttonSection()
            }
            .navigationTitle("按钮")
            .buttonCircleNavi(role: .destructive)
        }
    }
    
    private func cellSection() -> some View {
        Section("Cell") {
            SimpleCell("Swipe Test", bundleImageName: "LAL_r",
                       bundleImageType: "png", content: "Content") {
                HStack {
                    Text("Tag")
                        .simpleTagBorder(themeColor: .green,
                                         bgColor: .red)
                    Text("Tag")
                        .simpleTagBackground()
                }
            }.simpleSwipe(hasEdit: true, hasFavor: true, isFavor: false)
            SimpleCell("Title Title Title Title Title Title Title Title Title Title",
                       systemImage: "person.wave.2.fill",
                       content: "Cont Cont Cont Cont Cont Cont Cont Cont Cont Cont Cont Cont Cont Cont Cont",
                       fullContent: true
            )
            SimpleCell("Title Title Title Title Title Title",
                       systemImage: "person.wave.2.fill",
                       content: "Cont Cont Cont Cont Cont Cont Cont Cont Cont Cont",
                       stateText: "State Text State Text State Text State Text"
            )
        }
    }
    
    @ViewBuilder
    private func buttonSection() -> some View {
        if #available(iOS 16, macOS 13, *) {
            Section("Button") {
                #if os(iOS) || targetEnvironment(macCatalyst)
                SimpleMiddleButton("Middle button", role: .none) {
                    confirmShowPage = true }
                    .fullScreenCover(isPresented: $showPage, content: { stateView() })
                    .simpleConfirmation(type: .destructiveCancel, title: "确认操作", isPresented: $confirmShowPage, confirmTap:  { showPage = true })
                #endif
                SimpleMiddleButton("Middle button", role: .destructive) {}
                SimpleMiddleButton("Middle button", systemImageName: "person.wave.2.fill", role: .destructive) {}
            }
            #if !os(watchOS)
            Section("TextField") {
                Button { showInput = true } label: {
                    SimpleCell("输入短文字", systemImage: "rectangle.and.pencil.and.ellipsis.rtl")
                }
                SimpleTextField($input)
            }
            .sheet(isPresented: $showInput, content: {
                SimpleTextInputView(input, title: "输入短文字") { newText in
                    input = newText
                }.presentationDetents([.fraction(0.3)])
            })
            #endif
        }
    }
    
    private func pickerSection() -> some View {
        Section {
            NavigationLink {
                SimplePicker(
                    title: "单选",
                    dismissAfterTap: isTapDismiss,
                    allValue: allPickerContent,
                    selectValues: [singleValue]
                ) { newValue in
                    singleValue = newValue
                }
            } label: {
                SimpleCell("Single Picker",
                           systemImage: "person.wave.2.fill",
                           content: "Content Content Content",
                           stateText: singleValue.title)
            }
            NavigationLink {
                SimplePicker(
                    title: "多选",
                    maxSelectCount: nil,
                    allValue: allPickerContent,
                    selectValues: mutipleValue, 
                    multipleSaveAction:  { newSelects in
                        mutipleValue = newSelects
                    })
            } label: {
                SimpleCell("Mutile Picker",
                           systemImage: "person.wave.2.fill",
                           content: "Select count: \(mutipleValue.count)") {
                    Text(mutipleValue.map { $0.title }.joined(separator: ", ")).multilineTextAlignment(.leading)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            HStack {
                Text("Picker")
                Spacer()
                Toggle("单选点击退出", isOn: $isTapDismiss)
                    .labelStyle(font: .footnote)
            }
        }
    }
}

#Preview("Navi") {
    NavigationStack {
        DemoSimpleButton()
    }
}
