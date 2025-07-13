//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/4/22.
//

import Foundation
import SwiftUI

public struct SimpleColorModel: Identifiable {
    public var id: UUID
    public var name: String
    public var color: Color
    
    public init(id: UUID = UUID(), name: String, color: Color) {
        self.id = id
        self.name = name
        self.color = color
    }
}

extension SimpleColorModel {
    static var allSwiftUI: [SimpleColorModel] {
        [SimpleColorModel(name: ".primary", color: Color.primary),
         SimpleColorModel(name: ".secondary", color: Color.secondary),
         SimpleColorModel(name: ".black", color: Color.black),
         SimpleColorModel(name: ".white", color: Color.white),
         SimpleColorModel(name: ".gray", color: Color.gray),
         SimpleColorModel(name: ".red", color: Color.red),
         SimpleColorModel(name: ".green", color: Color.green),
         SimpleColorModel(name: ".blue", color: Color.blue),
         SimpleColorModel(name: ".orange", color: Color.orange),
         SimpleColorModel(name: ".yellow", color: Color.yellow),
         SimpleColorModel(name: ".pink", color: Color.pink),
         SimpleColorModel(name: ".purple", color: Color.purple),
         SimpleColorModel(name: ".mint", color: Color.mint),
         SimpleColorModel(name: ".teal", color: Color.teal),
         SimpleColorModel(name: ".cyan", color: Color.cyan),
         SimpleColorModel(name: ".indigo", color: Color.indigo),
         SimpleColorModel(name: ".brown", color: Color.brown)]
    }
    
    static var allGradient_Blue: [SimpleColorModel] {
        [.init(name: "Blue01", color: .blue_01),
         .init(name: "Blue02", color: .blue_02),
         .init(name: "Blue03", color: .blue_03),
         .init(name: "Blue04", color: .blue_04),
         .init(name: "Blue05", color: .blue_05),
         .init(name: "Blue06", color: .blue_06),
         .init(name: "Blue07", color: .blue_07),
         .init(name: "Blue08", color: .blue_08),
         .init(name: "Blue09", color: .blue_09),
         .init(name: "Blue10", color: .blue_10)
        ]
    }
    
    static var allGradient_Red: [SimpleColorModel] {
        [.init(name: "Red01", color: .red_01),
         .init(name: "Red02", color: .red_02),
         .init(name: "Red03", color: .red_03),
         .init(name: "Red04", color: .red_04),
         .init(name: "Red05", color: .red_05),
         .init(name: "Red06", color: .red_06),
         .init(name: "Red07", color: .red_07),
         .init(name: "Red08", color: .red_08),
         .init(name: "Red09", color: .red_09),
         .init(name: "Red10", color: .red_10)
        ]
    }
    
    static var allGradient_Green: [SimpleColorModel] {
        [.init(name: "Green01", color: .green_01),
         .init(name: "Green02", color: .green_02),
         .init(name: "Green03", color: .green_03),
         .init(name: "Green04", color: .green_04),
         .init(name: "Green05", color: .green_05),
         .init(name: "Green06", color: .green_06),
         .init(name: "Green07", color: .green_07),
         .init(name: "Green08", color: .green_08),
         .init(name: "Green09", color: .green_09),
         .init(name: "Green10", color: .green_10)
        ]
    }
    
    static var allGradient_Teal: [SimpleColorModel] {
        [.init(name: "Teal01", color: .teal_01),
         .init(name: "Teal02", color: .teal_02),
         .init(name: "Teal03", color: .teal_03),
         .init(name: "Teal04", color: .teal_04),
         .init(name: "Teal05", color: .teal_05),
         .init(name: "Teal06", color: .teal_06),
         .init(name: "Teal07", color: .teal_07),
         .init(name: "Teal08", color: .teal_08),
         .init(name: "Teal09", color: .teal_09),
         .init(name: "Teal10", color: .teal_10)
        ]
    }
    
    static var allGradient_Brown: [SimpleColorModel] {
        [.init(name: "Brown01", color: .brown_01),
         .init(name: "Brown02", color: .brown_02),
         .init(name: "Brown03", color: .brown_03),
         .init(name: "Brown04", color: .brown_04),
         .init(name: "Brown05", color: .brown_05),
         .init(name: "Brown06", color: .brown_06),
         .init(name: "Brown07", color: .brown_07),
         .init(name: "Brown08", color: .brown_08),
         .init(name: "Brown09", color: .brown_09),
         .init(name: "Brown10", color: .brown_10)
        ]
    }
    
    static var allGradient_Orange: [SimpleColorModel] {
        [.init(name: "Orange01", color: .orange_01),
         .init(name: "Orange02", color: .orange_02),
         .init(name: "Orange03", color: .orange_03),
         .init(name: "Orange04", color: .orange_04),
         .init(name: "Orange05", color: .orange_05),
         .init(name: "Orange06", color: .orange_06),
         .init(name: "Orange07", color: .orange_07),
         .init(name: "Orange08", color: .orange_08),
         .init(name: "Orange09", color: .orange_09),
         .init(name: "Orange10", color: .orange_10)
        ]
    }
    
    static var allGradient_Indigo: [SimpleColorModel] {
        [.init(name: "Indigo01", color: .indigo_01),
         .init(name: "Indigo02", color: .indigo_02),
         .init(name: "Indigo03", color: .indigo_03),
         .init(name: "Indigo04", color: .indigo_04),
         .init(name: "Indigo05", color: .indigo_05),
         .init(name: "Indigo06", color: .indigo_06),
         .init(name: "Indigo07", color: .indigo_07),
         .init(name: "Indigo08", color: .indigo_08),
         .init(name: "Indigo09", color: .indigo_09),
         .init(name: "Indigo10", color: .indigo_10)
        ]
    }
    
    static var allGradient_Purple: [SimpleColorModel] {
        [.init(name: "Purple01", color: .purple_01),
         .init(name: "Purple02", color: .purple_02),
         .init(name: "Purple03", color: .purple_03),
         .init(name: "Purple04", color: .purple_04),
         .init(name: "Purple05", color: .purple_05),
         .init(name: "Purple06", color: .purple_06),
         .init(name: "Purple07", color: .purple_07),
         .init(name: "Purple08", color: .purple_08),
         .init(name: "Purple09", color: .purple_09),
         .init(name: "Purple10", color: .purple_10)
        ]
    }
    
    static var allGradient_Pink: [SimpleColorModel] {
        [.init(name: "Pink01", color: .pink_01),
         .init(name: "Pink02", color: .pink_02),
         .init(name: "Pink03", color: .pink_03),
         .init(name: "Pink04", color: .pink_04),
         .init(name: "Pink05", color: .pink_05),
         .init(name: "Pink06", color: .pink_06),
         .init(name: "Pink07", color: .pink_07),
         .init(name: "Pink08", color: .pink_08),
         .init(name: "Pink09", color: .pink_09),
         .init(name: "Pink10", color: .pink_10)
        ]
    }
}

