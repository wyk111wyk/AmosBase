//
//  File.swift
//  
//
//  Created by AmosFitness on 2024/3/24.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct Options {
    /// By default, files are saved into searchPathDirectory/folder
    public var searchPathDirectory: FileManager.SearchPathDirectory
    public var folder: String = (Bundle.main.bundleIdentifier ?? "").appending("/DefaultCache")

    /// Optionally, you can set predefined directory for where to save files
    public var directoryUrl: URL? = nil

    public var encoder: JSONEncoder = JSONEncoder()
    public var decoder: JSONDecoder = JSONDecoder()

    public init() {
        #if os(tvOS)
        searchPathDirectory = .cachesDirectory
        #else
        searchPathDirectory = .applicationSupportDirectory
        #endif
    }
}

public class SimpleCache {
    public enum StorageError: Error {
        case notFound
        case encodeData
        case decodeData
        case createFile
        case missingFileAttributeKey(key: FileAttributeKey)
        case expired(maxAge: Double)
    }
    
    public enum Expiry {
        case never
        case maxAge(maxAge: TimeInterval)
    }
    
    public let cache = NSCache<NSString, AnyObject>()
    public let options: Options
    public let folderUrl: URL
    public let fileManager: FileManager = .default
    
    public init(options: Options = .init()) throws {
        self.options = options

        var url: URL
        if let directoryUrl = options.directoryUrl {
            url = directoryUrl
        } else {
            url = try fileManager.url(
                for: options.searchPathDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
        }

        self.folderUrl = url
            .appendingPathComponent(options.folder, isDirectory: true)

        do {
            try createDirectoryIfNeeded(folderUrl: folderUrl)
            try applyAttributesIfAny(folderUrl: folderUrl)
        }catch {
            debugPrint("初始化Cache错误：")
            debugPrint(error)
        }
    }
    
    // MARK: - 常用的方法
    func createDirectoryIfNeeded(folderUrl: URL) throws {
        var isDirectory = ObjCBool(true)
        guard !fileManager.fileExists(atPath: folderUrl.path, isDirectory: &isDirectory) else {
            return
        }

        try fileManager.createDirectory(
            atPath: folderUrl.path,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }

    public func exists(forKey key: String) -> Bool {
        return fileManager.fileExists(atPath: fileUrl(forKey: key).path)
    }

    public func removeAll() throws {
        cache.removeAllObjects()
        try fileManager.removeItem(at: folderUrl)
        try createDirectoryIfNeeded(folderUrl: folderUrl)
    }

    public func remove(forKey key: String) throws {
        cache.removeObject(forKey: key as NSString)
        try fileManager.removeItem(at: fileUrl(forKey: key))
    }

    public func fileUrl(forKey key: String) -> URL {
        return folderUrl.appendingPathComponent(key, isDirectory: false)
    }
}

extension SimpleCache {

    func applyAttributesIfAny(folderUrl: URL) throws {
        #if os(iOS) || os(tvOS)
            let attributes: [FileAttributeKey: Any] = [
                FileAttributeKey.protectionKey: FileProtectionType.complete
            ]

            try fileManager.setAttributes(attributes, ofItemAtPath: folderUrl.path)
        #endif
    }
    
    func verify(
        maxAge: TimeInterval,
        forKey key: String,
        fromDate date: @escaping (() -> Date) = { Date() }
    ) throws -> Bool {
        date().timeIntervalSince(try modificationDate(forKey: key)) <= maxAge
    }
    
    func commonSave(object: AnyObject, forKey key: String, toData: () throws -> Data) throws {
        let data = try toData()
        cache.setObject(object, forKey: key as NSString)
        try fileManager
            .createFile(atPath: fileUrl(forKey: key).path, contents: data, attributes: nil)
            .trueOrThrow(StorageError.createFile)
    }

    func commonLoad<T>(forKey key: String,
                       withExpiry expiry: Expiry,
                       fromDate date: @escaping (() -> Date) = { Date() },
                       fromData: (Data) throws -> T) throws -> T {
        switch expiry {
        case .never:
            break
        case .maxAge(let maxAge):
            guard try verify(maxAge: maxAge, forKey: key, fromDate: date) else {
                throw StorageError.expired(maxAge: maxAge)
            }
        }
        
        if let object = cache.object(forKey: key as NSString) as? T {
            return object
        } else {
            let data = try Data(contentsOf: fileUrl(forKey: key))
            let object = try fromData(data)
            cache.setObject(object as AnyObject, forKey: key as NSString)
            return object
        }
    }
}

// MARK: - Codable
extension SimpleCache {
    // 处理Data
    func save(object: Data, forKey key: String) throws {
        try commonSave(object: object as AnyObject, forKey: key, toData: { object })
    }
    
    func load(forKey key: String, withExpiry expiry: Expiry = .never) throws -> Data {
        return try commonLoad(forKey: key, withExpiry: expiry, fromData: { $0 })
    }
    
    // 处理图片
    func save(image: SFImage, forKey key: String) throws {
        try commonSave(object: image as AnyObject, forKey: key, toData: {
            return try unwrapOrThrow(Utils.data(image: image), StorageError.encodeData)
        })
    }
    
    func loadImage(forKey key: String, withExpiry expiry: Expiry = .never) throws -> SFImage {
        return try commonLoad(forKey: key, withExpiry: expiry, fromData: { data in
            return try unwrapOrThrow(Utils.image(data: data), StorageError.decodeData)
        })
    }
    
    func save<T: Codable>(object: T, forKey key: String) throws {
        let encoder = options.encoder
        try commonSave(object: object as AnyObject, forKey: key, toData: {
            do {
                return try encoder.encode(object)
            } catch {
                let typeWrapper = TypeWrapper(object: object)
                return try encoder.encode(typeWrapper)
            }
        })
    }
    
    func load<T: Codable>(forKey key: String, as: T.Type, withExpiry expiry: Expiry = .never) throws -> T {
        func loadFromDisk<E: Codable>(forKey key: String, as: E.Type) throws -> E {
            let data = try Data(contentsOf: fileUrl(forKey: key))
            let decoder = options.decoder
            
            do {
                let object = try decoder.decode(E.self, from: data)
                return object
            } catch {
                let typeWrapper = try decoder.decode(TypeWrapper<E>.self, from: data)
                return typeWrapper.object
            }
        }
        
        return try commonLoad(forKey: key, withExpiry: expiry, fromData: { data in
            return try loadFromDisk(forKey: key, as: T.self)
        })
    }
}

extension SimpleCache {
    /// Get folder size in byte
    func folderSize() throws -> UInt64 {
        var totalSize: UInt64 = 0
        let contents = try fileManager.contentsOfDirectory(atPath: folderUrl.path)
        try contents.forEach { content in
            let fileUrl = folderUrl.appendingPathComponent(content)
            let attributes = try fileManager.attributesOfItem(atPath: fileUrl.path)
            if let size = attributes[.size] as? UInt64 {
                totalSize += size
            }
        }
        
        return totalSize
    }
    
    func folderSizeText() -> String {
        if let sizeString = try? Double(folderSize()).toStorage(unit: .bytes, outUnit: .megabits) {
            return sizeString
        }else {
            return "0 kb"
        }
    }
    
    /// Check if folder has no files
    func isEmpty() throws -> Bool {
        let contents = try fileManager.contentsOfDirectory(atPath: folderUrl.path)
        return contents.isEmpty
    }

    func files() throws -> [File] {
        let contents = try fileManager.contentsOfDirectory(atPath: folderUrl.path)
        let files: [File] = try contents.map { try file(forKey: $0) }
        return files
    }

    /// Remove all files matching predicate
    func removeAll(predicate: (File) -> Bool) throws {
        let files = try self.files().filter(predicate)
        try files.forEach {
            cache.removeObject(forKey: $0.name as NSString)
            try remove(forKey: $0.name)
        }
    }
    
    func file(forKey key: String) throws -> File {
        let fileUrl = self.fileUrl(forKey: key)
        let attributes = try fileManager.attributesOfItem(atPath: fileUrl.path)
        let modificationDate: Date? = attributes[.modificationDate] as? Date
        let size: UInt64? = attributes[.size] as? UInt64

        return File(
            name: key,
            url: fileUrl,
            modificationDate: modificationDate,
            size: size
        )
    }
    
    func modificationDate(forKey key: String) throws -> Date {
        guard let modificationDate = try file(forKey: key).modificationDate else {
            throw StorageError.missingFileAttributeKey(key: .modificationDate)
        }
        return modificationDate
    }
}

func unwrapOrThrow<T>(_ optional: Optional<T>, _ error: Error) throws -> T {
    if let value = optional {
        return value
    } else {
        throw error
    }
}

extension Bool {
    func trueOrThrow(_ error: Error) throws {
        if !self {
            throw error
        }
    }
}

/// Use to wrap primitive Codable
public struct TypeWrapper<T: Codable>: Codable {
    enum CodingKeys: String, CodingKey {
        case object
    }

    public let object: T

    public init(object: T) {
        self.object = object
    }
}

class Utils {
    static func image(data: Data) -> SFImage? {
        #if canImport(UIKit)
        return UIImage(data: data)
        #elseif canImport(AppKit)
        return NSImage(data: data)
        #else
        return nil
        #endif
    }

    static func data(image: SFImage) -> Data? {
        #if canImport(UIKit)
        return image.jpegData(compressionQuality: 0.9)
        #elseif canImport(AppKit)
        return image.tiffRepresentation
        #else
        return nil
        #endif
    }
}

public struct File {
    public let name: String
    public let url: URL
    public let modificationDate: Date?
    public let size: UInt64?
}
