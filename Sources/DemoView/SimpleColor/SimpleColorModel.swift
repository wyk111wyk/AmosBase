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
    static var allColor: [SimpleColorModel] {
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
    
    static var allGreen: [SimpleColorModel] {
        [.init(name: "Ice", color: .green_Ice),
         .init(name: "Gin", color: .green_Gin),
         .init(name: "Rainee", color: .green_Rainee),
         .init(name: "Honey", color: .green_Honey),
         .init(name: "Pastal", color: .green_Pastel),
         .init(name: "Spring", color: .green_Spring),
         .init(name: "Caribben", color: .green_Caribbean),
         .init(name: "Downy", color: .green_Downy),
         .init(name: "Keppel", color: .green_Keppel),
         .init(name: "Hinterland", color: .green_Hinterland),
         .init(name: "Olive", color: .green_Olive),
         .init(name: "Leaf", color: .green_Leaf)]
    }
    
    static var allBlue: [SimpleColorModel] {
        [.init(name: "LinkWater", color: .blue_LinkWater),
         .init(name: "French", color: .blue_French),
         .init(name: "Downy", color: .blue_Downy),
         .init(name: "Neptune", color: .blue_Neptune),
         .init(name: "Seagull", color: .blue_Seagull),
         .init(name: "Dodger", color: .blue_Dodger),
         .init(name: "Piction", color: .blue_Picton),
         .init(name: "Polo", color: .blue_Polo),
         .init(name: "Cornflower", color: .blue_Cornflower),
         .init(name: "Chambray", color: .blue_Chambray),
         .init(name: "Orient", color: .blue_Orient),
         .init(name: "Regal", color: .blue_Regal)
        ]
    }
    
    static var allRed: [SimpleColorModel] {
        [.init(name: "Vivid", color: .red_vivid),
         .init(name: "Geraldine", color: .red_Geraldine),
         .init(name: "Sunglo", color: .red_Sunglo),
         .init(name: "Rose", color: .red_Rose),
         .init(name: "Sunset", color: .red_Sunset),
         .init(name: "Razzmatazz", color: .red_Razzmatazz),
         .init(name: "Amaranth", color: .red_Amaranth),
         .init(name: "Lipstick", color: .red_Lipstick),
         .init(name: "Cavern", color: .red_Cavern),
         .init(name: "Peach", color: .red_Peach)
        ]
    }
    
    static var allYellow: [SimpleColorModel] {
        [.init(name: "Champagne", color: .yellow_Champagne),
         .init(name: "Bus", color: .yellow_Bus),
         .init(name: "Golden", color: .yellow_Golden),
         .init(name: "Goldenrod", color: .yellow_Goldenrod),
         .init(name: "Sunglow", color: .yellow_Sunglow),
         .init(name: "Sandy", color: .yellow_Sandy),
         .init(name: "Rajah", color: .yellow_Rajah),
         .init(name: "Neon", color: .yellow_Neon)
        ]
    }
    
    static var allPurple: [SimpleColorModel] {
        [.init(name: "Spindle", color: .purple_Spindle),
         .init(name: "Heliotrope", color: .purple_Heliotrope),
         .init(name: "Wisteria", color: .purple_Wisteria),
         .init(name: "Brilliant", color: .purple_Brilliant),
         .init(name: "Razzle", color: .purple_Razzle),
         .init(name: "Port", color: .purple_Port),
         .init(name: "Cedar", color: .purple_Cedar),
         .init(name: "Persian", color: .pink_Persian),
         .init(name: "Orchid", color: .pink_Orchid)
        ]
    }
    
    static var allGray: [SimpleColorModel] {
        [.init(name: "Charade", color: .gray_Charade),
         .init(name: "Space", color: .gray_Space),
         .init(name: "Thunder", color: .gray_Thunder),
         .init(name: "Hit", color: .gray_Hit),
         .init(name: "Nurse", color: .gray_Nurse),
         .init(name: "Tundora", color: .brown_Tundora),
         .init(name: "Americano", color: .brown_Americano),
         .init(name: "Gurkha", color: .brown_Gurkha)
        ]
    }
}

