//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/4/7.
//

import Foundation

@available(iOS 16, macOS 13, watchOS 9, *)
public class SimpleFileHelper {
    let file = FileManager.default
    
    public init() {}
    
    public struct FileInfo: Identifiable {
        public var id: UUID
        var name: String
        var suffix: String
        var size: Double
        var path: URL
        
        public init(id: UUID = UUID(), name: String, suffix: String, size: Double, path: URL) {
            self.id = id
            self.name = name
            self.suffix = suffix
            self.size = size
            self.path = path
        }
    }
    
    /// 获取（创建）文件夹路径URL
    func folderPath(_ folderName: String? = "audioFile", isCreate: Bool = true) -> URL? {
        // 获取文档目录路径
        guard let documentsDirectory = file.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        // 创建文件夹路径
        var folderDirectory = documentsDirectory
        if let folderName {
            folderDirectory = documentsDirectory.appendingPathComponent(folderName)
        }
        
        // 检查audioFile文件夹是否存在，如果不存在则创建
        if !file.fileExists(atPath: folderDirectory.path()), isCreate {
            do {
                try file.createDirectory(at: folderDirectory, withIntermediateDirectories: true)
            } catch {
                return nil
            }
        }
        return folderDirectory
    }

    /// 获取（创建）某个文件的路径 URL
    func filePath(
        _ fileName: String,
        folderName: String? = "audioFile",
        suffix: String? = "wav"
    ) -> URL? {
        // 获取文档目录路径
        guard let folderPath = folderPath(folderName) else {
            return nil
        }
        
        // 构建最终的文件路径
        let fullFileName: String =
        if let suffix { "\(fileName).\(suffix)" }
        else { fileName }
        
        let finalFilePath = folderPath.appendingPathComponent(fullFileName)
        if !file.fileExists(atPath: finalFilePath.path()) {
            file.createFile(atPath: finalFilePath.path(), contents: nil, attributes: nil)
        }
        
        // 返回文件路径的字符串表示
        return finalFilePath
    }

    /// 获取文件夹内所有文件的URL路径
    func fetchFileURL(_ folderPath: URL) -> [URL] {
        do {
            let fileURLs = try file.contentsOfDirectory(at: folderPath, includingPropertiesForKeys: nil)
            return fileURLs
        } catch {
            debugPrint("Error fetching folder files: \(error)")
            return []
        }
    }
    
    /// 获取文件夹内所有的文件
    func fetchFiles(_ folderPath: URL) -> [FileInfo] {
        do {
            var filesInfo: [FileInfo] = []
            for fileURL in fetchFileURL(folderPath) {
                let attributes = try file.attributesOfItem(atPath: fileURL.path())
                let fileSize = attributes[FileAttributeKey.size] as? UInt64 ?? 0
                let fileInfo = FileInfo(name: fileURL.deletingPathExtension().lastPathComponent,
                                        suffix: fileURL.pathExtension,
                                        size: Double(fileSize),
                                        path: fileURL)
                filesInfo.append(fileInfo)
            }
            return filesInfo
        }catch {
            debugPrint("获取文件列表错误：\(error)")
            return []
        }
    }
    
    /// 删除指定路径的文件
    @discardableResult
    func deleteFile(_ filePath: URL) -> Bool {
        do {
            try file.removeItem(at: filePath)
            return true
        } catch {
            debugPrint("删除文件失败：\(error)")
            return false
        }
    }
    
    /// 重命名文件
    @discardableResult
    func renameFile(_ filePath: URL) -> Bool {
        do {
            let fileName = filePath.deletingPathExtension().lastPathComponent
            let suffix = filePath.pathExtension
            let newFilePath = filePath.deletingLastPathComponent().appendingPathComponent(fileName + ".\(suffix)")
            try file.moveItem(at: filePath, to: newFilePath)
            return true
        } catch {
            debugPrint("重命名文件失败：\(error)")
            return false
        }
    }
}
