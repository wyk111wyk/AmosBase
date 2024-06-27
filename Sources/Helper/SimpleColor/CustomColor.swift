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
    
    static var gray_Charade: Color {
        Color(r: 133, g: 134, b: 139)
    }
    
    static var gray_Hit: Color {
        Color(r: 150, g: 165, b: 173)
    }
    
    static var gray_Nurse: Color {
        Color(r: 222, g: 229, b: 221)
    }
    
    // MARK: - Brown
    static var brown_Tundora: Color {
        Color(r: 168, g: 139, b: 76)
    }
    
    static var brown_Americano: Color {
        Color(r: 200, g: 178, b: 114)
    }
    
    static var brown_Gurkha: Color {
        Color(r: 83, g: 72, b: 50)
    }
    
    // MARK: - Purple
    
    static var purple_Heliotrope: Color {
        Color(r: 147, g: 119, b: 255)
    }
    
    static var purple_Wisteria: Color {
        Color(r: 148, g: 105, b: 174)
    }
    
    static var purple_Spindle: Color {
        Color(r: 195, g: 188, b: 235)
    }
    
    static var purple_Razzle: Color {
        Color(r: 255, g: 75, b: 186)
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
    
    static var yellow_Rajah: Color {
        Color(r: 250, g: 189, b: 115)
    }
    
    static var yellow_Bus: Color {
        Color(r: 247, g: 218, b: 0)
    }
    
    static var yellow_Sandy: Color {
        Color(r: 215, g: 174, b: 4)
    }
    
    static var yellow_Golden: Color {
        Color(r: 240, g: 231, b: 52)
    }
    
    static var yellow_Neon: Color {
        Color(r: 255, g: 145, b: 43)
    }
    
    // MARK: - Red
    static var red_01: Color {
        Color(r: 255, g: 245, b: 245)
    }
    
    static var red_02: Color {
        Color(r: 255, g: 227, b: 227)
    }
    
    static var red_03: Color {
        Color(r: 255, g: 201, b: 201)
    }
    
    static var red_04: Color {
        Color(r: 255, g: 168, b: 168)
    }
    
    static var red_05: Color {
        Color(r: 255, g: 135, b: 135)
    }
    
    static var red_06: Color {
        Color(r: 255, g: 107, b: 107)
    }
    
    static var red_07: Color {
        Color(r: 250, g: 82, b: 82)
    }
    
    static var red_08: Color {
        Color(r: 240, g: 62, b: 62)
    }
    
    static var red_09: Color {
        Color(r: 244, g: 49, b: 49)
    }
    
    static var red_10: Color {
        Color(r: 201, g: 42, b: 42)
    }
    
    static var red_Sunglo: Color {
        Color(r: 171, g: 56, b: 27)
    }
    
    static var red_Geraldine: Color {
        Color(r: 249, g: 135, b: 127)
    }
    
    static var red_Sunset: Color {
        Color(r: 254, g: 79, b: 66)
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
    
    static var red_Peach: Color {
        Color(r: 250, g: 194, b: 185)
    }
    
    // MARK: - Green
    static var green_01: Color {
        Color(r: 241, g: 252, b: 249)
    }
    
    static var green_02: Color {
        Color(r: 209, g: 246, b: 237)
    }
    
    static var green_03: Color {
        Color(r: 162, g: 237, b: 220)
    }
    
    static var green_04: Color {
        Color(r: 105, g: 219, b: 198)
    }
    
    static var green_05: Color {
        Color(r: 62, g: 195, b: 174)
    }
    
    static var green_06: Color {
        Color(r: 37, g: 167, b: 149)
    }
    
    static var green_07: Color {
        Color(r: 27, g: 134, b: 122)
    }
    
    static var green_08: Color {
        Color(r: 25, g: 108, b: 99)
    }
    
    static var green_09: Color {
        Color(r: 25, g: 86, b: 80)
    }
    
    static var green_10: Color {
        Color(r: 25, g: 72, b: 68)
    }
    
    static var green_Pastel: Color {
        Color(red: 130/255, green: 219/255, blue: 136/255)
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
    
    static var green_Olive: Color {
        Color(r: 152, g: 152, b: 2)
    }
    
    static var green_Leaf: Color {
        Color(r: 77, g: 93, b: 11)
    }
    // MARK: - Blue
    static var blue_01: Color {
        Color(r: 242, g: 249, b: 253)
    }
    
    static var blue_02: Color {
        Color(r: 229, g: 240, b: 249)
    }
    
    static var blue_03: Color {
        Color(r: 196, g: 226, b: 243)
    }
    
    static var blue_04: Color {
        Color(r: 144, g: 202, b: 233)
    }
    
    static var blue_05: Color {
        Color(r: 85, g: 174, b: 219)
    }
    
    static var blue_06: Color {
        Color(r: 48, g: 148, b: 199)
    }
    
    static var blue_07: Color {
        Color(r: 32, g: 118, b: 169)
    }
    
    static var blue_08: Color {
        Color(r: 27, g: 95, b: 137)
    }
    
    static var blue_09: Color {
        Color(r: 28, g: 86, b: 121)
    }
    
    static var blue_10: Color {
        Color(r: 27, g: 68, b: 95)
    }
    
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
    
    static var blue_Seagull: Color {
        Color(r: 123, g: 179, b: 225)
    }
    
    static var blue_Picton: Color {
        Color(r: 73, g: 184, b: 249)
    }
    
    static var blue_Orient: Color {
        Color(r: 2, g: 98, b: 139)
    }
}

#Preview("Color") {
    #if os(watchOS)
    let columns = [GridItem(.adaptive(minimum: 30, maximum: 40), spacing: 6)]
    let colorLength: CGFloat = 30
    #else
    let columns = [GridItem(.adaptive(minimum: 60, maximum: 80), spacing: 8)]
    let colorLength: CGFloat = 70
    #endif
    
    func systemColor(_ colorBundle: [SimpleColorModel]) -> some View {
        LazyVGrid(columns: columns, spacing: 12){
            ForEach(colorBundle) {colorData in
                VStack {
                    colorData.color
                        .frame(width: colorLength,
                               height: colorLength)
                        .cornerRadius(8)
                    Text(colorData.name)
                        .font(.footnote)
                        .lineLimit(1)
                }
            }
        }
    }
    
    return Form {
//        Section("自定义渐变色") {
//            systemColor(SimpleColorModel.allGradient_Blue)
//            systemColor(SimpleColorModel.allGradient_Red)
//            systemColor(SimpleColorModel.allGradient_Green)
//        }
        Section("自定义颜色") {
            systemColor(SimpleColorModel.allGray)
            systemColor(SimpleColorModel.allGreen)
            systemColor(SimpleColorModel.allBlue)
            systemColor(SimpleColorModel.allPurple)
            systemColor(SimpleColorModel.allRed)
            systemColor(SimpleColorModel.allYellow)
        }
    }
}
