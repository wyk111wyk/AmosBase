//
//  DeviceInfoView.swift
//  AmosFundation
//
//  Created by AmosFitness on 2023/11/13.
//

import SwiftUI
//import AsyncLocationKit
import CoreLocation

public struct DemoSimpleDevice: View {
    let title: String
    public init(_ title: String = "Device Info") {
        self.title = title
    }
    
    @State private var wifiName: String?
    
//    @State private var coordinate: CLLocationCoordinate2D?
//    @State private var address: String?
//    @State private var isLoadingLocation = false
//    let asyncLocationManager = AsyncLocationManager(desiredAccuracy: .nearestTenMetersAccuracy)
    
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
//                SimpleCell("当前地址") {
//                    if isLoadingLocation {
//                        ProgressView()
//                    }else if let address {
//                        Text(address)
//                            .font(.callout)
//                            .foregroundColor(.secondary)
//                    }
//                }
//                SimpleCell("经纬度") {
//                    if isLoadingLocation {
//                        ProgressView()
//                    }else {
//                        VStack(alignment: .trailing) {
//                            Text("Lat: \(coordinate?.latitude ?? 0)")
//                            Text("Lon: \(coordinate?.longitude ?? 0)")
//                        }
//                        .foregroundStyle(.secondary)
//                        .font(.callout)
//                    }
//                }
            }
            #endif
            
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
                Button {
                    SimpleDevice.playWatchHaptic(.directionUp)
                } label: {
                    Label("Haptic震动 - ⬆️ 增加", systemImage: "iphone.gen3.radiowaves.left.and.right")
                }
                Button {
                    SimpleDevice.playWatchHaptic(.directionDown)
                } label: {
                    Label("Haptic震动 - ⬇️ 减少", systemImage: "iphone.gen3.radiowaves.left.and.right")
                }
                Button {
                    SimpleDevice.playWatchHaptic(.retry)
                } label: {
                    Label("Haptic震动 - 🔁 重试", systemImage: "iphone.gen3.radiowaves.left.and.right")
                }
                Button {
                    SimpleDevice.playWatchHaptic(.start)
                } label: {
                    Label("Haptic震动 - ▶️ 开始", systemImage: "iphone.gen3.radiowaves.left.and.right")
                }
                Button {
                    SimpleDevice.playWatchHaptic(.stop)
                } label: {
                    Label("Haptic震动 - 🛑 停止", systemImage: "iphone.gen3.radiowaves.left.and.right")
                }
            }
            #endif
        }
        .navigationTitle(title)
//        .task {
//            #if !os(macOS)
//            let status = await asyncLocationManager.requestPermission(with: .whenInUsage)
//            if status == .authorizedAlways || status == .authorizedWhenInUse {
//                print("地点权限：\(status)")
//                #if !os(watchOS)
//                self.wifiName = SimpleDevice.wifiInfo()
//                #endif
//                isLoadingLocation = true
//                if let result = try? await asyncLocationManager.requestLocation(),
//                   case let .didUpdateLocations(locations) = result,
//                   let location = locations.first {
//                    print("请求地点：\(result)")
//                    self.coordinate = location.coordinate
//                    
//                    if let place = await location.coordinate.toPlace(locale: .zhHans) {
//                        isLoadingLocation = false
//                        self.address = place.toFullAddress()
//                    }else {
//                        isLoadingLocation = false
//                    }
//                }else {
//                    isLoadingLocation = false
//                }
//            }
//            #endif
//        }
    }
}

#Preview {
    NavigationView {
        DemoSimpleDevice()
    }
#if canImport(UIKit)
    .navigationViewStyle(.stack)
    #endif
}
