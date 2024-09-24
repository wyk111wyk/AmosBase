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
    static let gray_Space = Color(r: 45, g: 67, b: 67)
    
    static let gray_Charade = Color(r: 133, g: 134, b: 139)
    
    static let gray_Hit = Color(r: 150, g: 165, b: 173)
    
    static let gray_Nurse = Color(r: 222, g: 229, b: 221)
    
    // MARK: - Brown
    static let brown_Tundora = Color(r: 168, g: 139, b: 76)
    
    static let brown_Americano = Color(r: 200, g: 178, b: 114)
    
    static let brown_Gurkha = Color(r: 83, g: 72, b: 50)
    
    // MARK: - Purple
    static let purple_01 = Color(r: 248, g: 240, b: 252)
    
    static let purple_02 = Color(r: 243, g: 217, b: 250)
    
    static let purple_03 = Color(r: 238, g: 190, b: 250)
    
    static let purple_04 = Color(r: 229, g: 153, b: 247)
    
    static let purple_05 = Color(r: 218, g: 119, b: 242)
    
    static let purple_06 = Color(r: 204, g: 93, b: 232)
    
    static let purple_07 = Color(r: 190, g: 75, b: 219)
    
    static let purple_08 = Color(r: 174, g: 62, b: 201)
    
    static let purple_09 = Color(r: 156, g: 54, b: 181)
    
    static let purple_10 = Color(r: 134, g: 46, b: 156)
    
    static let purple_Heliotrope = Color(r: 147, g: 119, b: 255)
    
    static let purple_Wisteria = Color(r: 148, g: 105, b: 174)
    
    static let purple_Spindle = Color(r: 195, g: 188, b: 235)
    
    static let purple_Razzle = Color(r: 255, g: 75, b: 186)
    
    // MARK: - Pink
    static let pink_01 = Color(r: 255, g: 240, b: 246)
    
    static let pink_02 = Color(r: 255, g: 222, b: 235)
    
    static let pink_03 = Color(r: 252, g: 194, b: 215)
    
    static let pink_04 = Color(r: 250, g: 162, b: 193)
    
    static let pink_05 = Color(r: 247, g: 131, b: 172)
    
    static let pink_06 = Color(r: 240, g: 101, b: 149)
    
    static let pink_07 = Color(r: 230, g: 73, b: 128)
    
    static let pink_08 = Color(r: 214, g: 51, b: 108)
    
    static let pink_09 = Color(r: 194, g: 37, b: 92)
    
    static let pink_10 = Color(r: 166, g: 30, b: 77)
    
    static let pink_Orchid = Color(r: 235, g: 176, b: 224)
    
    // MARK: - Yellow
    static let yellow_Champagne = Color(r: 251, g: 233, b: 206)
    
    static let yellow_Rajah = Color(r: 250, g: 189, b: 115)
    
    static let yellow_Bus = Color(r: 247, g: 218, b: 0)
    
    static let yellow_Sandy = Color(r: 215, g: 174, b: 4)
    
    static let yellow_Golden = Color(r: 240, g: 231, b: 52)
    
    static let yellow_Neon = Color(r: 255, g: 145, b: 43)
    
    // MARK: - Red
    static let red_01 = Color(r: 255, g: 245, b: 245)
    
    static let red_02 = Color(r: 255, g: 227, b: 227)
    
    static let red_03 = Color(r: 255, g: 201, b: 201)
    
    static let red_04 = Color(r: 255, g: 168, b: 168)
    
    static let red_05 = Color(r: 255, g: 135, b: 135)
    
    static let red_06 = Color(r: 255, g: 107, b: 107)
    
    static let red_07 = Color(r: 250, g: 82, b: 82)
    
    static let red_08 = Color(r: 240, g: 62, b: 62)
    
    static let red_09 = Color(r: 244, g: 49, b: 49)
    
    static let red_10 = Color(r: 201, g: 42, b: 42)
    
    static let red_Sunglo = Color(r: 171, g: 56, b: 27)
    
    static let red_Geraldine = Color(r: 249, g: 135, b: 127)
    
    static let red_Sunset = Color(r: 254, g: 79, b: 66)
    
    static let red_Amaranth = Color(r: 240, g: 58, b: 104)
    
    static let red_Lipstick = Color(r: 201, g: 5, b: 106)
    
    static let red_vivid = Color(r: 253, g: 154, b: 121)
    
    static let red_Peach = Color(r: 250, g: 194, b: 185)
    
    // MARK: - Green
    static let green_01 = Color(r: 241, g: 252, b: 249)
    
    static let green_02 = Color(r: 209, g: 246, b: 237)
    
    static let green_03 = Color(r: 162, g: 237, b: 220)
    
    static let green_04 = Color(r: 105, g: 219, b: 198)
    
    static let green_05 = Color(r: 62, g: 195, b: 174)
    
    static let green_06 = Color(r: 37, g: 167, b: 149)
    
    static let green_07 = Color(r: 27, g: 134, b: 122)
    
    static let green_08 = Color(r: 25, g: 108, b: 99)
    
    static let green_09 = Color(r: 25, g: 86, b: 80)
    
    static let green_10 = Color(r: 25, g: 72, b: 68)
    
    static let green_Pastel = Color(red: 130/255, green: 219/255, blue: 136/255)
    
    static let green_Spring = Color(r: 18, g: 243, b: 149)
    
    static let green_Caribbean = Color(r: 10, g: 220, b: 146)
    
    static let green_Downy = Color(r: 122, g: 209, b: 189)
    
    static let green_Ice = Color(r: 171, g: 245, b: 225)
    
    static let green_Keppel = Color(r: 51, g: 162, b: 138)
    
    static let green_Olive = Color(r: 152, g: 152, b: 2)
    
    static let green_Leaf = Color(r: 77, g: 93, b: 11)
    
    // MARK: - Blue
    static let blue_01 = Color(r: 242, g: 249, b: 253)
    
    static let blue_02 = Color(r: 229, g: 240, b: 249)
    
    static let blue_03 = Color(r: 196, g: 226, b: 243)
    
    static let blue_04 = Color(r: 144, g: 202, b: 233)
    
    static let blue_05 = Color(r: 85, g: 174, b: 219)
    
    static let blue_06 = Color(r: 48, g: 148, b: 199)
    
    static let blue_07 = Color(r: 32, g: 118, b: 169)
    
    static let blue_08 = Color(r: 27, g: 95, b: 137)
    
    static let blue_09 = Color(r: 28, g: 86, b: 121)
    
    static let blue_10 = Color(r: 27, g: 68, b: 95)
    
    static let blue_French = Color(r: 174, g: 254, b: 252)
    
    static let blue_Regal = Color(r: 1, g: 67, b: 105)
    
    static let blue_Downy = Color(r: 104, g: 194, b: 210)
    
    static let blue_Neptune = Color(r: 127, g: 170, b: 189)
    
    static let blue_Cornflower = Color(r: 102, g: 151, b: 243)
    
    static let blue_Seagull = Color(r: 123, g: 179, b: 225)
    
    static let blue_Picton = Color(r: 73, g: 184, b: 249)
    
    static let blue_Orient = Color(r: 2, g: 98, b: 139)
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
            systemColor(SimpleColorModel.allGradient_Blue)
            systemColor(SimpleColorModel.allGradient_Red)
            systemColor(SimpleColorModel.allGradient_Pink)
            systemColor(SimpleColorModel.allGradient_Green)
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
