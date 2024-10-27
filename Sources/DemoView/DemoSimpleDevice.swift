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
    @ObservedObject var location = SimpleLocationHelper()
    public init(_ title: String = "Device Info") {
        self.title = title
    }
    
    @State private var wifiName: String?
    @State private var mapLocation: CLLocationCoordinate2D? = nil
    
    public var body: some View {
        Form {
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
            
            #if !os(macOS)
            Section("位置信息") {
                SimpleCell("Wifi名称", stateText: wifiName)
                SimpleCell("当前地址") {
                    if let place = location.currentPlace {
                        Text(place.toFullAddress())
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }else {
                        ProgressView()
                    }
                }
                Button {
                    mapLocation = location.currentLocation
                } label: {
                    SimpleCell("经纬度") {
                        if let coordinate = location.currentLocation {
                            VStack(alignment: .trailing) {
                                Text("Lat: \(coordinate.latitude)")
                                Text("Lon: \(coordinate.longitude)")
                            }
                            .foregroundStyle(.secondary)
                            .font(.callout)
                        }else {
                            ProgressView()
                        }
                    }
                }
                .disabled(location.currentLocation == nil)
            }
            #endif
            
            hapticSection()
        }
        .formStyle(.grouped)
        .navigationTitle(title)
        .sheet(item: $mapLocation) { location in
            SimpleMap(
                isPushin: false,
                pinMarker: .init(location: location.toLocation())
            )
        }
        .task {
            #if os(iOS)
            wifiName = SimpleDevice.wifiInfo()
            #endif
        }
    }
    
    @ViewBuilder
    private func hapticSection() -> some View {
        #if os(iOS)
        Section("设备操作") {
            Button {
                SimpleDevice.openSystemSetting()
            } label: {
                SimpleCell("跳转系统设置", systemImage: "gear")
            }
            Button {
                SimpleDevice.playNotificationHaptic(.success)
            } label: {
                SimpleCell("Haptic震动 - ✅ 成功", systemImage: "iphone.gen3.radiowaves.left.and.right")
            }
            Button {
                SimpleDevice.playNotificationHaptic(.error)
            } label: {
                SimpleCell("Haptic震动 - ❎ 错误", systemImage: "iphone.gen3.radiowaves.left.and.right")
            }
            Button {
                SimpleDevice.playNotificationHaptic(.warning)
            } label: {
                SimpleCell("Haptic震动 - ⚠️ 警告", systemImage: "iphone.gen3.radiowaves.left.and.right")
            }
            Button {
                SimpleDevice.playFeedbackHaptic(.heavy)
            } label: {
                SimpleCell("Haptic震动 - 强烈", systemImage: "iphone.radiowaves.left.and.right.circle.fill")
            }
            Button {
                SimpleDevice.playFeedbackHaptic(.rigid)
            } label: {
                SimpleCell("Haptic震动 - 较强", systemImage: "iphone.radiowaves.left.and.right.circle.fill")
            }
            Button {
                SimpleDevice.playFeedbackHaptic(.medium)
            } label: {
                SimpleCell("Haptic震动 - 普通", systemImage: "iphone.radiowaves.left.and.right.circle.fill")
            }
            Button {
                SimpleDevice.playFeedbackHaptic(.soft)
            } label: {
                SimpleCell("Haptic震动 - 柔软", systemImage: "iphone.radiowaves.left.and.right.circle.fill")
            }
            Button {
                SimpleDevice.playFeedbackHaptic(.light)
            } label: {
                SimpleCell("Haptic震动 - 轻柔", systemImage: "iphone.radiowaves.left.and.right.circle.fill")
            }
        }
        #elseif os(watchOS)
        Section("设备操作") {
            Button {
                SimpleDevice.playWatchHaptic(.success)
            } label: {
                SimpleCell("Haptic震动 - ✅ 成功", systemImage: "iphone.gen3.radiowaves.left.and.right")
            }
            Button {
                SimpleDevice.playWatchHaptic(.failure)
            } label: {
                SimpleCell("Haptic震动 - ❎ 错误", systemImage: "iphone.gen3.radiowaves.left.and.right")
            }
            Button {
                SimpleDevice.playWatchHaptic(.notification)
            } label: {
                SimpleCell("Haptic震动 - ⚠️ 警告", systemImage: "iphone.gen3.radiowaves.left.and.right")
            }
            Button {
                SimpleDevice.playWatchHaptic(.directionUp)
            } label: {
                SimpleCell("Haptic震动 - ⬆️ 增加", systemImage: "iphone.gen3.radiowaves.left.and.right")
            }
            Button {
                SimpleDevice.playWatchHaptic(.directionDown)
            } label: {
                SimpleCell("Haptic震动 - ⬇️ 减少", systemImage: "iphone.gen3.radiowaves.left.and.right")
            }
            Button {
                SimpleDevice.playWatchHaptic(.retry)
            } label: {
                SimpleCell("Haptic震动 - 🔁 重试", systemImage: "iphone.gen3.radiowaves.left.and.right")
            }
            Button {
                SimpleDevice.playWatchHaptic(.start)
            } label: {
                SimpleCell("Haptic震动 - ▶️ 开始", systemImage: "iphone.gen3.radiowaves.left.and.right")
            }
            Button {
                SimpleDevice.playWatchHaptic(.stop)
            } label: {
                SimpleCell("Haptic震动 - 🛑 停止", systemImage: "iphone.gen3.radiowaves.left.and.right")
            }
        }
        #endif
    }
}

#Preview {
    NavigationStack {
        DemoSimpleDevice()
    }
}
