//
//  SwiftUIView.swift
//
//
//  Created by AmosFitness on 2023/12/7.
//

import SwiftUI

public struct DemoSimpleButton<V: View>: View {
    @State private var isTapDismiss = true
    
    @State private var cellId: Int = Date().timeIntervalSince1970.toInt
    
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
            .formStyle(.grouped)
            .navigationDestination(
                isPresented: $showPage,
                destination: {
                    stateView()
                })
            .navigationTitle("UI元素")
            .buttonCircleNavi(role: .destructive)
#if !os(watchOS)
            .sheet(isPresented: $showInput, content: {
                SimpleTextInputView(
                    pageName: "输入短文字",
                    title: input,
                    showContent: false) { result in
                        input = result.title
                    }.presentationDetents([.height(200)])
            })
#endif
        }
    }
    
    private func cellSection() -> some View {
        Section {
            SimpleCell(
                "划动测试",
                bundleImageName: "LAL_r",
                bundleImageType: "png",
                content: String.randomChinese(medium: true)
            ) {
                HStack {
                    Text(String.randomChinese(word: true))
                        .simpleTag(.full(bgColor: .blue.opacity(0.9)))
                }
            }.simpleSwipe(hasEdit: true, hasFavor: true, isFavor: false)
            Button {
                
            } label: {
                SimpleCell(
                    String.randomChinese(short: true, medium: true),
                    numberIcon: 28,
                    iconColor: .red,
                    content: String.randomChinese(medium: true, long: true)
                )
            }
            SimpleCell(
                String.randomChinese(short: true),
                systemImage: "person.wave.2.fill",
                content: String.randomChinese(medium: true),
                stateText: String.randomChinese(short: true)
            )
        } header: {
            HStack {
                Text("Cell", bundle: .module)
                Spacer()
                Button {
                    cellId = Date().timeIntervalSince1970.toInt
                } label: {
                    Text("随机文字")
                        .font(.caption)
                }
            }
        }
        .id(cellId)
    }
    
    @ViewBuilder
    private func buttonSection() -> some View {
        Section {
#if os(iOS) || targetEnvironment(macCatalyst)
            SimpleMiddleButton("普通中央按钮", role: .none) {
                confirmShowPage = true }
            .simpleConfirmation(type: .destructiveCancel, title: "确认操作", isPresented: $confirmShowPage, confirmTap:  { showPage = true })
#endif
            SimpleMiddleButton("重要中央按钮", systemImageName: "person.wave.2.fill", role: .destructive) {}
        } header: {
            Text("Button", bundle: .module)
        }
    }
    
    @ViewBuilder
    private func textFieldSection() -> some View {
#if !os(watchOS)
        Section {
            Button { showInput = true } label: {
                SimpleCell("输入短文字", systemImage: "rectangle.and.pencil.and.ellipsis.rtl")
            }
            .buttonStyle(.borderless)
            SimpleTextField($input)
        } header: {
            Text("TextField", bundle: .module)
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
                Text("Picker", bundle: .module)
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
                newTag.viewType = .border()
                withAnimation {
                    tagCollectOne.removeById(newTag)
                    tagCollectTwo.appendOrReplace(newTag)
                }
            }
            SimpleTagsView(tags: tagCollectTwo) { tag in
                var newTag = tag
                newTag.color = .purple
                newTag.icon = "person.wave.2.fill"
                newTag.viewType = .full()
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
                Text("Slider", bundle: .module)
                Spacer()
                Text("\(sliderValue.toString(digit: 1))")
            }
        }
    }
}

#Preview("Cell") {
    DemoSimpleButton()
        .environment(\.locale, .zhHans)
}
