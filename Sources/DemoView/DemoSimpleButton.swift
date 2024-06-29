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
    
    @State private var tagCollectOne: [SimpleTagViewItem] = [
        .init(title: "Tag1", icon: "person.wave.2.fill"),
        .init(title: "Tag2", icon: "person.wave.2.fill"),
        .init(title: "Tag3", icon: "person.wave.2.fill"),
        .init(title: "Tag4", icon: "person.wave.2.fill"),
        .init(title: "Tag5", icon: "person.wave.2.fill"),
        .init(title: "Tag6", icon: "person.wave.2.fill")
    ]
    @State private var tagCollectTwo: [SimpleTagViewItem] = []
    
    @State private var sliderValue: CGFloat = 20
    @State private var starValue: Int = 2
    
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
                tagSection()
                sliderSection()
                textFieldSection()
            }
            .navigationDestination(isPresented: $showPage, destination: {
                stateView()
            })
            .navigationTitle("UI元素")
            .buttonCircleNavi(role: .destructive)
            .sheet(isPresented: $showInput, content: {
                SimpleTextInputView(
                    pageName: "输入短文字",
                    title: input,
                    showContent: false) { result in
                    input = result.title
                }.presentationDetents([.height(200)])
            })
        }
    }
    
    private func cellSection() -> some View {
        Section("Cell") {
            SimpleCell(
                "划动测试",
                bundleImageName: "LAL_r",
                bundleImageType: "png",
                content: String.randomChinese(short: true)
            ) {
                HStack {
                    Text("Tag")
                        .simpleTag(.border())
                }
            }.simpleSwipe(hasEdit: true, hasFavor: true, isFavor: false)
            SimpleCell(String.randomChinese(short: true, medium: true),
                       systemImage: "person.wave.2.fill",
                       content: String.randomChinese(medium: false),
                       fullContent: true
            )
            SimpleCell(String.randomChinese(medium: true),
                       systemImage: "person.wave.2.fill",
                       content: String.randomChinese(medium: true),
                       stateText: String.randomChinese(short: true)
            )
        }
    }
    
    @ViewBuilder
    private func buttonSection() -> some View {
        Section("Button") {
            #if os(iOS) || targetEnvironment(macCatalyst)
            SimpleMiddleButton("普通中央按钮", role: .none) {
                confirmShowPage = true }
                .simpleConfirmation(type: .destructiveCancel, title: "确认操作", isPresented: $confirmShowPage, confirmTap:  { showPage = true })
            #endif
            SimpleMiddleButton("重要中央按钮", systemImageName: "person.wave.2.fill", role: .destructive) {}
        }
    }
    
    @ViewBuilder
    private func textFieldSection() -> some View {
        #if !os(watchOS)
        Section("TextField") {
            Button { showInput = true } label: {
                SimpleCell("输入短文字", systemImage: "rectangle.and.pencil.and.ellipsis.rtl")
            }
            SimpleTextField($input)
        }
        #endif
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
                SimpleCell("单项选择",
                           systemImage: "person.wave.2.fill",
                           content: "仅可选择1项",
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
                SimpleCell("多项选择",
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
    
    private func tagSection() -> some View {
        Section {
            SimpleTagsView(tags: tagCollectOne) { tag in
                var newTag = tag
                newTag.color = .blue
                newTag.icon = "medal"
                newTag.viewType.toggle()
                withAnimation {
                    tagCollectOne.removeById(newTag)
                    tagCollectTwo.appendOrReplace(newTag)
                }
            }
            SimpleTagsView(tags: tagCollectTwo) { tag in
                var newTag = tag
                newTag.color = .purple
                newTag.icon = "person.wave.2.fill"
                newTag.viewType.toggle()
                withAnimation {
                    tagCollectTwo.removeById(newTag)
                    tagCollectOne.appendOrReplace(newTag)
                }
            }
        } header: {
            HStack {
                Text("Tags")
                Spacer()
            }
        }
    }
    
    private func sliderSection() -> some View {
        Section {
            SimpleSlider(value: $sliderValue, range: 0...150, color: .blue)
            SimpleSlider(value: $sliderValue, range: 0...150, cornerScale: 2, color: .red, textType: .value)
            SimpleButtonSlider(value: $sliderValue, range: 0...150, color: .green, minText: "0", maxText: "150")
            SimpleButtonSlider(value: $sliderValue, range: 0...150, buttonWidth: 60, cornerScale: 2, color: .brown, textColor: .white, textType: .value)
            SimpleStarSlider(currentRating: $starValue,
                             systemIcon: "externaldrive.fill",
                             state: starValue.toString())
        } header: {
            HStack {
                Text("Slider")
                Spacer()
                Text("\(sliderValue.toString(digit: 1))")
            }
        }
    }
}

#Preview("Navi") {
    NavigationStack {
        DemoSimpleButton()
    }
}
