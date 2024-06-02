//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/6/2.
//

import Foundation

public enum PicBedPath: String {
    case base, gpt, picGo
    
    static var allCases: [PicBedPath] {
        return [.base, .gpt, .picGo]
    }
    
    var title: String {
        switch self {
        case .base:
            return "AmosBase"
        case .gpt:
            return "AmosGPT"
        case .picGo:
            return "PicGo"
        }
    }
    
    var path: String {
        switch self {
        case .base:
            return "AmosBase/"
        case .gpt:
            return "AmosGPT/"
        case .picGo:
            return "PicGo/"
        }
    }
}
