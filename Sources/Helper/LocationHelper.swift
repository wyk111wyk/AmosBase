//
//  File.swift
//  
//
//  Created by AmosFitness on 2023/11/9.
//

import Foundation
import CoreLocation
import MapKit
import OSLog

private let mylog = Logger(subsystem: "LocationHelper", category: "AmosBase")
public class LocationHelper: NSObject {
    let manager: CLLocationManager = CLLocationManager()
    
    @discardableResult
    override init() {
        super.init()
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        manager.delegate = self
        manager.requestLocation()
    }
    
    func currentLocation() -> CLLocationCoordinate2D? {
        self.manager.location?.coordinate
    }
}

extension LocationHelper: CLLocationManagerDelegate {
    //MARK: - 获取定位后的经纬度
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loction = locations.last {
            mylog.log("定位成功：latitude: \(loction.coordinate.latitude) longitude:\(loction.coordinate.longitude)")
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        mylog.error("定位失败:\(error.localizedDescription)")
    }
}
