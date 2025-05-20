//
//  DeviceInfoView.swift
//  AmosFundation
//
//  Created by AmosFitness on 2023/11/13.
//

import SwiftUI
import MapKit
import CoreLocation

public struct DemoSimpleDevice: View {
    @Environment(\.dismiss) private var dismissPage
    
    let title: String
    public init(_ title: String = "Device Info") {
        self.title = title
    }
    
    @State private var wifiName: String?
    
    public var body: some View {
        Form {
            Section("设备操作") {
                PlainButton {
                    SimpleDevice.openSystemSetting()
                } label: {
                    SimpleCell("跳转系统设置", systemImage: "gear")
                }
            }
            Section("设备信息") {
                #if os(iOS)
                SimpleCell("系统名称", stateText: SimpleDevice.getSystemName())
                SimpleCell("系统版本", stateText: SimpleDevice.getSystemVersion())
                SimpleCell("设备类型", stateText: SimpleDevice.getModel())
                #endif
                SimpleCell("设备型号", stateText: SimpleDevice.getFullModel())
                SimpleCell("总磁盘", stateText: SimpleDevice.getDiskTotalSize())
                SimpleCell("可用空间", stateText: SimpleDevice.getDiskTotalSize())
                SimpleCell("当前IP", stateText: SimpleDevice.getDeviceIP())
                SimpleCell("应用名称", stateText: SimpleDevice.getAppName())
                SimpleCell("应用版本", stateText: SimpleDevice.getAppVersion())
            }
        }
        .formStyle(.grouped)
        .navigationTitle(title)
    }
}

#Preview {
    NavigationStack {
        DemoSimpleDevice()
    }
}
