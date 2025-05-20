//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/9/10.
//

import SwiftUI
import MapKit

public struct SimpleMapMarker: Hashable {
    public let title: String
    public let systemIcon: String?
    public let color: Color
    public let lat: Double
    public let long: Double
    public let place: MKPlacemark?
    
    public init(
        title: String = "Pin",
        systemIcon: String? = nil,
        color: Color = .red,
        location: CLLocation
    ) {
        self.title = title
        self.systemIcon = systemIcon
        self.color = color
        self.lat = location.coordinate.latitude
        self.long = location.coordinate.longitude
        self.place = nil
    }
    
    public init(
        title: String,
        systemIcon: String?,
        color: Color,
        lat: Double,
        long: Double,
        place: MKPlacemark? = nil
    ) {
        self.title = title
        self.systemIcon = systemIcon
        self.color = color
        self.lat = lat
        self.long = long
        self.place = place
    }
    
    public var icon: String {
        systemIcon ?? "mappin"
    }
    
    public var coordinate: CLLocationCoordinate2D {
        .init(latitude: lat, longitude: long)
    }
    
    public var location: CLLocation {
        .init(latitude: lat, longitude: long)
    }
    
    public var item: MKMapItem {
        if let place {
            MKMapItem(placemark: place)
        }else {
            MKMapItem(placemark: .init(coordinate: coordinate))
        }
    }
    
    public var marker: some MapContent {
        Marker(
            title,
            systemImage: icon,
            coordinate: coordinate
        )
        .tint(color)
        .tag(self)
    }
    
    public static var example: SimpleMapMarker {
        .init(
            title: "📍预览地点坐标",
            systemIcon: "mappin",
            color: .blue,
            lat: 29.721462,
            long: 120.254904,
            place: .init(
                coordinate: .init(latitude: 29.721462, longitude: 120.254904),
                addressDictionary: [
                    "locality": "诸暨市",
                    "thoroughfare": "诸暨市滨江北路45号楼上楼下反正找不到"]
            )
        )
    }
}

public extension MKMapItem {
    func toMarker(
        systemIcon: String? = nil,
        color: Color = .blue
    ) -> SimpleMapMarker {
        let place = self.placemark
        return SimpleMapMarker(
            title: place.name ?? place.toFullAddress(),
            systemIcon: systemIcon,
            color: color,
            lat: place.coordinate.latitude,
            long: place.coordinate.longitude,
            place: place
        )
    }
}
