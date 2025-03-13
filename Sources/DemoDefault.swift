//
//  File.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/10/16.
//

import Foundation
import FamilyControls

extension SimpleDefaults.Keys {
    static let colorDisplayType = Key<String>("Library_ColorDisplayType", default: "small", iCloud: true)
    
    static let library_gitToken = Key<String>("Library_GitToken", default: "", iCloud: true)
    static let library_googleKey = Key<String>("Library_GoogleKey", default: "", iCloud: true)
    static let library_amapKey = Key<String>("Library_AmapKey", default: "", iCloud: true)
    
    static let map_isRegionPin = Key<Bool>("Library_Map_IsRegionPin", default: false)
    static let map_isAddress = Key<Bool>("Library_Map_IsAddress", default: false)
    static let map_isShowsTraffic = Key<Bool>("Library_Map_IsShowsTraffic", default: false)
    
    static let feedback_account = Key<SimpleFeedbackModel?>("Feedback_Account", iCloud: true)
    static let feedback_hasShowReviewRequest = Key<Bool>("Feedback_HasShowReviewRequest", default: false)
    
    #if os(iOS)
    public static let control_startRestriction = Key<Bool>("control_StartRestriction", default: false)
    public static let control_selectedApp = Key<FamilyActivitySelection>("control_SelectedApp", default: FamilyActivitySelection())
    #endif
}

#if os(iOS)
extension FamilyActivitySelection: SimpleDefaults.Serializable {
    public static let bridge = SimpleFamilyActivitySelectionBridge()
}

public struct SimpleFamilyActivitySelectionBridge: SimpleDefaults.Bridge {
    public typealias Value = FamilyActivitySelection
    public typealias Serializable = Data

    public func serialize(_ value: Value?) -> Serializable? {
        guard let value else {
            return nil
        }

        return value.encode()
    }

    public func deserialize(_ object: Serializable?) -> Value? {
        guard let object else {
            return nil
        }

        return object.decode(type: Value.self)
    }
}
#endif

extension SimpleFeedbackModel: SimpleDefaults.Serializable {
    public static let bridge = SimpleFeedbackBridge()
}

public struct SimpleFeedbackBridge: SimpleDefaults.Bridge {
    public typealias Value = SimpleFeedbackModel
    public typealias Serializable = Data

    public func serialize(_ value: Value?) -> Serializable? {
        guard let value else {
            return nil
        }

        return value.encode()
    }

    public func deserialize(_ object: Serializable?) -> Value? {
        guard let object else {
            return nil
        }

        return object.decode(type: Value.self)
    }
}
