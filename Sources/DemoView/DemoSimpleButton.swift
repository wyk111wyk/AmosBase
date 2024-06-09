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
    
    @State private var selectedTag: SimpleTagViewItem?
    
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
        }
    }
    
    private func cellSection() -> some View {
        Section("Cell") {
            SimpleCell("Swipe Test", bundleImageName: "LAL_r",
                       bundleImageType: "png", content: "Content") {
                HStack {
                    Text("Tag")
                        .simpleTag(.full())
                    Text("Tag")
                        .simpleTag(.border())
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
        Section("Button") {
            #if os(iOS) || targetEnvironment(macCatalyst)
            SimpleMiddleButton("Middle button", role: .none) {
                confirmShowPage = true }
                .simpleConfirmation(type: .destructiveCancel, title: "确认操作", isPresented: $confirmShowPage, confirmTap:  { showPage = true })
            #endif
            SimpleMiddleButton("Middle button", role: .destructive) {}
            SimpleMiddleButton("Middle button", systemImageName: "person.wave.2.fill", role: .destructive) {}
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
        .sheet(isPresented: $showInput, content: {
            SimpleTextInputView(title: input, showContent: false) { result in
                input = result.title
            }.presentationDetents([.fraction(0.3)])
        })
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
    
    private func tagSection() -> some View {
        Section {
            SimpleTagsView(tags: [
                .init(title: "Tag1", icon: "person.wave.2.fill"),
                .init(title: "Tag2", icon: "person.wave.2.fill"),
                .init(title: "Tag3", icon: "person.wave.2.fill"),
                .init(title: "Tag4", icon: "person.wave.2.fill"),
                .init(title: "Tag5", icon: "person.wave.2.fill"),
                .init(title: "Tag6", icon: "person.wave.2.fill")
            ]) { tag in
                selectedTag = tag
            }
        } header: {
            HStack {
                Text("Tags")
                Spacer()
                if let selectedTag {
                    Text(selectedTag.title)
                }
            }
        }
    }
    
    private func sliderSection() -> some View {
        Section {
            SimpleSlider(value: $sliderValue, range: 0...150)
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
