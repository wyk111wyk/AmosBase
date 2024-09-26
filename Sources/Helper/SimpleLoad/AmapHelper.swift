//
//  File.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/9/25.
//

import Foundation
import CoreLocation
import SwiftUI

// MARK: - 根据经纬度获取地址
internal struct AmapRegeoStore: Codable {
    let status: String
    let regeocode: AmapRegeoCode
    
    var isRequestSuccess: Bool {
        status == "1"
    }
}

public struct AmapRegeoCode: Codable {
    let formatted_address: String // 浙江省绍兴市诸暨市暨阳街道滨江北路下坊门新村
    let addressComponent: AmapAddressComponent
    let pois: [AmapSimplePOI]?
}

public struct AmapAddressComponent: Codable {
    let country: String? // 中国
    let province: String? // 浙江省
    let city: String? // 绍兴市
    let district: String? // 诸暨市
    let township: String? // 暨阳街道
    
    let adcode: String? // 330681 - 可以用来查询天气预报
    let citycode: String? // 0575
    let towncode: String? // 330681001000
}

public struct AmapSimplePOI: Codable {
    let id: String // B0FFM7IGJA
    let direction: String // 南
    let name: String // 绍兴山凹凹营地
    let businessarea: String // 诸暨
    let address: String // 坝内村水库
    let location: String // 120.666054,29.969655
    let distance: String // 106.447
    let type: String // 商务住宅;住宅区;住宅小区
    
    var coordinate: CLLocationCoordinate2D {
        location.toAmapCoordinate()
    }
}

// MARK: - 路径计算 Route
internal struct AmapRouteRootStore: Codable {
    let status: String
    let route: AmapRouteStore
    
    var isRequestSuccess: Bool {
        status == "1"
    }
}

public struct AmapRouteStore: Codable {
    let taxi_cost: String // 预计出租车费用，单位：元
    let paths: [AmapPathStore]
}

public struct AmapPathStore: Codable {
    let distance: String // 方案距离，单位：米
    let restriction: String // 0 代表限行已规避或未限行 1 代表限行无法规避
    let cost: CostStore
    
    struct CostStore: Codable {
        let duration: String // 线路耗时，包括方案总耗时及分段step中的耗时
        let tolls: String // 此路线道路收费，单位：元，包括分段信息
        let toll_distance: String // 收费路段里程，单位：米，包括分段信息
        let traffic_lights: String // 方案中红绿灯个数，单位：个
    }
}

extension AmapRouteStore {
    /// 红绿灯数量
    var wrappedTrafficLights: String {
        paths.first?.cost.traffic_lights ?? "0"
    }
    var wrappedTaxiCost: String {
        "\(taxi_cost)元"
    }
    var wrappedTolls: String {
        "\(paths.first?.cost.tolls ?? "0")元"
    }
    var wrappedDuration: String {
        (Double(paths.first?.cost.duration ?? "0") ?? 0).toDuration()
    }
    var estimatedArriveTime: String {
        let time = Date().addingTimeInterval((Double(paths.first?.cost.duration ?? "0") ?? 0))
        return String(time.formatted(date: .omitted, time: .shortened))
    }
    var wrappedDistance: String {
        (Double(paths.first?.distance ?? "0") ?? 0).toLength()
    }
    var wrappedTollDistance: String {
        let tollDistance = (Double(paths.first?.cost.toll_distance ?? "0") ?? 0)
        return tollDistance.toLength()
    }
}

// MARK: - 天气预报
// MARK: - Weather Base

struct AmapWeatherRoot: Codable {
    let status: String
    let lives: [AmapWeatherLive]
    
    var isRequestSuccess: Bool {
        status == "1"
    }
}

public struct AmapWeatherLive: Codable {
    let province: String
    let city: String
    let adcode: String
    let weather: String
    let winddirection: String
    let windpower: String
    let humidity: String
    let temperature: String
    let reporttime: String
}

extension AmapWeatherLive {
    var tempDisplay: String {
        Double(temperature).wrapped.toTemperature()
    }
}

public extension String {
    func weatherIcon() -> Image {
        if self == "晴" {
            return Image(systemName: "sun.max")
        }else if self == "少云"  || self == "晴间多云" {
            return Image(systemName: "cloud.sun")
        }else if self == "多云"  || self == "阴" {
            return Image(systemName: "smoke")
        }else if ["微风","和风","清风","强风/劲风","疾风","大风"].contains(self) {
            return Image(systemName: "wind")
        }else if ["烈风","风暴","狂爆风","飓风","热带风暴"].contains(self) {
            return Image(systemName: "tropicalstorm")
        }else if self == "龙卷风" {
            return Image(systemName: "tornado")
        }else if self == "霾" {
            return Image(systemName: "aqi.low")
        }else if self == "中度霾" {
            return Image(systemName: "aqi.medium")
        }else if self == "重度霾" || self == "严重霾" {
            return Image(systemName: "aqi.high")
        }else if ["阵雨","雷阵雨","强雷阵雨"].contains(self) {
            return Image(systemName: "cloud.bolt.rain")
        }else if self == "雷阵雨并伴有冰雹" {
            return Image(systemName: "cloud.hail")
        }else if ["雨雪天气","雨夹雪","阵雨夹雪","冻雨"].contains(self) {
            return Image(systemName: "cloud.sleet")
        }else if ["小雨","毛毛雨/细雨","小雨-中雨"].contains(self) {
            return Image(systemName: "cloud.drizzle")
        }else if ["雨","中雨","大雨","中雨-大雨"].contains(self) {
            return Image(systemName: "cloud.rain")
        }else if ["暴雨","大暴雨","特大暴雨","强阵雨","极端降雨","大雨-暴雨","暴雨-大暴雨","大暴雨-特大暴雨"].contains(self) {
            return Image(systemName: "cloud.heavyrain")
        }else if self.contains("雪") {
            return Image(systemName: "snowflake")
        }else if self.contains("雾") {
            return Image(systemName: "cloud.fog")
        }else if ["浮尘","扬沙","沙尘暴","强沙尘暴"].contains(self) {
            return Image(systemName: "sun.dust")
        }else if self == "热" {
            return Image(systemName: "thermometer.sun")
        }else if self == "冷" {
            return Image(systemName: "thermometer.snowflake")
        }else {
            return Image(systemName: "thermometer")
        }
    }
}

// MARK: - Weather All

struct AmapWeatherForecastRoot: Codable {
    let status: String
    let forecasts: [AmapForecastStore]
    
    var isRequestSuccess: Bool {
        status == "1"
    }
}

public struct AmapForecastStore: Codable {
    let province: String?
    let city: String?
    let adcode: String?
    let reporttime: String?
    let casts: [AmapForecast]
}

public struct AmapForecast: Codable {
    let date: String
    let week: String
    let dayweather: String
    let nightweather: String
    let daytemp: String
    let nighttemp: String
    let daywind: String
    let nightwind: String
    let daypower: String
    let nightpower: String
}

extension AmapForecast: Identifiable {
    public var id: String {
        date
    }
    var dayTempDisplay: String {
        Double(daytemp).wrapped.toTemperature()
    }
    var nightTempDisplay: String {
        Double(nighttemp).wrapped.toTemperature()
    }
    var weekDisplay: String {
        var calendar = Calendar.current
        calendar.locale = Locale.current
        #if !os(watchOS)
        let weeks = calendar.weekdaySymbols
        #else
        let weeks = calendar.shortWeekdaySymbols
        #endif
        // ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        var weekNum = Int(week) ?? 0
        if weekNum == 7 { weekNum = 0 }
        return weeks[weekNum]
    }
}

// MARK: - 根据关键词返回简单的相关提示
struct AmapTipRoot: Codable {
    let status: String
    let tips: [AmpTips]
    
    var isRequestSuccess: Bool {
        status == "1"
    }
}

public struct AmpTips: Codable, Identifiable {
    public let id: String // B0FFM7IGJA
    let name: String // 绍兴山凹凹营地
    let district: String // 浙江省绍兴市越城区
    let adcode: String // 330602
    let location: String // 120.666054,29.969655
    let address: String // 坝内村水库
    let typecode: String // 080504
}

extension AmpTips {
    var coordinate: CLLocationCoordinate2D {
        location.toAmapCoordinate()
    }
    
    var fullAddress: String {
        district + address
    }
}

// MARK: - 搜索详细的地点信息
struct AmapSearchRoot: Codable {
    let status: String
    let pois: [AmapSearchPOI]
    
    var isRequestSuccess: Bool {
        status == "1"
    }
}

public struct AmapSearchPOI: Codable, Identifiable {
    let name: String
    public let id: String
    let location: String // poi 经纬度
    let type: String // 所属类型
    let typecode: String // 分类编码
    let pname: String // 所属省份
    let cityname: String // 所属城市
    let adname: String // 所属区县
    var address: String? // 详细地址
    let pcode: String // 所属省份编码
    let citycode: String // 所属城市编码
    let adcode: String // 所属区域编码
    
    let business: AmapBusinessInto?
    let photos: [AmapPhotoInfo]?
    
    struct AmapPhotoInfo: Codable, Identifiable {
        let title: String // 图片介绍
        let url: String // 图片的下载链接
        
        var id: String {
            url
        }
    }
    
    struct AmapBusinessInto: Codable {
        let business_area: String? // 商圈
        let opentime_today: String? // 今日营业时间
        let opentime_weekend: String? // 营业时间描述
        
        let tags: String? // poi 特色内容，目前仅在美食poi下返回
        let rating: String? // 评分,目前仅在餐饮、酒店、景点、影院类 POI 下返回
        let cost: String? // 人均消费，目前仅在餐饮、酒店、景点、影院类 POI 下返回
        let parking_type: String? // 停车场类型（地下、地面、路边），目前仅在停车场类 POI 下返回
        
        let tel: String? // 0575-85626998;13357527379
        let keytag: String // poi 标识，用于确认poi信息类型
        
        var allTelNumber: [String] {
            tel?.components(separatedBy: ";") ?? []
        }
    }
}

extension AmapSearchPOI {
    
    var coordinate: CLLocationCoordinate2D {
        location.toAmapCoordinate()
    }
    
    var fullAddress: String {
        pname + cityname + adname + (address ?? "")
    }
    
    var wrappedType: [String] {
        type.components(separatedBy: ";")
    }
    
    var hasPhotos: Bool {
        photos?.count ?? 0 > 0
    }
    
    var hasPhoneCall: Bool {
        business?.tel?.count ?? 0 > 0
    }
}

// MARK: - 基础转换工具
public protocol HashCode: Hashable, Codable {}
public enum AmapStringType: HashCode {
    case string(String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = try .string(container.decode(String.self))
        } catch DecodingError.typeMismatch {
            throw DecodingError.typeMismatch(
                AmapStringType.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Encoded payload not of an expected type"
                )
            )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let string):
            try container.encode(string)
        }
    }
    
    public var value: String {
        switch self {
        case .string(let string):
            return string
        }
    }
}
