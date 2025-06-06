//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by Amos on 2025/3/14.
//

import SwiftUI

public struct DemoSimpleButton: View {
    @Environment(\.dismiss) private var dismissPage
    
    @State var isPresent: Bool = false
    @State private var isPressing: Bool = false
    @State var isLoading: Bool = false
    @State var isNetworkWording: Bool?
    @State var showConfirm: Bool = false
    
    public init(){}
    
    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    SimpleToggleButton(
                        title: "点击切换：\(isPresent.toString())",
                        isPresented: $isPresent
                    )
                    DetectButton(
                        tapAction: {
                            print("点击完成")
                        },
                        holdAction: { isPressing in
                            self.isPressing = isPressing
                        },
                        label: {
                            HStack {
                                Text("长按检测：\(isPressing.toString())")
                                    .foregroundStyle(isPressing ? .red : .green)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        })
                }
                Section {
                    ConfirmButton(tapAction: {})
                    ConfirmButton(isInMiddle: true, tapAction: {})
                    ConfirmButton(isLoading: true, tapAction: {})
                    DeleteButton(tapAction: {})
                    SimpleEditButton(tapAction: {})
                    ConfirmButton(title: "显示对话框") {
                        showConfirm = true
                    }
                }
                Section {
                    SimpleAsyncButton {
                        isLoading = true
                        isNetworkWording = await SimpleWeb().isNetworkAvailable()
                        isLoading = false
                    } label: {
                        SimpleCell("多线程任务") {
                            if isLoading {
                                ProgressView()
                            }else if let isNetworkWording {
                                Text(isNetworkWording ? "连接" : "断开")
                                    .simpleTag(.border(contentColor: isNetworkWording ? . green : .red))
                            }
                        }
                    }
                }
                Section {
                    SimpleHoldButton(
                        duration: 2,
                        coverColor: .red.opacity(0.5),
                        buttonView: {
                            HStack {
                                Text("长按检测")
                                Spacer()
                            }
                        },
                        onCompletion: {
                            SimpleHaptic.playSuccessHaptic()
                        }
                    )
                }
            }
            .navigationTitle("按钮类型")
            .largeTitleForNavigationBar()
            .formStyle(.grouped)
            .buttonCircleNavi(role: .cancel, title: "测试按钮") {
                dismissPage()
            }
            .buttonCircleNavi(role: .destructive, isLoading: false)
            .confirmationDialog(
                "测试按钮",
                isPresented: $showConfirm,
                titleVisibility: .visible
            ) {
                SimpleToggleButton(
                    title: "切换载入",
                    isPresented: $isLoading
                )
            }
        }
    }
}

#Preview("按钮") {
    DemoSimpleButton()
}
