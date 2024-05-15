//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/5/14.
//

import Foundation

public class SimplePicBed: GithubAPI {
    // Personal Access Tokens: For PicGo
    // Expires on Wed, May 14 2025
    let token: String = "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"
    let repo = "PicBed"
    let owner = "wyk111wyk"
    let branch = "main"
    let defaultPath = "AmosBase/"
    
    public init() {
        let authentication = TokenGithubAuth(token: token)
        super.init(authentication: authentication)
    }
    
    /// 获取 Path 内的所有文件
    public func fetchFileList(path: String? = nil) async -> [GithubRepoFileListModel] {
        let filePath: String = if let path { path } else { defaultPath }
        let fetchPath = "/repos/\(owner)/\(repo)/contents/\(filePath)"
        
        do {
            let fileList: [GithubRepoFileListModel]? = try await self.gh_get(path: fetchPath)
            return fileList ?? []
        }catch {
            debugPrint("读取所有文件失败: \(error)")
            return []
        }
    }
    
    /// 从服务器删除一个文件
    @discardableResult
    public func deleteFile(for gitImage: GithubRepoFileListModel) async -> Bool {
        let detetePath = "/repos/\(owner)/\(repo)/contents/\(gitImage.path)"
        let bodyJson: [String: String] = [
            "message": "Deleted by AmosBase",
            "branch": branch,
            "sha": gitImage.sha
        ]
        
        do {
            return try await self.delete(path: detetePath, body: bodyJson.jsonData())
        }catch {
            debugPrint("删除一个文件\(gitImage.name)失败: \(error)")
            return false
        }
    }
    
    // https://docs.github.com/zh/rest/repos/contents?apiVersion=2022-11-28#create-or-update-file-contents
    // 令牌必须具有以下权限集: contents:write
    // PUT /repos/{owner}/{repo}/contents/{path}
    /// content: Base64编码的文件
    @discardableResult
    public func uploadFile(
        content: String,
        name: String,
        type: String = "png",
        path: String? = nil
    ) async -> URL? {
        let filePath: String = if let path { path } else { defaultPath }
        let finalPath = "/repos/\(owner)/\(repo)/contents/\(filePath)\(name).\(type)"
        let bodyJson: [String: String] = [
            "message": "Upload by AmosBase",
            "branch": branch,
            "content": content
        ]
        
        do {
            let responseData = try await self.gh_put(
                path: finalPath,
                body: bodyJson.jsonData()
            )
            if let model = responseData?.decode(type: GithubRepoFileAddModel.self) {
                debugPrint(model.content)
                return URL(string: model.content.download_url)
            }else {
                return nil
            }
        }catch {
            debugPrint("上传文件失败: \(error)")
            return nil
        }
    }
}
