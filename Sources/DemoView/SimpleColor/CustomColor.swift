//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/4/22.
//

import Foundation
import SwiftUI

// MARK: - 自定义预置颜色
public extension Color {
    // MARK: - Gray
    static var gray_Space: Color {
        Color(r: 45, g: 67, b: 67)
    }
    
    static var gray_Thunder: Color {
        Color(r: 60, g: 43, b: 57)
    }
    
    static var gray_Charade: Color {
        Color(r: 45, g: 47, b: 60)
    }
    
    static var gray_Hit: Color {
        Color(r: 150, g: 165, b: 173)
    }
    
    static var gray_Nurse: Color {
        Color(r: 222, g: 229, b: 221)
    }
    
    // MARK: - Brown
    static var brown_Tundora: Color {
        Color(r: 77, g: 73, b: 75)
    }
    
    static var brown_Americano: Color {
        Color(r: 138, g: 114, b: 109)
    }
    
    static var brown_Gurkha: Color {
        Color(r: 157, g: 153, b: 126)
    }
    
    // MARK: - Purple
    static var purple_Port: Color {
        Color(r: 35, g: 35, b: 73)
    }
    
    static var purple_Heliotrope: Color {
        Color(r: 147, g: 119, b: 255)
    }
    
    static var purple_Wisteria: Color {
        Color(r: 148, g: 105, b: 174)
    }
    
    static var purple_Spindle: Color {
        Color(r: 195, g: 188, b: 235)
    }
    
    static var purple_Brilliant: Color {
        Color(r: 229, g: 56, b: 220)
    }
    
    static var purple_Razzle: Color {
        Color(r: 255, g: 75, b: 186)
    }
    
    static var purple_Cedar: Color {
        Color(r: 60, g: 37, b: 66)
    }
    
    // MARK: - Pink
    static var pink_Persian: Color {
        Color(r: 252, g: 120, b: 199)
    }
    
    static var pink_Orchid: Color {
        Color(r: 235, g: 176, b: 224)
    }
    
    // MARK: - Yellow
    static var yellow_Champagne: Color {
        Color(r: 251, g: 233, b: 206)
    }
    
    static var yellow_Sunglow: Color {
        Color(r: 251, g: 201, b: 49)
    }
    
    static var yellow_Rajah: Color {
        Color(r: 250, g: 189, b: 115)
    }
    
    static var yellow_Bus: Color {
        Color(r: 247, g: 218, b: 0)
    }
    
    static var yellow_Sandy: Color {
        Color(r: 240, g: 178, b: 101)
    }
    
    static var yellow_Golden: Color {
        Color(r: 240, g: 231, b: 52)
    }
    
    static var yellow_Goldenrod: Color {
        Color(r: 248, g: 207, b: 125)
    }
    
    static var yellow_Neon: Color {
        Color(r: 255, g: 145, b: 43)
    }
    
    // MARK: - Red
    static var red_Sunglo: Color {
        Color(r: 226, g: 103, b: 100)
    }
    
    static var red_Geraldine: Color {
        Color(r: 249, g: 135, b: 127)
    }
    
    static var red_Rose: Color {
        Color(r: 201, g: 100, b: 96)
    }
    
    static var red_Sunset: Color {
        Color(r: 254, g: 79, b: 66)
    }
    
    static var red_Razzmatazz: Color {
        Color(r: 246, g: 3, b: 92)
    }
    
    static var red_Amaranth: Color {
        Color(r: 240, g: 58, b: 104)
    }
    
    static var red_Lipstick: Color {
        Color(r: 201, g: 5, b: 106)
    }
    
    static var red_vivid: Color {
        Color(r: 253, g: 154, b: 121)
    }
    
    static var red_Cavern: Color {
        Color(r: 230, g: 199, b: 196)
    }
    
    static var red_Peach: Color {
        Color(r: 250, g: 194, b: 185)
    }
    
    // MARK: - Green
    static var green_Honey: Color {
        Color(r: 210, g: 252, b: 113)
    }
    
    static var green_Pastel: Color {
        Color(red: 130/255, green: 219/255, blue: 136/255)
    }
    
    static var green_Gin: Color {
        Color(r: 222, g: 236, b: 224)
    }
    
    static var green_Rainee: Color {
        Color(r: 194, g: 200, b: 171)
    }
    
    static var green_Spring: Color {
        Color(r: 18, g: 243, b: 149)
    }
    
    static var green_Caribbean: Color {
        Color(r: 10, g: 220, b: 146)
    }
    
    static var green_Downy: Color {
        Color(r: 122, g: 209, b: 189)
    }
    
    static var green_Ice: Color {
        Color(r: 171, g: 245, b: 225)
    }
    
    static var green_Keppel: Color {
        Color(r: 51, g: 162, b: 138)
    }
    
    static var green_Hinterland: Color {
        Color(r: 41, g: 74, b: 78)
    }
    
    static var green_Olive: Color {
        Color(r: 152, g: 152, b: 2)
    }
    
    static var green_Leaf: Color {
        Color(r: 77, g: 93, b: 11)
    }
    // MARK: - Blue
    static var blue_French: Color {
        Color(r: 174, g: 254, b: 252)
    }
    
    static var blue_Regal: Color {
        Color(r: 1, g: 67, b: 105)
    }
    
    static var blue_Downy: Color {
        Color(r: 104, g: 194, b: 210)
    }
    
    static var blue_Neptune: Color {
        Color(r: 127, g: 170, b: 189)
    }
    
    static var blue_Cornflower: Color {
        Color(r: 102, g: 151, b: 243)
    }
    
    static var blue_LinkWater: Color {
        Color(r: 206, g: 226, b: 242)
    }
    
    static var blue_Seagull: Color {
        Color(r: 123, g: 179, b: 225)
    }
    
    static var blue_Dodger: Color {
        Color(r: 51, g: 162, b: 253)
    }
    
    static var blue_Picton: Color {
        Color(r: 73, g: 184, b: 249)
    }
    
    static var blue_Polo: Color {
        Color(r: 150, g: 176, b: 210)
    }
    
    static var blue_Orient: Color {
        Color(r: 2, g: 98, b: 139)
    }
    
    static var blue_Chambray: Color {
        Color(r: 54, g: 75, b: 153)
    }
    
}
