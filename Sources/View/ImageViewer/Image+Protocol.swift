//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/2/28.
//

import Foundation
import SwiftUI

#if os(iOS)
public protocol SimpleImageStore {
    var image: UIImage { get set }
    var caption: String?  { get set }
}

public struct ImageStoreModel: SimpleImageStore {
    public var image: UIImage
    public var caption: String?
    
    static func examples() -> [ImageStoreModel] {
        let images: [UIImage] = [.init(packageResource: "IMG_5151", ofType: "jpeg")!,
                                 .init(packageResource: "IMG_5153", ofType: "jpeg")!]
        let allImages:[ImageStoreModel] = images.compactMap {
            ImageStoreModel(image: $0, caption: "caption") }
        return allImages
    }
}
#endif
