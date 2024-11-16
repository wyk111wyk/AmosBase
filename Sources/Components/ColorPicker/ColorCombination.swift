//
//  SwiftUIView.swift
//  AmosBase
//
//  Created by AmosFitness on 2024/11/16.
//

import SwiftUI

public struct ColorCombination: Identifiable {
    public var id: UUID = UUID()
    
    let titleColor: Color
    let authorColor: Color
    let contentColor: Color
    let backgroundColor: Color
    let isShowMetrial: Bool
    let bgBackgroundColor: Color
    
    public init(
        titleColor: Color,
        authorColor: Color,
        contentColor: Color,
        backgroundColor: Color,
        isShowMetrial: Bool,
        bgBackgroundColor: Color
    ) {
        self.titleColor = titleColor
        self.authorColor = authorColor
        self.contentColor = contentColor
        self.backgroundColor = backgroundColor
        self.isShowMetrial = isShowMetrial
        self.bgBackgroundColor = bgBackgroundColor
    }
    
    public static var styleDefault: ColorCombination {
        ColorCombination(
            titleColor: .primary,
            authorColor: .secondary,
            contentColor: .primary,
            backgroundColor: .white,
            isShowMetrial: true,
            bgBackgroundColor: .white
        )
    }
    
    public static var style01: ColorCombination {
        ColorCombination(
            titleColor: .hexColor("#202f39"),
            authorColor: .hexColor("#435f87"),
            contentColor: .hexColor("#202f39"),
            backgroundColor: .hexColor("#fffbf0"),
            isShowMetrial: false,
            bgBackgroundColor: .hexColor("#435f87")
        )
    }
    
    public static var style02: ColorCombination {
        ColorCombination(
            titleColor: .hexColor("#f8f7f2"),
            authorColor: .hexColor("#f8f7f2"),
            contentColor: .hexColor("#f8f7f2"),
            backgroundColor: .hexColor("#415d60"),
            isShowMetrial: false,
            bgBackgroundColor: .hexColor("#bacaca")
        )
    }
    
    public static var style03: ColorCombination {
        ColorCombination(
            titleColor: .hexColor("#236b53"),
            authorColor: .hexColor("#478b38"),
            contentColor: .hexColor("#236b53"),
            backgroundColor: .hexColor("#f2f9f2"),
            isShowMetrial: false,
            bgBackgroundColor: .hexColor("#236b53")
        )
    }
    
    public static var style04: ColorCombination {
        ColorCombination(
            titleColor: .hexColor("#fffbf0"),
            authorColor: .hexColor("#fffbf0"),
            contentColor: .hexColor("#bacac6"),
            backgroundColor: .hexColor("#2b5a6c"),
            isShowMetrial: false,
            bgBackgroundColor: .hexColor("#627481")
        )
    }
    
    public static var style05: ColorCombination {
        ColorCombination(
            titleColor: .hexColor("#57656e"),
            authorColor: .hexColor("#57656e"),
            contentColor: .hexColor("#57656e"),
            backgroundColor: .hexColor("#d6ecf0"),
            isShowMetrial: false,
            bgBackgroundColor: .hexColor("#57656e")
        )
    }
    
    public static var style06: ColorCombination {
        ColorCombination(
            titleColor: .hexColor("#a68178"),
            authorColor: .hexColor("#a68178"),
            contentColor: .hexColor("#a68178"),
            backgroundColor: .hexColor("#f2eadd"),
            isShowMetrial: false,
            bgBackgroundColor: .hexColor("#9c2831")
        )
    }
    
    public static var style07: ColorCombination {
        ColorCombination(
            titleColor: .hexColor("#2d3f32"),
            authorColor: .hexColor("#2d3f32"),
            contentColor: .hexColor("#2d3f32"),
            backgroundColor: .hexColor("#c7b182"),
            isShowMetrial: false,
            bgBackgroundColor: .hexColor("#406465")
        )
    }
    
    public static var style08: ColorCombination {
        ColorCombination(
            titleColor: .hexColor("#f0f2f1"),
            authorColor: .hexColor("#f0f2f1"),
            contentColor: .hexColor("#f0f2f1"),
            backgroundColor: .hexColor("#534739"),
            isShowMetrial: false,
            bgBackgroundColor: .hexColor("#9e8775")
        )
    }
    
    public static var style09: ColorCombination {
        ColorCombination(
            titleColor: .hexColor("#dcfafa"),
            authorColor: .hexColor("#fffbf0"),
            contentColor: .hexColor("#dcfafa"),
            backgroundColor: .hexColor("#003472"),
            isShowMetrial: false,
            bgBackgroundColor: .hexColor("#8fb9d1")
        )
    }
    
    public static var style10: ColorCombination {
        ColorCombination(
            titleColor: .hexColor("#fffbf0"),
            authorColor: .hexColor("#fffbf0"),
            contentColor: .hexColor("#fffbf0"),
            backgroundColor: .hexColor("#815476"),
            isShowMetrial: false,
            bgBackgroundColor: .hexColor("#d3a2b9")
        )
    }
    
    public static var style11: ColorCombination {
        ColorCombination(
            titleColor: .hexColor("#e3f9fd"),
            authorColor: .hexColor("#e9e7ef"),
            contentColor: .hexColor("#e3f9fd"),
            backgroundColor: .hexColor("#5d8797"),
            isShowMetrial: false,
            bgBackgroundColor: .hexColor("#78abaf")
        )
    }
    
    public static var style12: ColorCombination {
        ColorCombination(
            titleColor: .hexColor("#d6ecf0"),
            authorColor: .hexColor("#e9e7ef"),
            contentColor: .hexColor("#d3e4ee"),
            backgroundColor: .hexColor("#737f6d"),
            isShowMetrial: false,
            bgBackgroundColor: .hexColor("#bacaca")
        )
    }
    
    public static var style13: ColorCombination {
        ColorCombination(
            titleColor: .hexColor("#f1f2f4"),
            authorColor: .hexColor("#e9e7ef"),
            contentColor: .hexColor("#f1f2f4"),
            backgroundColor: .hexColor("#082b41"),
            isShowMetrial: false,
            bgBackgroundColor: .hexColor("#105286")
        )
    }
    
    public static var style14: ColorCombination {
        ColorCombination(
            titleColor: .hexColor("#dcd9cc"),
            authorColor: .hexColor("#dcd9cc"),
            contentColor: .hexColor("#dcd9cc"),
            backgroundColor: .hexColor("#992f33"),
            isShowMetrial: false,
            bgBackgroundColor: .hexColor("#2f323c")
        )
    }
    
    public static var style15: ColorCombination {
        ColorCombination(
            titleColor: .hexColor("#eee9d3"),
            authorColor: .hexColor("#eee9d3"),
            contentColor: .hexColor("#eee9d3"),
            backgroundColor: .hexColor("#523c4b"),
            isShowMetrial: false,
            bgBackgroundColor: .hexColor("#c3b5ac")
        )
    }
    
    public static var style16: ColorCombination {
        ColorCombination(
            titleColor: .hexColor("#345760"),
            authorColor: .hexColor("#345760"),
            contentColor: .hexColor("#345760"),
            backgroundColor: .hexColor("#b0ccd3"),
            isShowMetrial: false,
            bgBackgroundColor: .hexColor("#508e8f")
        )
    }
    
    public static var style17: ColorCombination {
        ColorCombination(
            titleColor: .hexColor("#b27573"),
            authorColor: .hexColor("#b27573"),
            contentColor: .hexColor("#b27573"),
            backgroundColor: .hexColor("#f3e6c8"),
            isShowMetrial: false,
            bgBackgroundColor: .hexColor("#d0a596")
        )
    }
    
    public func combinButton<S: Shape>(
        shape: S = Circle(),
        tapAction: @escaping (ColorCombination) -> Void = {_ in}
    ) -> some View {
        PlainButton {
            tapAction(self)
        } label: {
            HStack(spacing: 1) {
                Rectangle().foregroundStyle(contentColor)
                Rectangle().foregroundStyle(backgroundColor)
                Rectangle().foregroundStyle(bgBackgroundColor)
            }
            .clipShape(shape)
            .padding(5)
            .shadow(radius: 2,x: 1, y: 1)
        }
    }
    
    public static var allColor: [ColorCombination]  {[
        .styleDefault, .style01, .style02, .style03, .style04, .style05, .style06, .style07, .style08, .style09, .style10, .style11, .style12, .style13, .style14, .style15, .style16, .style17
    ]}
}

#Preview {
    let columns = [GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 8)]
    ScrollView {
        LazyVGrid(columns: columns, spacing: 12){
            ForEach(ColorCombination.allColor) { combin in
                combin.combinButton(shape: RoundedRectangle(cornerRadius: 8))
                    .frame(width: 100, height: 100)
            }
        }
        .padding()
    }
}
