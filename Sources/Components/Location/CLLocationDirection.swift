//
//  File.swift
//  AmosBase
//
//  Created by Amos on 2025/5/19.
//

import CoreLocation

public extension CLLocationDirection {
    enum CompassPoints: Int {
        case four = 4
        case eight = 8
    }
    
    func toDirection(_ compassPoints: CompassPoints = .eight) -> String? {
        // 检查航向是否有效
        if self < 0 {
            return nil
        }

        // 确保度数在 [0, 360) 范围内
        let normalizedCourse = self.truncatingRemainder(dividingBy: 360)

        let directions: [String]
        let sectorWidth: Double
        let shift: Double // 用于调整扇区边界，使北(0度)位于第一个扇区的中心附近

        switch compassPoints {
        case .four:
            directions = ["N", "E", "S", "W"]
            sectorWidth = 360.0 / 4.0 // 90 度
            shift = sectorWidth / 2.0 // 45 度
        case .eight:
            directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
            sectorWidth = 360.0 / 8.0 // 45 度
            shift = sectorWidth / 2.0 // 22.5 度
        }

        // 将航向值加上偏移量，并取模 360，这样 0 度就落在了第一个扇区的中间
        let shiftedCourse = (normalizedCourse + shift).truncatingRemainder(dividingBy: 360)

        // 计算对应的方向索引
        let index = Int(shiftedCourse / sectorWidth)

        // 返回对应索引的方向字符串
        // 确保索引在有效范围内，尽管计算方法通常会保证这一点
        let safeIndex = min(max(0, index), directions.count - 1)

        return directions[safeIndex]
    }
}
