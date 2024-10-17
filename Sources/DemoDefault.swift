//
//  File.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/10/16.
//

import Foundation

extension SimpleDefaults.Keys {
    static let colorDisplayType = Key<String>("Library_ColorDisplayType", default: "small", iCloud: true)
    
    static let library_gitToken = Key<String>("Library_GitToken", default: "", iCloud: true)
    static let library_googleKey = Key<String>("Library_GoogleKey", default: "", iCloud: true)
    static let library_amapKey = Key<String>("Library_AmapKey", default: "", iCloud: true)
    
    static let map_isRegionPin = Key<Bool>("Library_Map_IsRegionPin", default: false)
    static let map_isAddress = Key<Bool>("Library_Map_IsAddress", default: false)
    static let map_isShowsTraffic = Key<Bool>("Library_Map_IsShowsTraffic", default: false)
}
