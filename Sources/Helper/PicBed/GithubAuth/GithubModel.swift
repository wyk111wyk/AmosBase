//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/5/15.
//

import Foundation

public struct GithubRepoFileAddModel: Codable {
    let content: GithubRepoFileListModel
}

public struct GithubRepoFileListModel: Codable, Identifiable {
    public var id: String { sha }
    public let name: String // 202405141424217.jpeg
    public let path: String // PicGo/202405141424217.jpeg
    public let sha: String // 6147762f0739589b2696ba45cb002c2aa1c4b790
    public let size: Double // 3605504
    public let type: String // file
    public let download_url: String // "https://raw.githubusercontent.com/wyk111wyk/PicBed/main/PicGo/202405141424217.jpeg"
    
    public var imageUrl: URL? {
        URL(string: download_url)
    }
}
