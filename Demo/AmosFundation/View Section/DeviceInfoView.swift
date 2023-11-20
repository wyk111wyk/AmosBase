//
//  DeviceInfoView.swift
//  AmosFundation
//
//  Created by AmosFitness on 2023/11/13.
//

import SwiftUI
import AmosBase

struct DeviceInfoView: View {
    let title: String
    init(_ title: String = "Device Info") {
        self.title = title
    }
    
    var body: some View {
        Form {
            Section("设备信息") {
                #if os(iOS)
                SimpleCell("系统名称", stateText: SimpleDevice.getSystemName())
                SimpleCell("系统版本", stateText: SimpleDevice.getSystemVersion())
                SimpleCell("设备类型", stateText: SimpleDevice.getModel())
                SimpleCell("设备名称", stateText: SimpleDevice.getDeviceName())
                #endif
                SimpleCell("设备型号", stateText: SimpleDevice.getFullModel())
                SimpleCell("总磁盘", stateText: SimpleDevice.getDiskTotalSize())
                SimpleCell("可用空间", stateText: SimpleDevice.getDiskTotalSize())
                SimpleCell("当前IP", stateText: SimpleDevice.getDeviceIP())
                SimpleCell("应用名称", stateText: SimpleDevice.getAppName())
                SimpleCell("应用版本", stateText: SimpleDevice.getAppVersion())
            }
            
            #if os(iOS)
            Section("设备操作") {
                Button {
                    SimpleDevice.openSystemSetting()
                } label: {
                    Label("跳转系统设置", systemImage: "gear")
                }
                Button {
                    SimpleDevice.playHaptic(.success)
                } label: {
                    Label("Haptic震动 - ✅ 成功", systemImage: "iphone.gen3.radiowaves.left.and.right")
                }
                Button {
                    SimpleDevice.playHaptic(.error)
                } label: {
                    Label("Haptic震动 - ❎ 错误", systemImage: "iphone.gen3.radiowaves.left.and.right")
                }
                Button {
                    SimpleDevice.playHaptic(.warning)
                } label: {
                    Label("Haptic震动 - ⚠️ 警告", systemImage: "iphone.gen3.radiowaves.left.and.right")
                }
            }
            #elseif os(watchOS)
            Section("设备操作") {
                Button {
                    SimpleDevice.playWatchHaptic(.success)
                } label: {
                    Label("Haptic震动 - ✅ 成功", systemImage: "iphone.gen3.radiowaves.left.and.right")
                }
                Button {
                    SimpleDevice.playWatchHaptic(.failure)
                } label: {
                    Label("Haptic震动 - ❎ 错误", systemImage: "iphone.gen3.radiowaves.left.and.right")
                }
                Button {
                    SimpleDevice.playWatchHaptic(.notification)
                } label: {
                    Label("Haptic震动 - ⚠️ 警告", systemImage: "iphone.gen3.radiowaves.left.and.right")
                }
            }
            #endif
        }
        .navigationTitle(title)
    }
}

#Preview {
    NavigationStack {
        DeviceInfoView()
    }
}
