//
//  File.swift
//  
//
//  Created by AmosFitness on 2023/11/22.
//

import Foundation
import CoreLocation
import OSLog

private let mylog = Logger(subsystem: "SimpleLocation", category: "AmosBase")

public class SimpleLocation {
    private var simpleLocation: SimpleLocationHelper
    public init() {
        self.simpleLocation = .init(needLocation: true){_ in}
    }
    
    deinit {
        print("deinit SimpleLocation")
    }
    
    @discardableResult
    public func requireAuthorization() async -> CLAuthorizationStatus {
        return await withCheckedContinuation({ continuation in
            simpleLocation = .init(statusCall: { content in
                continuation.resume(returning: content.status)
            })
            simpleLocation.requireAuthorization()
        })
    }
    
    public func requireCurrentLocation() async -> CLLocation? {
        return await withCheckedContinuation({ continuation in
            simpleLocation = .init(needLocation: true) { content in
                if let location = content.location {
                    continuation.resume(returning: location)
                }
            }
            simpleLocation.requireAuthorization()
        })
    }
}

public final class SimpleLocationHelper: NSObject {
    var locationManager: CLLocationManager? = nil
    public typealias callContent = (status: CLAuthorizationStatus, location: CLLocation?)
    var statusCall: ((callContent) -> Void)? = nil
    var authStatus: CLAuthorizationStatus = .notDetermined
    var needLocation: Bool = false
    
    public override init() {
        super.init()
    }
    
    @discardableResult
    public convenience init(needLocation: Bool = false,
                            statusCall: @escaping (callContent) -> Void) {
        self.init()
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        self.statusCall = statusCall
        self.needLocation = needLocation
    }
    
    public func requireAuthorization() {
        guard let locationManager else { return }
        mylog.log("开始请求位置权限")
        
        let status = locationManager.authorizationStatus
        authStatus = status
        if status == .notDetermined {
            // 尚未设置定位权限
            locationManager.requestWhenInUseAuthorization()
        } else if status == .denied || status == .restricted {
            // 拒绝权限
            statusCall?((authStatus, nil))
        } else {
            // 已授权
            statusCall?((authStatus, nil))
            if needLocation {
                requireCurrentLocation()
            }
        }
    }
    
    public func requireCurrentLocation() {
        mylog.log("开始获取当前位置")
        locationManager?.requestLocation()
    }
}

extension SimpleLocationHelper: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mylog.log("成功获取当前设备位置")
        print(manager.location?.coordinate ?? "N/A")
        statusCall?((authStatus, locations.first))
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("获取位置错误：\(error.localizedDescription)")
        mylog.error("获取位置错误：\(error.localizedDescription)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mylog.log("did Change Authorization")
        authStatus = status
        statusCall?((authStatus, nil))
        if needLocation && (status == .authorizedWhenInUse || status == .authorizedAlways) {
            requireCurrentLocation()
        }
    }
    
    // 只要初始化就会读取该方法
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authStatus = manager.authorizationStatus
        mylog.log("locationManager Did Change Authorization: \(self.authStatus.rawValue)")
        statusCall?((authStatus, nil))
        
        if authStatus == .notDetermined {
            requireAuthorization()
        }
        if needLocation && (authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways) {
            requireCurrentLocation()
        }
    }
}
