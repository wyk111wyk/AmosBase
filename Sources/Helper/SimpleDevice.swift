//
//  File.swift
//  
//
//  Created by AmosFitness on 2023/11/10.
//

import Foundation
import SwiftUI
import AVFoundation
#if os(iOS)
import SystemConfiguration.CaptiveNetwork
import CoreLocation
#endif
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
import IOKit
#endif
#if canImport(WatchKit)
import WatchKit
#endif
#if canImport(CoreTelephony)
import CoreTelephony
#endif
#if canImport(WatchKit)
import WatchKit
#endif

public class SimpleDevice: NSObject {
    public static func playSuccessHaptic() {
#if os(iOS)
        playNotificationHaptic(.success)
#elseif os(watchOS)
        playWatchHaptic(.success)
#endif
    }
    
    public static func playFailureHaptic() {
#if os(iOS)
        playNotificationHaptic(.error)
#elseif os(watchOS)
        playWatchHaptic(.failure)
#endif
    }
    
    public static func playHeavyHaptic() {
#if os(iOS)
        playFeedbackHaptic(.heavy)
#elseif os(watchOS)
        playWatchHaptic(.notification)
#endif
    }
    
    public static func playMediumHaptic() {
#if os(iOS)
        playFeedbackHaptic(.medium)
#elseif os(watchOS)
        playWatchHaptic(.retry)
#endif
    }
    
    public static func playLightHaptic() {
#if os(iOS)
        playFeedbackHaptic(.light)
#elseif os(watchOS)
        playWatchHaptic(.click)
#endif
    }
    
    /// 打开系统设置 -  本App的页面
    ///
    /// 使用 UIApplication.shared.open(url)
    public static func openSystemSetting() {
        #if os(iOS)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        #elseif os(macOS)
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.general") {
            NSWorkspace.shared.open(url)
        }
        #endif
    }
    
    #if os(iOS)
    /// 设备进行震动 -  成功、失败
    ///
    /// 可自动判断设备是否支持
    public static func playNotificationHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    /// 设备进行震动 - 强、弱
    ///
    /// 可自动判断设备是否支持
    public static func playFeedbackHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    #elseif canImport(WatchKit)
    
    /// 手表进行震动和声音 -  根据传入状态
    ///
    /// 该方法仅支持手表：notification、directionUp、directionDown、success、failure、retry、start、stop、click
    public static func playWatchHaptic(_ type: WKHapticType) {
        WKInterfaceDevice.current().play(type)
    }
    #endif
    
    #if os(iOS)
    
    ///获取设备类型 iPhone
    public static func getModel() -> String {
        return UIDevice.current.model
    }
    
    ///获取系统语言
    public static func getSystemLanguage() -> String {
        return Locale.current.identifier
    }
    
    
    class public override func description() -> String {
        var message = "系统版本: \(getSystemVersion())\n"
        message += "系统名称: \(getSystemName())\n"
        message += "设备类型: \(getModel())\n"
        message += "设备型号全称: \(getFullModel())\n"
        message += "总磁盘: \(getDiskTotalSize())\n"
        message += "可用磁盘: \(getAvalibleDiskSize())\n"
        message += "当前设备IP: \(getDeviceIP() ?? "")\n"
        message += "应用名称: \(getAppName() ?? "")\n"
        message += "应用版本: \(getAppVersion() ?? "")"
        
//        print(message)
        return message
    }
    
    /*
     在iOS 13之前，只要能够连接上WiFi就可以获取到WiFi信息。
     在iOS 13之后，需要为应用授权获取WiFi信息的能力，还要授权获取位置，才能获取到WiFi信息。

     为应用授权获取WiFi信息的能力 Targets -> Capabilities -> Access WiFi Information
     
     授权获取位置:
     "NSLocationAlwaysUsageDescription"
     "NSLocationAlwaysAndWhenInUseUsageDescription"
     "NSLocationWhenInUseUsageDescription"
     
     {
         BSSID = "a4:39:b3:c7:4a:10";
         SSID = "Amos Studio";
         SSIDDATA = {length = 11, bytes = 0x416d6f732053747564696f};
     }
     */
    /// 获取正在连接的wifi的名称，必需要位置权限
    public static func wifiInfo() -> String? {
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    debugPrint(interfaceInfo)
                    return interfaceInfo["SSID"] as? String
                }
            }
        }
        return nil
    }
#endif
}

extension SimpleDevice {
    ///获取系统名称 iOS
    public static func getSystemName() -> String {
        #if os(iOS)
        UIDevice.current.systemName
        #elseif os(macOS)
        Host.current().localizedName ?? "macOS"
        #elseif os(watchOS)
        WKInterfaceDevice.current().systemName
        #endif
    }
    
    ///获取系统版本 15.0
    public static func getSystemVersion() -> String {
        #if os(iOS)
        return UIDevice.current.systemVersion
        #elseif os(macOS)
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        let versionString = "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
        return versionString
        #elseif os(watchOS)
        WKInterfaceDevice.current().systemVersion
        #endif
    }
    
    /// 获取设备型号
    ///
    /// iPhone / iPad / Airpods / Touch / Apple Watch / AirTag
    public static func getFullModel() -> String {
        deviceName()
    }
    
    public enum DeviceSize {
        case small, medium, large, iPad
    }
    /// 获取 iPhone 的尺寸级别
    public static func deviceSize() -> DeviceSize {
        let deviceName = deviceName()
        if deviceName.contains("iPhone") {
            if deviceName.contains("SE") || deviceName.contains("mini") {
                return .small
            }else if deviceName.contains("Max") {
                return .large
            }else {
                return .medium
            }
        }else if deviceName.contains("Watch") {
            return .small
        }else if deviceName.contains("iPad") {
            return .iPad
        }
        return .large
    }
    
    ///获取总磁盘 931.5 GB
    public static func getDiskTotalSize() -> String {
        fileSizeToString(fileSize: getTotalDiskSize())
    }
    
    ///获取可用磁盘 282.0 GB
    public static func getAvalibleDiskSize() -> String {
        fileSizeToString(fileSize: getAvailableDiskSize())
    }
    
    /// 获取当前设备IP
    public static func getDeviceIP() -> String? {
        deviceIP()
    }
    
    /// 应用名称
    public static func getAppName() -> String? {
        appName()
    }
    
    /// 应用版本
    public static func getAppVersion(withBundle: Bool = true) -> String? {
        appVersion(withBundle: withBundle)
    }
    
    /// 设备标识码
    public static func getDeviceIdentifier() -> String? {
        #if os(iOS)
        UIDevice.current.identifierForVendor?.uuidString
        #elseif os(macOS)
        let platformExpert = IOServiceGetMatchingService(
            kIOMainPortDefault,
            IOServiceMatching("IOPlatformExpertDevice")
        )
            
        guard platformExpert != 0 else {
            return nil
        }
        
        guard let uuid = IORegistryEntryCreateCFProperty(
            platformExpert,
            kIOPlatformUUIDKey as CFString,
            kCFAllocatorDefault,
            0
        )?.takeRetainedValue() as? String else {
            IOObjectRelease(platformExpert)
            return nil
        }
        
        IOObjectRelease(platformExpert)
        return uuid
        #else
        return nil
        #endif
    }
    
    /// 是否我自己的设备
    public static func isAmosDevice() -> Bool {
        guard let deviceIdentifier = getDeviceIdentifier() else {
            return false
        }
        
//        debugPrint("deviceIdentifier: " + deviceIdentifier)
        
        let myDevice = [
            "35138123-122A-4E76-AD0C-9394FD458D6F", //iPhone 15 Pro Max
            "E520AEAA-ECFA-4504-841E-8592D5A3446D", //iPad Pro
            "ECA17554-E72E-5FE4-A2F0-99897557EB1A", //Mac mini M4
            "9B0B1092-30C7-45BF-B8CE-99FCE5B581C4" //Aurora 13 mini
        ]
        return myDevice.contains(deviceIdentifier)
    }
    
    #if !os(watchOS)
    /// 检查是否有可用的摄像头
    public static func hasCamera() -> Bool {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )
        return !discoverySession.devices.isEmpty
    }
    #endif
    
    /// 检查设备是否支持 iCloud
    public static func hasiCloud() -> Bool {
        // ubiquityIdentityToken 在 watchOS 上无法使用
        if let _ = FileManager.default.ubiquityIdentityToken {
            return true
        } else {
            return false
        }
    }
}

///private
extension SimpleDevice {
    
    ///获取应用名称
    private static func appName() -> String? {
        if let name = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            return name
        }else {
            return nil
        }
    }
    
    ///获取应用的版本号
    private static func appVersion(withBundle: Bool) -> String? {
        let infoDictionary = Bundle.main.infoDictionary
        var version = ""
        
        guard let shortVersion = infoDictionary?["CFBundleShortVersionString"] as? String else {
            return nil
        }
        version += shortVersion
        
        if withBundle {
            guard let bundleVersion = infoDictionary?["CFBundleVersion"] as? String else {
                return nil
            }
            version += ".\(bundleVersion)"
        }
        
        return version
    }
    
    /// 获取当前设备IP
    private static func deviceIP() -> String? {
        var addresses = [String]()
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while (ptr != nil) {
                let flags = Int32(ptr!.pointee.ifa_flags)
                var addr = ptr!.pointee.ifa_addr.pointee
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            if let address = String(validatingUTF8:hostname) {
                                addresses.append(address)
                            }
                        }
                    }
                }
                ptr = ptr!.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        if let ipStr = addresses.first {
            return ipStr
        } else {
            return nil
        }
    }
    
    
    ///获取设备名称 
    ///https://gist.github.com/adamawolf/3048717
    private static func deviceName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
            
        case "iPod1,1":                             return "1st Gen iPod Touch"
        case "iPod2,1":                             return "2st Gen iPod Touch"
        case "iPod3,1":                             return "3st Gen iPod Touch"
        case "iPod4,1":                             return "4st Gen iPod Touch"
        case "iPod5,1":                             return "5st Gen iPod Touch"
        case "iPod7,1":                             return "6st Gen iPod Touch"
        case "iPod9,1":                             return "7st Gen iPod Touch"
            
            ///iphone
        case "iPhone1,1":                           return "iPhone 1G"
        case "iPhone1,2":                           return "iPhone 3G"
        case "iPhone2,1":                           return "iPhone 3GS"
        case "iPhone3,1","iPhone3,2","iPhone3,3":   return "iPhone 4"
        case "iPhone4,1":                           return "iPhone 4S"
        case "iPhone5,1","iPhone5,2":               return "iPhone 5"
        case "iPhone5,3","iPhone5,4":               return "iPhone 5C"
        case "iPhone6,1","iPhone6,2":               return "iPhone 5S"
        case "iPhone7,1":                           return "iPhone 6 Plus"
        case "iPhone7,2":                           return "iPhone 6"
        case "iPhone8,1":                           return "iPhone 6s"
        case "iPhone8,2":                           return "iPhone 6s Plus"
        case "iPhone8,4":                           return "iPhone SE"
        case "iPhone9,1","iPhone9,3":               return "iPhone 7"
        case "iPhone9,2","iPhone9,4":               return "iPhone 7 Plus"
        case "iPhone10,1","iPhone10,4":             return "iPhone 8"
        case "iPhone10,2","iPhone10,5":             return "iPhone 8 Plus"
        case "iPhone10,3","iPhone10,6":             return "iPhone X"
        case "iPhone11,8":                          return "iPhone XR"
        case "iPhone11,2":                          return "iPhone XS"
        case "iPhone11,4","iPhone11,6":             return "iPhone XS Max"
        case "iPhone12,1":                          return "iPhone 11"
        case "iPhone12,3":                          return "iPhone 11 Pro"
        case "iPhone12,5":                          return "iPhone 11 Pro Max"
        case "iPhone12,8":                          return "iPhone SE 2"
        case "iPhone13,1":                          return "iPhone 12 mini"
        case "iPhone13,2":                          return "iPhone 12"
        case "iPhone13,3":                          return "iPhone 12 Pro"
        case "iPhone13,4":                          return "iPhone 12 Pro Max"
        case "iPhone14,4":                          return "iPhone 13 mini"
        case "iPhone14,5":                          return "iPhone 13"
        case "iPhone14,2":                          return "iPhone 13 Pro"
        case "iPhone14,3":                          return "iPhone 13 Pro Max"
        case "iPhone14,6":                          return "iPhone SE (3rd generation)"
        case "iPhone14,7":                          return "iPhone 14"
        case "iPhone14,8":                          return "iPhone 14 Plus"
        case "iPhone15,2":                          return "iPhone 14 Pro"
        case "iPhone15,3":                          return "iPhone 14 Pro Max"
        case "iPhone15,4":                          return "iPhone 15"
        case "iPhone15,5":                          return "iPhone 15 Plus"
        case "iPhone16,1":                          return "iPhone 15 Pro"
        case "iPhone16,2":                          return "iPhone 15 Pro Max"
        case "iPhone17,1":                          return "iPhone 16 Pro"
        case "iPhone17,2":                          return "iPhone 16 Pro Max"
        case "iPhone17,3":                          return "iPhone 16"
        case "iPhone17,4":                          return "iPhone 16 Plus"
            
            ///iPad
        case "iPad1,1":                             return "iPad"
        case "iPad1,2":                             return "iPad 3G"
        case "iPad2,1":                             return "iPad 2 (WiFi)"
        case "iPad2,2":                             return "iPad 2"
        case "iPad2,3":                             return "iPad 2 (CDMA)"
        case "iPad2,4":                             return "iPad 2"
        case "iPad3,1":                             return "iPad 3 (WiFi)"
        case "iPad3,2":                             return "iPad 3 (GSM+CDMA)"
        case "iPad3,3":                             return "iPad 3"
        case "iPad3,4":                             return "iPad 4 (WiFi)"
        case "iPad3,5":                             return "iPad 4"
        case "iPad3,6":                             return "iPad 4 (GSM+CDMA)"
        case "iPad6,11":                            return "iPad 5 (WiFi)"
        case "iPad6,12":                            return "iPad 5 (Cellular)"
        case "iPad7,5","iPad7,6":                   return "iPad 6"
        case "iPad11,6","iPad11,7":                 return "iPad 8"
        case "iPad12,1","iPad12,2":                 return "iPad 9"
        case "iPad13,18","iPad13,19":               return "iPad 10"
            
        case "iPad4,1":                             return "iPad Air (WiFi)"
        case "iPad4,2":                             return "iPad Air (Cellular)"
        case "iPad5,3","iPad5,4":                   return "iPad Air 2"
        case "iPad11,3","iPad11,4":                 return "iPad Air 3"
        case "iPad13,1","iPad13,2":                 return "iPad Air 4"
        case "iPad13,16","iPad13,17":               return "iPad Air 5"
        case "iPad14,8","iPad14,9":                 return "iPad Air 6"
        case "iPad14,10","iPad14,11":               return "iPad Air 7"
            
        case "iPad2,5":                             return "iPad mini (WiFi)"
        case "iPad2,6":                             return "iPad mini"
        case "iPad2,7":                             return "iPad mini (GSM+CDMA)"
        case "iPad4,4":                             return "iPad mini 2 (WiFi)"
        case "iPad4,5":                             return "iPad mini 2 (Cellular)"
        case "iPad4,6":                             return "iPad mini 2"
        case "iPad4,7","iPad4,8","iPad4,9":         return "iPad mini 3"
        case "iPad5,1":                             return "iPad mini 4 (WiFi)"
        case "iPad5,2":                             return "iPad mini 4 (LTE)"
        case "iPad11,1","iPad11,2":                 return "iPad mini 5"
        case "iPad14,1","iPad14,2":                 return "iPad mini 6"
            
        case "iPad6,3","iPad6,4":                   return "iPad Pro 9.7"
        case "iPad7,3":                             return "iPad Pro 10.5 (WiFi)"
        case "iPad7,4":                             return "iPad Pro 10.5 (Cellular)"
        case "iPad8,1","iPad8,2","iPad8,3","iPad8,4":           return "iPad Pro 11"
        case "iPad8,9","iPad8,10":                              return "iPad Pro 11 2nd"
        case "iPad13,4","iPad13,5","iPad13,6","iPad13,7":       return "iPad Pro 11 3rd"
        case "iPad14,3","iPad14,4":                             return "iPad Pro 11 4th"
        case "iPad16,3","iPad16,4":                             return "iPad Pro 11 5th"
            
        case "iPad6,7", "iPad6,8":                              return "iPad Pro 12.9"
        case "iPad7,1":                                         return "iPad Pro 12.9 2nd (WiFi)"
        case "iPad7,2":                                         return "iPad Pro 12.9 2nd (Cellular)"
        case "iPad8,5","iPad8,6","iPad8,7","iPad8,8":           return "iPad Pro 12.9 3rd"
        case "iPad8,11","iPad8,12":                             return "iPad Pro 12.9 4th"
        case "iPad13,8","iPad13,9","iPad13,10","iPad13,11":     return "iPad Pro 12.9 5th"
        case "iPad14,5","iPad14,6":                             return "iPad Pro 12.9 6th"
        case "iPad16,5","iPad16,6":                             return "iPad Pro 12.9 7th"
            
            //Apple Watch
        case "Watch1,1","Watch1,2":                             return "Apple Watch (1st generation)"
        case "Watch2,6","Watch2,7":                             return "Apple Watch Series 1"
        case "Watch2,3","Watch2,4":                             return "Apple Watch Series 2"
        case "Watch3,1","Watch3,2","Watch3,3","Watch3,4":       return "Apple Watch Series 3"
        case "Watch4,1","Watch4,2","Watch4,3","Watch4,4":       return "Apple Watch Series 4"
        case "Watch5,1","Watch5,2","Watch5,3","Watch5,4":       return "Apple Watch Series 5"
        case "Watch5,9","Watch5,10","Watch5,11","Watch5,12":    return "Apple Watch SE"
        case "Watch6,1","Watch6,2","Watch6,3","Watch6,4":       return "Apple Watch Series 6"
        case "Watch6,6","Watch6,7","Watch6,8","Watch6,9":       return "Apple Watch Series 7"
        case "Watch6,10","Watch6,11","Watch6,12","Watch6,13":   return "Apple Watch SE 2"
        case "Watch6,14","Watch6,16":               return "Apple Watch Series 8 41mm"
        case "Watch6,15","Watch6,17":               return "Apple Watch Series 8 45mm"
        case "Watch7,1","Watch7,3":                 return "Apple Watch Series 9 41mm"
        case "Watch7,2","Watch7,4":                 return "Apple Watch Series 9 45mm"
        case "Watch7,6","Watch7,8":                 return "Apple Watch Series 10 42mm"
        case "Watch7,7","Watch7,9":                 return "Apple Watch Series 10 46mm"
            
        case "Watch6,18":                                       return "Apple Watch Ultra"
        case "Watch7,5":                                        return "Apple Watch Ultra 2"
            
            ///AppleTV
        case "AppleTV1,1":                                      return "Apple TV 1st"
        case "AppleTV2,1":                                      return "Apple TV 2nd"
        case "AppleTV3,1","AppleTV3,2":                         return "Apple TV 3rd"
        case "AppleTV5,3":                                      return "Apple TV 4th"
        case "AppleTV6,2":                                      return "Apple TV 4K"
        case "AppleTV11,1":                                      return "Apple TV 4K 2nd"
            
            ///AirPods
        case "AirPods1,1":                                      return "AirPods 1st"
        case "AirPods1,2","AirPods2,1":                         return "AirPods 2nd"
        case "AirPods1,3","Audio2,1":                           return "AirPods 3rd"
        case "iProd8,1","AirPods2,2","AirPodsPro1,1":           return "AirPods Pro"
        case "AirPodsPro1,2":                                   return "AirPods Pro 2nd"
        case "iProd8,6","AirPodsMax1,1":                        return "AirPods Max"
            
            /// AurTag
        case "AirTag1,1":                                       return "AirTag"
            
            ///Simulator
        case "i386":                                return "Simulator(i386)"
        case "x86_64":                              return "Simulator(x86_64)"
        case "arm64":                               return "Simulator(arm64)"
            
        default:                                    return "unknow device"
        }
    }
    
    private static func blankof<T>(type:T.Type) -> T {
        let ptr = UnsafeMutablePointer<T>.allocate(capacity: MemoryLayout<T>.size)
        let val = ptr.pointee
        return val
    }
    
    /// 磁盘总大小
    private static func getTotalDiskSize() -> Int64 {
        var fs = blankof(type: statfs.self)
        if statfs("/var",&fs) >= 0{
            return Int64(UInt64(fs.f_bsize) * fs.f_blocks)
        }
        return -1
    }
    
    /// 磁盘可用大小
    private static func getAvailableDiskSize() -> Int64 {
        var fs = blankof(type: statfs.self)
        if statfs("/var",&fs) >= 0{
            return Int64(UInt64(fs.f_bsize) * fs.f_bavail)
        }
        return -1
    }
    
    /// 将大小转换成字符串用以显示
    private static func fileSizeToString(fileSize:Int64) -> String {
        
        let fileSize1 = CGFloat(fileSize)
        
        let KB:CGFloat = 1024
        let MB:CGFloat = KB*KB
        let GB:CGFloat = MB*KB
        
        if fileSize < 10 {
            return "0 B"
            
        } else if fileSize1 < KB {
            return "< 1 KB"
        } else if fileSize1 < MB {
            return String(format: "%.1f KB", CGFloat(fileSize1)/KB)
        } else if fileSize1 < GB {
            return String(format: "%.1f MB", CGFloat(fileSize1)/MB)
        } else {
            return String(format: "%.1f GB", CGFloat(fileSize1)/GB)
        }
    }
}
