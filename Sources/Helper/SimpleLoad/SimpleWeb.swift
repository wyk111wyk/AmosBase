//
//  File.swift
//
//
//  Created by AmosFitness on 2024/5/16.
//

import Foundation
import CoreLocation

public class SimpleWeb {
    let logger: SimpleLogger = .console(subsystem: "SimpleWeb")
    
    let cacheHelper: SimpleCache?
    var session: URLSession
    
    public init() {
        cacheHelper = try? SimpleCache(isDebuging: false)
        session = URLSession(configuration: URLSessionConfiguration.default)
    }
}

// MARK: - 简单的联网方法
extension SimpleWeb {
    /// 检查网络是否可用
    public func isNetworkAvailable(
        url: URL = URL(string: "https://www.baidu.com")!
    ) async -> Bool {
        let result = try? await loadData(from: url)
        if let result {
            logger.debug("🟢已联网 \(result.count.toDouble.toStorage())", title: "🛜设备网络状况")
            return true
        }else {
            return false
        }
    }
    
    /// 从网址下载图片，先从缓存读取，没有则从网络读取并缓存
    public func loadImage(from key: String) async throws -> SFImage? {
        guard let url = URL(string: key) else { return nil }
        if cacheHelper?.exists(forKey: key) == true,
           let cacheImage = try cacheHelper?.loadImage(forKey: key) {
            logger.debug(key, title: "🛜1.从缓存获取图片")
            return cacheImage
        }
        
        if let data = try await loadData(from: url),
           let image = SFImage(data: data) {
            logger.debug(data.count.toDouble.toStorage(), title: "🛜2.从网络获取图片")
            try cacheHelper?.save(object: data, forKey: key)
            return image
        }else {
            logger.debug("3.无法从网络或缓存获取图片")
            return nil
        }
    }
    
    /// 从网址下载数据
    public func loadData(from url: URL?) async throws -> Data? {
        do {
            guard let url else { return nil }
            let (data, _) = try await session.data(from: url)
            return data
        }catch {
            logger.error(error, title: "🛜下载 Data 错误")
            throw error
        }
    }
}

// MARK: - 请求网络指令
extension SimpleWeb {
    public typealias WebResult = (data: Data?, response: URLResponse?)
    
    /// 已知URLRequest，进行网络请求
    public func request(
        urlRequest: URLRequest,
        callbackQueue: DispatchQueue = .main
    ) async throws -> WebResult {
        return try await withCheckedThrowingContinuation(
            { contionuation in
                let task = session.dataTask(
                    with: urlRequest
                ) { (data, response, error) in
                    callbackQueue.async {
                        if let error {
                            debugPrint("🛜网络请求错误：\(error)")
                            contionuation.resume(throwing: error)
                        }else {
//                          data?.toJsonPrint()
                            contionuation.resume(returning: (data, response))
                        }
                    }
                }
                task.resume()
            }
        )
    }
    
    /// 从网络请求数据等基础操作
    public func request(
        method: SimpleRequestMethod,
        url: URLConvertible,
        parameters: [String: String]? = nil,
        headers: [String: String] = [:],
        body: Data? = nil,
        callbackQueue: DispatchQueue = .main
    ) async throws -> WebResult {
        return try await withCheckedThrowingContinuation(
            { contionuation in
                do {
                    let request = SimpleWebRequest(
                        url: url,
                        method: method,
                        parameters: parameters,
                        headers: headers,
                        body: body
                    )
                    if let urlRequest = try request.request() {
                        let task = session.dataTask(
                            with: urlRequest
                        ) { (data, response, error) in
                            callbackQueue.async {
                                if let error {
                                    debugPrint("🛜网络请求错误：\(error)")
                                    contionuation.resume(throwing: error)
                                }else {
//                                    data?.toJsonPrint()
                                    contionuation.resume(returning: (data, response))
                                }
                            }
                        }
                        task.resume()
                    }
                } catch {
                    contionuation.resume(throwing: error)
                }
            })
    }
    
    /// 已知URLRequest，进行网络请求
    /// <调试> 将 type 设置为 String.self 将返回 data 的 JSON 格式
    public func request<T: Codable>(
        urlRequest: URLRequest,
        callbackQueue: DispatchQueue = .main,
        type: T.Type,
        decoder: any DataDecoder = JSONDecoder()
    ) async throws -> T? {
        let result = try await request(
            urlRequest: urlRequest,
            callbackQueue: callbackQueue
        )
        
        guard let data = result.data else {
            throw SimpleError.customError(title: "网络请求错误(\(urlRequest))", msg: "无法获取到数据 Data")
        }
        
        if type.self == String.self {
            return data.toJsonPrint() as? T
        }else {
            return try data.decodeWithError(type: T.self)
        }
    }
    
    /// 请求网络数据并根据格式解码
    /// <调试> 将 type 设置为 String.self 将返回 data 的 JSON 格式
    public func request<T: Codable>(
        method: SimpleRequestMethod,
        url: URLConvertible,
        parameters: [String: String]? = nil,
        headers: [String: String] = [:],
        body: Data? = nil,
        callbackQueue: DispatchQueue = .main,
        type: T.Type,
        decoder: any DataDecoder = JSONDecoder()
    ) async throws -> T? {
        let result = try await request(
            method: method,
            url: url,
            parameters: parameters,
            headers: headers,
            body: body,
            callbackQueue: callbackQueue
        )
        
        guard let data = result.data else {
            throw SimpleError.customError(title: "网络请求错误", msg: "无法获取到数据 Data")
        }
        
        if type.self == String.self {
            return data.toJsonPrint() as? T
        }else {
            return try data.decodeWithError(type: T.self)
        }
    }
}

// MARK: - 请求异步连续的网络指令
extension SimpleWeb {
    public func requestStream(
        urlSession: URLSession = .shared,
        urlRequest: URLRequest
    ) -> AsyncThrowingStream<UInt8, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                let stream: URLSession.AsyncBytes
                let rawResponse: URLResponse
                do {
                    (stream, rawResponse) = try await urlSession.bytes(for: urlRequest)
                } catch {
                    continuation.finish(throwing: error)
                    return
                }
                // Verify the status code is 200
                guard let response = rawResponse as? HTTPURLResponse else {
                    logger.debug("Response was not an HTTP response.", title: "Invalid response")
                    continuation.finish(
                        throwing: SimpleError.networkError(
                            msg: "Response was not an HTTP response."
                        )
                    )
                    return
                }
                
                logger.debug(response.statusCode.toString(), title: "Stream UrlRequest StatusCode")
                // Verify the status code is 200
                guard response.statusCode == 200 else {
                    
                    var responseBody = ""
                    for try await line in stream.lines {
                        responseBody += line + "\n"
                    }
                    
                    continuation.finish(
                        throwing: SimpleError.networkError(
                            msg: responseBody,
                            statusCode: response.statusCode
                        )
                    )
                    return
                }
                
                for try await byte in stream {
                    continuation.yield(byte)
                }

                continuation.finish()
            }
        }
    }
}

// MARK: - 一些常用的网络请求
extension SimpleWeb {
    private struct ElevationStore: Codable {
        let status: String
        let results: [Elevation]
        
        var isRequestSuccess: Bool { status == "OK" }
    }
    
    public struct Elevation: Codable {
        let elevation: Double
        let resolution: Double
        let location: Location
        
        struct Location: Codable {
            let lat: Double
            let lng: Double
        }
        
        var coordinate: CLLocation {
            CLLocation(latitude: location.lat, longitude: location.lng)
        }
    }
    
    // MARK: - Google Map
    /// 根据经纬度坐标获取当地海拔(正和负)
    /// - Parameter completion: 获取海拔信息
    public func google_fetchElevation(
        coordinate: CLLocationCoordinate2D,
        googleKey: String
    ) async throws -> Elevation? {
        let coordinate = coordinate.toGoogleString()
        let url = "https://maps.googleapis.com/maps/api/elevation/json?locations=\(coordinate)&key=\(googleKey)"
        
        let result = try await request(method: .GET, url: url)
        if let fetchedData = result.data?.decode(type: ElevationStore.self) {
            if fetchedData.isRequestSuccess {
                let elvationData = fetchedData.results.first!
                debugPrint("海拔是: \(elvationData.elevation)m")
                return elvationData
            }else {
                debugPrint(fetchedData.status)
                throw SimpleError.customError(msg: fetchedData.status)
            }
        }
        
        return nil
    }
    
    public enum AmapExtensionsType: String {
        case all, base
    }
    
    // https://lbs.amap.com/api/webservice/guide/api/inputtips
    // MARK: - 高德地图
    /// 通过 经纬度 获取 详细地址信息 和 附近兴趣点(可选)
    /// - Parameter coordinate: 获取地址或兴趣点
    public func amap_fetchAddress(
        amapKey: String,
        coordinate: CLLocationCoordinate2D,
        resultType: AmapExtensionsType = .base, //  all 时会返回基本地址信息、附近 POI 内容、道路信息以及道路交叉口信息
        radius: Int = 1000 // 取值范围：0~3000，单位：米
    ) async throws -> AmapRegeoCode? {
        let params = [
            "key": amapKey,
            "location": coordinate.toAmapString(),
            "extensions": resultType.rawValue,
            "radius": radius.toString(),
            "output": "JSON"
        ]
        let url = "https://restapi.amap.com/v3/geocode/regeo".addParams(params)
        let result = try await request(method: .GET, url: url)
        if let resultStore = result.data?.decode(type: AmapRegeoStore.self) {
            if resultStore.isRequestSuccess {
                debugPrint("高德-成功获取地址: \(resultStore.regeocode.formatted_address)")
                return resultStore.regeocode
            }else {
                debugPrint(result)
            }
        }
        
        return nil
    }
    
    public enum AmapRouteStrategy: Int {
        case speed_1 = 0, lowCost_1 = 1, distance_1 = 3, recommand = 32, hideJam = 33, highway = 34, noHighway = 35, lowCost = 36, bigRoad = 37, speed = 38, nojamAndHighway = 39, nojamAndNoHighway = 40, nojamAndLowCost = 41, lowCostAndNoHighway = 42, nojamAndLowCostAndNoHighway = 43, noJamAndBigRoad = 44, noJamAndSpeed = 45
    }
    public enum AmapCarType: Int {
        case gasoline = 0, electric = 1, hybrid = 2
    }
    // https://lbs.amap.com/api/webservice/guide/api/newroute#t5
    /// 通过开始和结束的地点计算路径
    public func amap_fetchRoute(
        from start: String? = nil, // 经纬度
        to end: String, // 经纬度
        amapKey: String,
        alternativeRoute: Int = 2, // 备选方案
        strategy: AmapRouteStrategy = .highway, // 路线策略
        plate: String = "", // 车牌：限行
        carType: AmapCarType
    ) async throws -> AmapRouteStore? {
        // 首先获取当前设备的地点
        var current_start = CLLocationManager().location?.coordinate.toAmapString() ?? ""
        if let start = start {
            current_start = start
        }
        // 生成相关的URL
        let params = [
            "key": amapKey,
            "origin": current_start,
            "destination": end,
            "AlternativeRoute": alternativeRoute.toString(),
            "strategy": strategy.rawValue.toString(),
            "plate": plate,
            "carType": carType.rawValue.toString(),
            "show_fields": "cost"
        ]
        let url = "https://restapi.amap.com/v5/direction/driving".addParams(params)
        
        let result = try await request(method: .GET, url: url)
        if let resultStore = result.data?.decode(type: AmapRouteRootStore.self) {
            if resultStore.isRequestSuccess {
                debugPrint("高德-成功获取路线: \(resultStore.route.paths.count)条")
                return resultStore.route
            }else {
                debugPrint(result)
            }
        }
        
        return nil
    }
    
    // https://lbs.amap.com/api/webservice/guide/api/inputtips
    /// 通过高德地图获取最新的天气预报（每小时更新一次）
    public func amap_fetchLiveWeather(
        amapKey: String,
        areaCode: String // 区域的 adcode
    ) async throws -> AmapWeatherLive? {
        let params = [
            "key": amapKey,
            "city": areaCode,
            "extensions": "base",
            "output": "JSON"
        ]
        let url = "https://restapi.amap.com/v3/weather/weatherInfo".addParams(params)
        let result = try await request(method: .GET, url: url)
        if let resultStore = result.data?.decode(type: AmapWeatherRoot.self) {
            if resultStore.isRequestSuccess {
                debugPrint("高德-成功获取最新天气: \(resultStore.lives.first?.reporttime ?? "N/A")")
                return resultStore.lives.first
            }else {
                debugPrint(result)
            }
        }
        
        return nil
    }
    
    /// 获取几天内的天气预报
    /// 预报天气每天更新3次，分别在8、11、18点左右更新
    public func amap_fetchWeatherForecast(
        amapKey: String,
        areaCode: String // 区域的 adcode
    ) async throws -> AmapForecastStore? {
        let params = [
            "key": amapKey,
            "city": areaCode,
            "extensions": "all",
            "output": "JSON"
        ]
        let url = "https://restapi.amap.com/v3/weather/weatherInfo".addParams(params)
        let result = try await request(method: .GET, url: url)
        if let resultStore = result.data?.decode(type: AmapWeatherForecastRoot.self) {
            if resultStore.isRequestSuccess {
                debugPrint("高德-成功获取未来的天气预报: \(resultStore.forecasts.first?.casts.count ?? 0)条")
                return resultStore.forecasts.first
            }else {
                debugPrint(result)
            }
        }
        
        return nil
    }
    
    // https://lbs.amap.com/api/webservice/guide/api/inputtips
    /// 高德地图根据关键词返回简单的相关提示
    /// - Parameter keyword: 搜索兴趣点
    public func amap_fetchInputTips(
        amapKey: String,
        keyword: String,
        city: String? = nil // 城市的 adcode
    ) async throws -> [AmpTips] {
        let params = [
            "key": amapKey,
            "keywords": keyword,
            "city": city ?? ""
        ]
        let url = "https://restapi.amap.com/v3/assistant/inputtips".addParams(params)
        let result = try await request(method: .GET, url: url)
        
        if let resultStore = result.data?.decode(type: AmapTipRoot.self) {
            if resultStore.isRequestSuccess {
                debugPrint("高德-成功获取搜索Tips: \(resultStore.tips.count)条")
                return resultStore.tips
            }else {
                debugPrint(result)
            }
        }
        
        return []
    }
    
    // https://lbs.amap.com/api/webservice/guide/api/newpoisearch
    ///高德地图通过文本关键字搜索地点信息
    public func amap_fetchPoi(
        amapKey: String,
        keyword: String,
        region: String? = nil, // 增加指定区域内数据召回权重，可输入 citycode，adcode，cityname
        page: Int = 1
    ) async throws -> [AmapSearchPOI] {
        let params = [
            "key": amapKey,
            "keywords": keyword,
            "region": region ?? "",
            "page_size": "25",
            "page_num": page.toString(),
            "show_fields": "business,photos"
        ]
        let url = "https://restapi.amap.com/v5/place/text".addParams(params)
        let result = try await request(method: .GET, url: url)
        if let resultStore = result.data?.decode(type: AmapSearchRoot.self) {
            if resultStore.isRequestSuccess {
                debugPrint("高德-成功获取第\(page)页搜索结果: \(resultStore.pois.count)条")
                return resultStore.pois
            }else {
                debugPrint(result)
            }
        }
        
        return []
    }
    
    public enum AmapPoiSortRule: String {
        case distance, weight
    }
    /// 搜索一个地点周围的地点信息
    public func amap_fetchNearbyPoi(
        amapKey: String,
        coordinate: CLLocationCoordinate2D,
        location: String, // 中心点坐标
        keyword: String? = nil, // 地点关键字
        radius: Int = 5000, // 取值范围:0-50000,单位：米
        sort: AmapPoiSortRule = .weight, // 按距离排序：distance；综合排序：weight
        page: Int = 1
    ) async throws -> [AmapSearchPOI] {
        let params = [
            "key": amapKey,
            "location": coordinate.toAmapString(),
            "keywords": keyword ?? "",
            "radius": radius.toString(),
            "sortrule": sort.rawValue,
            "page_size": "25",
            "page_num": page.toString(),
            "show_fields": "business,photos"
        ]
        let url = "https://restapi.amap.com/v5/place/around".addParams(params)
        let result = try await request(method: .GET, url: url)
        if let resultStore = result.data?.decode(type: AmapSearchRoot.self) {
            if resultStore.isRequestSuccess {
                debugPrint("高德-成功获取第\(page)页搜索结果: \(resultStore.pois.count)条")
                return resultStore.pois
            }else {
                debugPrint(result)
            }
        }
        
        return []
    }
    
    /// 根据地点的ID搜索该地点的详细信息
    public func amap_fetchPoiDetail(
        amapKey: String,
        poiID: String // poi唯一标识
    ) async throws -> AmapSearchPOI? {
        let params = [
            "key": amapKey,
            "id": poiID,
            "show_fields": "business,photos"
        ]
        let url = "https://restapi.amap.com/v5/place/detail".addParams(params)
        let result = try await request(method: .GET, url: url)
        if let resultStore = result.data?.decode(type: AmapSearchRoot.self) {
            if resultStore.isRequestSuccess {
                debugPrint("高德-成功获取地点信息: \(resultStore.pois.first?.name ?? "N/A")")
                return resultStore.pois.first
            }else {
                debugPrint(result)
            }
        }
        
        return nil
    }
}
