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
    
    // MARK: - Brown
    public static var brown_01: Color { Color(hex: "#FAF6F0")! }
    
    public static var brown_02: Color { Color(hex: "#F2E5D3")! }
    
    public static var brown_03: Color { Color(hex: "#E3C7A4")! }
    
    public static var brown_04: Color { Color(hex: "#D5A874")! }
    
    public static var brown_05: Color { Color(hex: "#CB8E54")! }
    
    public static var brown_06: Color { Color(hex: "#C07240")! }
    
    public static var brown_07: Color { Color(hex: "#A85835")! }
    
    public static var brown_08: Color { Color(hex: "#8E422F")! }
    
    public static var brown_09: Color { Color(hex: "#74362C")! }
    
    public static var brown_10: Color { Color(hex: "#602F27")! }
    
    // MARK: - Indigo
    public static var indigo_01: Color { Color(hex: "#F2F6FB")! }
    
    public static var indigo_02: Color { Color(hex: "#E6EFF9")! }
    
    public static var indigo_03: Color { Color(hex: "#D2E0F3")! }
    
    public static var indigo_04: Color { Color(hex: "#B7CAEA")! }
    
    public static var indigo_05: Color { Color(hex: "#9AAEDF")! }
    
    public static var indigo_06: Color { Color(hex: "#778BD0")! }
    
    public static var indigo_07: Color { Color(hex: "#6775C4")! }
    
    public static var indigo_08: Color { Color(hex: "#5661AC")! }
    
    public static var indigo_09: Color { Color(hex: "#48528B")! }
    
    public static var indigo_10: Color { Color(hex: "#3F4770")! }
    
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
    
    // MARK: - Teal
    public static var teal_01: Color { Color(hex: "#F5F5F0")! }
    
    public static var teal_02: Color { Color(hex: "#E8EADD")! }
    
    public static var teal_03: Color { Color(hex: "#D2D7BF")! }
    
    public static var teal_04: Color { Color(hex: "#B5BD99")! }
    
    public static var teal_05: Color { Color(hex: "#9AA477")! }
    
    public static var teal_06: Color { Color(hex: "#808C5C")! }
    
    public static var teal_07: Color { Color(hex: "#616B45")! }
    
    public static var teal_08: Color { Color(hex: "#4B5437")! }
    
    public static var teal_09: Color { Color(r: 63, g: 67, b: 48) }
    
    public static var teal_10: Color { Color(hex: "#363C2B")! }
    
    // MARK: - Orange
    public static var orange_01: Color { Color(hex: "#FEF2D6")! }
    
    public static var orange_02: Color { Color(hex: "#FDE4AF")! }
    
    public static var orange_03: Color { Color(hex: "#FBD18B")! }
    
    public static var orange_04: Color { Color(hex: "#F9BD6F")! }
    
    public static var orange_05: Color { Color(hex: "#F7A049")! }
    
    public static var orange_06: Color { Color(hex: "#EE9C4B")! }
    
    public static var orange_07: Color { Color(hex: "#ED8B3C")! }
    
    public static var orange_08: Color { Color(hex: "#EC7A2E")! }
    
    public static var orange_09: Color { Color(hex: "#EB6821")! }
    
    public static var orange_10: Color { Color(hex: "#EA5514")! }
    
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
            systemColor(SimpleColorModel.allGradient_Orange)
            systemColor(SimpleColorModel.allGradient_Teal)
            systemColor(SimpleColorModel.allGradient_Brown)
            systemColor(SimpleColorModel.allGradient_Indigo)
            systemColor(SimpleColorModel.allGradient_Green)
            systemColor(SimpleColorModel.allGradient_Blue)
            systemColor(SimpleColorModel.allGradient_Red)
            systemColor(SimpleColorModel.allGradient_Pink)
            systemColor(SimpleColorModel.allGradient_Purple)
        }
    }
    .formStyle(.grouped)
}
