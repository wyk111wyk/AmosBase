//
//  SwiftUIView.swift
//
//
//  Created by AmosFitness on 2023/12/7.
//

import SwiftUI

public struct DemoSimpleUIElement: View {
    @State private var isTapDismiss = true
    
    @State private var cellId: Int = Date().timeIntervalSince1970.toInt
    @State private var input = ""
    @State private var isFavor = false
    
    @State private var confirmShowPage = false
    
    @State private var randomWord01: String = .randomChinese(word: true)
    @State private var randomTitle01: String = .randomChinese(short: true)
    @State private var randomTitle02: String = .randomChinese(short: true)
    @State private var randomContent01: String = .randomChinese(medium: true)
    @State private var randomContent02: String = .randomChinese(medium: true)
    
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
    
    let additionViews: [AnyView]
    
    @State private var showHiddenButton = false
    @State private var selectedViewIndex: Int?
    
    public init(
        additionViews: [AnyView] = []
    ) {
        self.additionViews = additionViews
        
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
            .navigationDestination(item: $selectedViewIndex, destination: { selectedViewIndex in
                additionViews[selectedViewIndex]
            })
            .navigationTitle("UI元素")
            .buttonCircleNavi(role: .destructive)
        }
    }
    
    private func cellSection() -> some View {
        Section {
            SimpleCell(
                "划动测试",
                titleSystemImage: isFavor ? "star.fill" : nil,
                titleImageColor: .yellow,
                bundleImageName: "LAL_r",
                bundleImageType: "png",
                content: randomContent01,
                purchaseLevel: .premium,
                localizationBundle: .module
            ) {
                HStack {
                    Text(randomWord01)
                        .simpleTag(.full(bgColor: .blue.opacity(0.9)))
                }
            }.simpleSwipe(allowsFullSwipe: true, isFavor: isFavor, favorAction: {
                withAnimation {
                    isFavor.toggle()
                }
            })
            PlainButton {
                SimpleAudioHelper.playRightAudio()
            } label: {
                SimpleCell(
                    randomTitle01,
                    systemImage: "play.circle",
                    content: randomContent01,
                    isPushButton: true
                )
            }
            SimpleCell(
                randomTitle02,
                titleSystemImage: isFavor ? "star.fill" : nil,
                titleImageColor: .yellow,
                numberIcon: 368,
                content: randomContent02,
                contentSystemImage: "tray",
                stateText: randomTitle02
            )
            .swipeActions(edge: .leading, allowsFullSwipe: true, content: {
                Button {
                    withAnimation {
                        showHiddenButton.toggle()
                    }
                } label: {
                    Label("附加按钮", systemImage: "lasso.badge.sparkles")
                }
                .tint(.orange)
            })
        } header: {
            HStack {
                Text("Cell", bundle: .module)
                Spacer()
                Button {
                    withAnimation {
                        randomText()
                    }
                } label: {
                    Text("随机文字")
                        .font(.caption)
                }
            }
        }
        .id(cellId)
    }
    
    private func randomText() {
        randomWord01 = .randomChinese(word: true)
        randomTitle01 = .randomChinese(short: true)
        randomTitle02 = .randomChinese(short: true)
        randomContent01 = .randomChinese(medium: true, long: true)
        randomContent02 = .randomChinese(medium: true)
    }
    
    @ViewBuilder
    private func buttonSection() -> some View {
        if showHiddenButton {
            Section("附加按钮") {
                ForEach(additionViews.indices, id: \.self) { index in
                    PlainButton {
                        selectedViewIndex = index
                    } label: {
                        SimpleCell(additionTitles[index], isPushButton: true)
                            .contentShape(Rectangle())
                    }
                }
            }
        }
    }
    
    private var additionTitles: [String] {
        ["地图和标记", "设备应用管理"]
    }
    
    @ViewBuilder
    private func textFieldSection() -> some View {
        Section {
            SimpleTextField($input)
        } header: {
            Text("TextField", bundle: .module)
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
            SimpleTagsView(tags: tagCollectOne, tagType: .list) { tag in
                var newTag = tag
                newTag.color = .blue
                newTag.icon = "medal"
                newTag.viewType = .border()
                withAnimation {
                    tagCollectOne.removeByItem(newTag)
                    tagCollectTwo.appendOrReplace(newTag)
                }
            }
            SimpleTagsView(tags: tagCollectTwo, tagType: .list) { tag in
                var newTag = tag
                newTag.color = .purple
                newTag.icon = "person.wave.2.fill"
                newTag.viewType = .bg()
                withAnimation {
                    tagCollectTwo.removeByItem(newTag)
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
            SimpleSlider(value: $sliderValue, range: 0...150, cornerScale: 2, color: .red, textType: .value)
            SimpleButtonSlider(value: $sliderValue, range: 0...150, color: .green, minText: "0", maxText: "150")
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
    DemoSimpleUIElement()
        .environment(\.locale, .zhHans)
}
