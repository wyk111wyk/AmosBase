//
//  Location+Extension.swift
//  AmosGym
//
//  Created by 吴昱珂 on 2022/8/9.
//

import Foundation
import CoreLocation
import MapKit
import OSLog

private let mylog = Logger(subsystem: "Location+Extension", category: "AmosBase")

public extension CLPlacemark {
    func toFullAddress() -> String {
        var address = ""
        address += self.administrativeArea ?? ""
        address += self.subAdministrativeArea ?? ""
        address += self.locality ?? ""
        address += self.subLocality ?? ""
        address += self.thoroughfare ?? ""
//        address += self.subThoroughfare ?? ""
        if self.name != self.thoroughfare {
            address += self.name ?? ""
        }
        mylog.log("AppleMap Address: \(address)")
        return address
    }
    
    func toCity() -> String? {
        self.locality
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    public static func !=(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude != rhs.latitude || lhs.longitude != rhs.longitude
    }
}

extension MKCoordinateRegion: Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        return (lhs.center.longitude == rhs.center.longitude) &&
        (lhs.center.latitude == rhs.center.latitude) &&
        (lhs.span.latitudeDelta == rhs.span.latitudeDelta) &&
        (lhs.span.longitudeDelta == rhs.span.longitudeDelta)
    }
    public static func != (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        return (lhs.center.longitude != rhs.center.longitude) ||
        (lhs.center.latitude != rhs.center.latitude) ||
        (lhs.span.latitudeDelta != rhs.span.latitudeDelta) ||
        (lhs.span.longitudeDelta != rhs.span.longitudeDelta)
    }
}

extension MKCoordinateSpan: Equatable {
    public static func ==(lhs: MKCoordinateSpan, rhs: MKCoordinateSpan) -> Bool {
        lhs.latitudeDelta == rhs.latitudeDelta && lhs.longitudeDelta == rhs.longitudeDelta
    }
    public static func !=(lhs: MKCoordinateSpan, rhs: MKCoordinateSpan) -> Bool {
        lhs.latitudeDelta != rhs.latitudeDelta || lhs.longitudeDelta != rhs.longitudeDelta
    }
}

public extension String {
    /// 将地址转换为坐标
    func toCoordinate(region: CLRegion? = nil,
                      locale: Locale = .current) async -> CLLocationCoordinate2D? {
        let place = try? await CLGeocoder().geocodeAddressString(self, in: region, preferredLocale: locale).first
        return place?.location?.coordinate
    }
}

public extension CLLocationCoordinate2D {
    /// longitude 120, latitude 29
    func toAmapString() -> String {
        if self.longitude == 0 && self.latitude == 0 {
            return "N/A"
        }else {
            return "\(self.longitude),\(self.latitude)"
        }
    }
    
    /// 将地点转换为地址
    ///
    /// 使用Apple Map的API
    func toPlace(locale: Locale = .current) async -> CLPlacemark?  {
        let loction: CLLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let places = try? await CLGeocoder().reverseGeocodeLocation(loction, preferredLocale: locale)
        guard let places else {
            return nil
        }
        
        return places.first
    }
    
    /// 两个地点之间的距离 -  单位是 米
    ///
    /// 传入为起点，本体为终点
    func distance(from coordinate: CLLocationCoordinate2D?) -> Double? {
        guard let fromCoordinate = coordinate else {
            return nil
        }
        let start = CLLocation(latitude: fromCoordinate.latitude,
                               longitude: fromCoordinate.longitude)
        let end = CLLocation(latitude: self.latitude,
                             longitude: self.longitude)
        let distance: CLLocationDistance = end.distance(from: start)
        return distance
    }
    
    /// 两个地点之间的距离：xx米
    func meter(from coordinate: CLLocationCoordinate2D? = nil) -> String {
        guard let distance = self.distance(from: coordinate) else {
            return "N/A"
        }
        
        mylog.log("====> 两点间距离是：\(distance)m")
        if distance == 0 {
            return 0.toUnit(unit: UnitLength.meters,
                            option: .providedUnit)
        }else {
            return distance.toUnit(unit: UnitLength.meters,
                                   degit: 1)
        }
    }
    
    #if !os(watchOS)
    /// 计算两点间的所有行车路线
    ///
    /// 不传入起点坐标则默认当前坐标，无坐标则返回nil
    func routes(from coordinate: CLLocationCoordinate2D? = nil) async -> [MKRoute]? {
        var currentCoordinate = CLLocationManager().location?.coordinate
        if coordinate != nil { currentCoordinate = coordinate }
        guard let currentCoordinate else { return nil }
        
        // 起点
        let start = MKMapItem(placemark: MKPlacemark(
            coordinate: currentCoordinate,
            addressDictionary: nil))
        // 目的地
        let destination = MKMapItem(placemark: MKPlacemark(
            coordinate: self,
            addressDictionary: nil))
        
        let directionsRequest = MKDirections.Request()
        directionsRequest.transportType = .automobile
        directionsRequest.source = start
        directionsRequest.destination = destination
        directionsRequest.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: directionsRequest)
        if let routes = try? await directions.calculate().routes {
            return routes
        }else {
            return nil
        }
    }
    
    /// 计算两点间的推荐行车路线（一条）
    ///
    /// 不传入起点坐标则默认当前坐标，无坐标则返回nil
    func route(from coordinate: CLLocationCoordinate2D? = nil) async -> MKRoute? {
        if let route = await self.routes(from: coordinate)?.first {
            return route
        }else {
            return nil
        }
    }
    #endif
}
