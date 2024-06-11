//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/2/28.
//

import Foundation
import SwiftUI

public protocol SimpleImageStore {
    var id: String { get set }
    var image: SFImage { get set }
    var caption: String?  { get set }
}

public struct ImageStoreModel: SimpleImageStore, Identifiable {
    public var id: String
    public var image: SFImage
    public var caption: String?
    
    init(
        id: String = UUID().uuidString,
        image: SFImage,
        caption: String? = nil
    ) {
        self.id = id
        self.image = image
        self.caption = caption
    }
    
    static func examples() -> [ImageStoreModel] {
        let images: [SFImage] = [.init(packageResource: "IMG_5151", ofType: "jpeg")!,
                                 .init(packageResource: "IMG_5153", ofType: "jpeg")!]
        let allImages:[ImageStoreModel] = images.compactMap {
            ImageStoreModel(image: $0, caption: "caption") }
        return allImages
    }
}
