//
//  File.swift
//  
//
//  Created by AmosFitness on 2023/11/13.
//

import Foundation
import SwiftUI

public struct SimpleMapShare {
    public enum MapShareMode {
        case navi, position
    }
    
    public enum MapShareType: String, CaseIterable, Identifiable {
        public var id: String { self.mapName }
        case appleMap, baiduMap, aMap, googleMap, qqMap
        var mapName: String {
            switch self {
            case .appleMap:
                return "Apple地图"
            case .baiduMap:
                return "百度地图"
            case .aMap:
                return "高德地图"
            case .googleMap:
                return "谷歌地图"
            case .qqMap:
                return "腾讯地图"
            }
        }
    }
    
    let title: String
    let content: String
    let lat: Double
    let long: Double
    let address: String
    let mode: MapShareMode
    
    public init(mode: MapShareMode = .navi) {
        self.title = "AK23自助健身房"
        self.content = "24小时营业"
        self.lat = 29.721462
        self.long = 120.254904
        self.address = "诸暨市暨阳街道滨江北路45-3号"
//        self.address = ""
        self.mode = mode
    }
    
    public init(title: String,
         content: String = "ak23",
         lat: Double,
         long: Double,
         address: String,
         mode: MapShareMode = .position) {
        self.title = title
        self.content = content
        self.lat = lat
        self.long = long
        self.address = address
        self.mode = mode
    }
    
    func getLink(_ mapType: MapShareType) -> URL? {
        var urlComponents = URLComponents()
        
        switch mapType {
        case .appleMap:
            /* https://developer.apple.com/library/archive/featuredarticles/iPhoneURLScheme_Reference/MapLinks/MapLinks.html
             */
            urlComponents.scheme = "maps"
            urlComponents.host = ""
            urlComponents.queryItems = [
                URLQueryItem(name: "q", value: title),
                URLQueryItem(name: "sll", value: "\(lat),\(long)")]
//            }
        case .baiduMap:
            /* https://lbs.baidu.com/faq/api?title=webapi/uri/ios
             */
            urlComponents.scheme = "baidumap"
            urlComponents.host = "map"
            if self.mode == .navi {
                urlComponents.path = "/direction"
                urlComponents.queryItems = [
                    URLQueryItem(name: "origin", value: "我的位置"),
                    URLQueryItem(name: "destination", value: "\(lat),\(long)"),
                    URLQueryItem(name: "destination", value: title),
                    URLQueryItem(name: "coord_type", value: "wgs84"),
                    URLQueryItem(name: "mode", value: "driving")]
            }else {
                if address.isEmpty {
                    urlComponents.path = "/marker"
                    urlComponents.queryItems = [
                        URLQueryItem(name: "location", value: "\(lat),\(long)"),
                        URLQueryItem(name: "title", value: title),
                        URLQueryItem(name: "coord_type", value: "wgs84"),
                        URLQueryItem(name: "content", value: content)]
                }else {
                    urlComponents.path = "/geocoder"
                    urlComponents.queryItems = [
                        URLQueryItem(name: "address", value: address),
                        URLQueryItem(name: "destination", value: title)]
                }
            }
            urlComponents.queryItems?.append(URLQueryItem(name: "src", value: "ios.akstudio.amosbase"))
        case .aMap:
            urlComponents.scheme = "iosamap"
            if self.mode == .navi {
                // https://lbs.amap.com/api/amap-mobile/guide/ios/navi
                urlComponents.host = "navi"
                urlComponents.queryItems = [
                    URLQueryItem(name: "poiname", value: title),
                    URLQueryItem(name: "poiid", value: "BGVIS"),
                    URLQueryItem(name: "lat", value: "\(lat)"),
                    URLQueryItem(name: "lon", value: "\(long)"),
                    URLQueryItem(name: "dev", value: "0")]
            }else {
                if address.isEmpty {
                    // https://lbs.amap.com/api/amap-mobile/guide/ios/marker
                    urlComponents.host = "viewMap"
                    urlComponents.queryItems = [
                        URLQueryItem(name: "poiname", value: title),
                        URLQueryItem(name: "lat", value: "\(lat)"),
                        URLQueryItem(name: "lon", value: "\(long)")]
                }else {
                    // https://lbs.amap.com/api/amap-mobile/guide/ios/search
                    urlComponents.host = "poi"
                    urlComponents.queryItems = [
                        URLQueryItem(name: "name", value: title),
                        URLQueryItem(name: "lat", value: "\(lat)"),
                        URLQueryItem(name: "lon", value: "\(long)"),
                        URLQueryItem(name: "dev", value: "1")]
                }
            }
            urlComponents.queryItems?.append(URLQueryItem(name: "sourceApplication", value: "ios.akstudio.amosbase"))
        case .googleMap:
            // https://developers.google.com/maps/documentation/urls/ios-urlscheme
            urlComponents.scheme = "comgooglemaps-x-callback"
            if self.mode == .navi {
                urlComponents.queryItems = [
                    URLQueryItem(name: "x-source", value: "AK23"),
                    URLQueryItem(name: "x-success", value: "urlScheme"),
                    URLQueryItem(name: "saddr", value: ""),
                    URLQueryItem(name: "daddr", value: "\(lat),\(long)"),
                    URLQueryItem(name: "directionsmode", value: "driving")
                ]
            }else {
                if address.isEmpty {
                    urlComponents.queryItems = [
                        URLQueryItem(name: "center", value: "\(lat),\(long)"),
                        URLQueryItem(name: "zoom", value: "12"),
                        URLQueryItem(name: "views", value: "traffic")
                    ]
                }else {
                    urlComponents.queryItems = [
                        URLQueryItem(name: "q", value: address),
                        URLQueryItem(name: "center", value: "\(lat),\(long)"),
                        URLQueryItem(name: "zoom", value: "12"),
                        URLQueryItem(name: "views", value: "traffic")
                    ]
                }
            }
        case .qqMap:
            // https://lbs.qq.com/webApi/uriV1/uriGuide/uriMobileGuide
            urlComponents.scheme = "qqmap"
            urlComponents.host = "map"
            if self.mode == .navi {
                urlComponents.path = "/routeplan"
                urlComponents.queryItems = [
                    URLQueryItem(name: "type", value: "drive"),
                    URLQueryItem(name: "fromcoord", value: "CurrentLocation"),
                    URLQueryItem(name: "to", value: title),
                    URLQueryItem(name: "tocoord", value: "\(lat),\(long)"),
                    URLQueryItem(name: "referer", value: "NR3BZ-2T7W5-7D3I4-QBE5I-PUHR3-ZNF6S")]
            }else {
                if address.isEmpty {
                    urlComponents.path = "/search"
                    urlComponents.queryItems = [
                        URLQueryItem(name: "keyword", value: title),
                        URLQueryItem(name: "center", value: "\(lat),\(long)"),
                        URLQueryItem(name: "radius", value: "1000"),
                        URLQueryItem(name: "referer", value: "NR3BZ-2T7W5-7D3I4-QBE5I-PUHR3-ZNF6S")]
                }else {
                    urlComponents.path = "/marker"
                    urlComponents.queryItems = [
                        URLQueryItem(name: "title", value: title),
                        URLQueryItem(name: "marker", value: "coord:\(lat),\(long)"),
                        URLQueryItem(name: "addr", value: address),
                        URLQueryItem(name: "referer", value: "NR3BZ-2T7W5-7D3I4-QBE5I-PUHR3-ZNF6S")]
                }
            }
        }
        
        guard let url = urlComponents.url else {
            return URL(string: "")
        }
//        printDebug("跳转地图url：\(url.absoluteString)")
        return url
    }
}

extension SimpleMapShare {
    public func navigationButtons(_ mapTypes: [MapShareType] = MapShareType.allCases) -> some View {
        
        @ViewBuilder
        func buttonView(_ mapType: MapShareType) -> some View {
            if let url = getLink(mapType) {
                Link(destination: url) {
                    HStack {
                        Spacer()
                        Text(LocalizedStringKey(mapType.mapName))
                            .foregroundColor(.accentColor)
                        Spacer()
                    }
                }
            }
        }
        
//        let showTypes = mapTypes.filter { type in
//            type.isInstalled
//        }
        
        return ForEach(mapTypes) {
            buttonView($0)
        }
    }
}
