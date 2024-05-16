//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/5/16.
//

import Foundation

public class SimpleWeb {
    let cacheHelper: SimpleCache?
    
    init() {
        cacheHelper = try? SimpleCache(isDebuging: false)
    }
    
    /// 先从缓存读取，没有则从网络读取并缓存
    public func loadImage(from key: String) async throws -> SFImage? {
        guard let url = URL(string: key) else { return nil }
        if cacheHelper?.exists(forKey: key) == true,
           let cacheImage = try cacheHelper?.loadImage(forKey: key) {
            debugPrint("1.从缓存获取图片：\(key)")
            return cacheImage
        }
        
        if let data = try await loadData(from: url),
           let image = SFImage(data: data) {
            debugPrint("2.从网络获取图片：\(data.count.toDouble.toStorage())")
            try cacheHelper?.save(object: data, forKey: key)
            return image
        }else {
            debugPrint("3.没有网络获取图片")
            return nil
        }
    }
    
    public func loadData(from url: URL?) async throws -> Data? {
        do {
            guard let url else { return nil }
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        }catch {
            debugPrint("下载 Data 错误：\(error.localizedDescription)")
            throw error
        }
    }
}
