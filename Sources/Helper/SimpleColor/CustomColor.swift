//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/4/22.
//

import Foundation
import SwiftUI

// MARK: - 自定义预置颜色
//extension ShapeStyle where Self == HierarchicalShapeStyle {
//    public static var amosColor: HierarchicalShapeStyle {}
//}

extension ShapeStyle where Self == Color {
    // MARK: - Gray
    public static var gray_Space: Color { Color(r: 45, g: 67, b: 67) }
    
    public static var gray_Charade: Color { Color(r: 133, g: 134, b: 139) }
    
    public static var gray_Hit: Color { Color(r: 150, g: 165, b: 173) }
    
    public static var gray_Nurse: Color { Color(r: 222, g: 229, b: 221) }
    
    // MARK: - Brown
    public static var brown_Tundora: Color { Color(r: 168, g: 139, b: 76) }
    
    public static var brown_Americano: Color { Color(r: 200, g: 178, b: 114) }
    
    public static var brown_Gurkha: Color { Color(r: 83, g: 72, b: 50) }
    
    // MARK: - Purple
    public static var purple_01: Color { Color(r: 248, g: 240, b: 252) }
    
    public static var purple_02: Color { Color(r: 243, g: 217, b: 250) }
    
    public static var purple_03: Color { Color(r: 238, g: 190, b: 250) }
    
    public static var purple_04: Color { Color(r: 229, g: 153, b: 247) }
    
    public static var purple_05: Color { Color(r: 218, g: 119, b: 242) }
    
    public static var purple_06: Color { Color(r: 204, g: 93, b: 232) }
    
    public static var purple_07: Color { Color(r: 190, g: 75, b: 219) }
    
    public static var purple_08: Color { Color(r: 174, g: 62, b: 201) }
    
    public static var purple_09: Color { Color(r: 156, g: 54, b: 181) }
    
    public static var purple_10: Color { Color(r: 134, g: 46, b: 156) }
    
    public static var purple_Heliotrope: Color { Color(r: 147, g: 119, b: 255) }
    
    public static var purple_Wisteria: Color { Color(r: 148, g: 105, b: 174) }
    
    public static var purple_Spindle: Color { Color(r: 195, g: 188, b: 235) }
    
    public static var purple_Razzle: Color { Color(r: 255, g: 75, b: 186) }
    
    // MARK: - Pink
    public static var pink_01: Color { Color(r: 255, g: 240, b: 246) }
    
    public static var pink_02: Color { Color(r: 255, g: 222, b: 235) }
    
    public static var pink_03: Color { Color(r: 252, g: 194, b: 215) }
    
    public static var pink_04: Color { Color(r: 250, g: 162, b: 193) }
    
    public static var pink_05: Color { Color(r: 247, g: 131, b: 172) }
    
    public static var pink_06: Color { Color(r: 240, g: 101, b: 149) }
    
    public static var pink_07: Color { Color(r: 230, g: 73, b: 128) }
    
    public static var pink_08: Color { Color(r: 214, g: 51, b: 108) }
    
    public static var pink_09: Color { Color(r: 194, g: 37, b: 92) }
    
    public static var pink_10: Color { Color(r: 166, g: 30, b: 77) }
    
    public static var pink_Orchid: Color { Color(r: 235, g: 176, b: 224) }
    
    // MARK: - Yellow
    public static var yellow_Champagne: Color { Color(r: 251, g: 233, b: 206) }
    
    public static var yellow_Rajah: Color { Color(r: 250, g: 189, b: 115) }
    
    public static var yellow_Bus: Color { Color(r: 247, g: 218, b: 0) }
    
    public static var yellow_Sandy: Color { Color(r: 215, g: 174, b: 4) }
    
    public static var yellow_Golden: Color { Color(r: 240, g: 231, b: 52) }
    
    public static var yellow_Neon: Color { Color(r: 255, g: 145, b: 43) }
    
    // MARK: - Red
    public static var red_01: Color { Color(r: 255, g: 245, b: 245) }
    
    public static var red_02: Color { Color(r: 255, g: 227, b: 227) }
    
    public static var red_03: Color { Color(r: 255, g: 201, b: 201) }
    
    public static var red_04: Color { Color(r: 255, g: 168, b: 168) }
    
    public static var red_05: Color { Color(r: 255, g: 135, b: 135) }
    
    public static var red_06: Color { Color(r: 255, g: 107, b: 107) }
    
    public static var red_07: Color { Color(r: 250, g: 82, b: 82) }
    
    public static var red_08: Color { Color(r: 240, g: 62, b: 62) }
    
    public static var red_09: Color { Color(r: 244, g: 49, b: 49) }
    
    public static var red_10: Color { Color(r: 201, g: 42, b: 42) }
    
    public static var red_Sunglo: Color { Color(r: 171, g: 56, b: 27) }
    
    public static var red_Geraldine: Color { Color(r: 249, g: 135, b: 127) }
    
    public static var red_Sunset: Color { Color(r: 254, g: 79, b: 66) }
    
    public static var red_Amaranth: Color { Color(r: 240, g: 58, b: 104) }
    
    public static var red_Lipstick: Color { Color(r: 201, g: 5, b: 106) }
    
    public static var red_vivid: Color { Color(r: 253, g: 154, b: 121) }
    
    public static var red_Peach: Color { Color(r: 250, g: 194, b: 185) }
    
    // MARK: - Green
    public static var green_01: Color { Color(r: 239, g: 251, b: 242) }
    
    public static var green_02: Color { Color(r: 218, g: 249, b: 227) }
    
    public static var green_03: Color { Color(r: 185, g: 240, b: 199) }
    
    public static var green_04: Color { Color(r: 134, g: 228, b: 158) }
    
    public static var green_05: Color { Color(r: 84, g: 205, b: 114) }
    
    public static var green_06: Color { Color(r: 51, g: 176, b: 81) }
    
    public static var green_07: Color { Color(r: 39, g: 141, b: 64) }
    
    public static var green_08: Color { Color(r: 33, g: 108, b: 52) }
    
    public static var green_09: Color { Color(r: 30, g: 84, b: 44) }
    
    public static var green_10: Color { Color(r: 26, g: 69, b: 38) }
    
    public static var green_Pastel: Color { Color(red: 130/255, green: 219/255, blue: 136/255) }
    
    public static var green_Spring: Color { Color(r: 18, g: 243, b: 149) }
    
    public static var green_Caribbean: Color { Color(r: 10, g: 220, b: 146) }
    
    public static var green_Downy: Color { Color(r: 122, g: 209, b: 189) }
    
    public static var green_Ice: Color { Color(r: 171, g: 245, b: 225) }
    
    public static var green_Keppel: Color { Color(r: 51, g: 162, b: 138) }
    
    public static var green_Olive: Color { Color(r: 152, g: 152, b: 2) }
    
    public static var green_Leaf: Color { Color(r: 77, g: 93, b: 11) }
    
    // MARK: - Blue
    public static var blue_01: Color { Color(r: 242, g: 249, b: 253) }
    
    public static var blue_02: Color { Color(r: 229, g: 240, b: 249) }
    
    public static var blue_03: Color { Color(r: 196, g: 226, b: 243) }
    
    public static var blue_04: Color { Color(r: 144, g: 202, b: 233) }
    
    public static var blue_05: Color { Color(r: 85, g: 174, b: 219) }
    
    public static var blue_06: Color { Color(r: 48, g: 148, b: 199) }
    
    public static var blue_07: Color { Color(r: 32, g: 118, b: 169) }
    
    public static var blue_08: Color { Color(r: 27, g: 95, b: 137) }
    
    public static var blue_09: Color { Color(r: 28, g: 86, b: 121) }
    
    public static var blue_10: Color { Color(r: 27, g: 68, b: 95) }
    
    public static var blue_French: Color { Color(r: 174, g: 254, b: 252) }
    
    public static var blue_Regal: Color { Color(r: 1, g: 67, b: 105) }
    
    public static var blue_Downy: Color { Color(r: 104, g: 194, b: 210) }
    
    public static var blue_Neptune: Color { Color(r: 127, g: 170, b: 189) }
    
    public static var blue_Cornflower: Color { Color(r: 102, g: 151, b: 243) }
    
    public static var blue_Seagull: Color { Color(r: 123, g: 179, b: 225) }
    
    public static var blue_Picton: Color { Color(r: 73, g: 184, b: 249) }
    
    public static var blue_Orient: Color { Color(r: 2, g: 98, b: 139) }
}

#Preview("Color") {
    #if os(watchOS)
    let columns = [GridItem(.adaptive(minimum: 30, maximum: 40), spacing: 6)]
    let colorLength: CGFloat = 30
    #else
    let columns = [GridItem(.adaptive(minimum: 70, maximum: 80), spacing: 8)]
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
        Section("自定义渐变色") {
            systemColor(SimpleColorModel.allGradient_Green)
            systemColor(SimpleColorModel.allGradient_Blue)
            systemColor(SimpleColorModel.allGradient_Red)
            systemColor(SimpleColorModel.allGradient_Pink)
            systemColor(SimpleColorModel.allGradient_Purple)
        }
        Section("自定义颜色") {
            systemColor(SimpleColorModel.allGray)
            systemColor(SimpleColorModel.allGreen)
            systemColor(SimpleColorModel.allBlue)
            systemColor(SimpleColorModel.allPurple)
            systemColor(SimpleColorModel.allRed)
            systemColor(SimpleColorModel.allYellow)
        }
    }
    .formStyle(.grouped)
}
