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
                SimpleCell("系统名称", stateText: DeviceInfo.getSystemName())
                SimpleCell("系统版本", stateText: DeviceInfo.getSystemVersion())
                SimpleCell("设备类型", stateText: DeviceInfo.getModel())
                SimpleCell("设备名称", stateText: DeviceInfo.getDeviceName())
                #endif
                SimpleCell("设备型号", stateText: DeviceInfo.getFullModel())
                SimpleCell("总磁盘", stateText: DeviceInfo.getDiskTotalSize())
                SimpleCell("可用空间", stateText: DeviceInfo.getDiskTotalSize())
                SimpleCell("当前IP", stateText: DeviceInfo.getDeviceIP())
                SimpleCell("应用名称", stateText: DeviceInfo.getAppName())
                SimpleCell("应用版本", stateText: DeviceInfo.getAppVersion())
            }
            
            #if os(iOS)
            Section("设备操作") {
                Button {
                    DeviceInfo.openSystemSetting()
                } label: {
                    Label("跳转系统设置", systemImage: "gear")
                }
                Button {
                    DeviceInfo.playHaptic(.success)
                } label: {
                    Label("Haptic震动 - ✅ 成功", systemImage: "iphone.gen3.radiowaves.left.and.right")
                }
                Button {
                    DeviceInfo.playHaptic(.error)
                } label: {
                    Label("Haptic震动 - ❎ 错误", systemImage: "iphone.gen3.radiowaves.left.and.right")
                }
                Button {
                    DeviceInfo.playHaptic(.warning)
                } label: {
                    Label("Haptic震动 - ⚠️ 警告", systemImage: "iphone.gen3.radiowaves.left.and.right")
                }
            }
            #elseif os(watchOS)
            Section("设备操作") {
                Button {
                    DeviceInfo.playWatchHaptic(.success)
                } label: {
                    Label("Haptic震动 - ✅ 成功", systemImage: "iphone.gen3.radiowaves.left.and.right")
                }
                Button {
                    DeviceInfo.playWatchHaptic(.failure)
                } label: {
                    Label("Haptic震动 - ❎ 错误", systemImage: "iphone.gen3.radiowaves.left.and.right")
                }
                Button {
                    DeviceInfo.playWatchHaptic(.notification)
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
