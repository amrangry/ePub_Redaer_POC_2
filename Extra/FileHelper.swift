//
//  FileHelper.swift
//  Adka
//
//  Created by Amr ELghadban on 6/27/18.
//  Copyright © 2018 Adka. All rights reserved.
//

import UIKit

extension FileHelper {
    enum DirectoryDomain {
        case localStorage
        case sandBoxStorage
        case tempStorage
        
        var value: FileManager.SearchPathDirectory {
            switch self {
            case .localStorage:
                return .documentDirectory
            case .sandBoxStorage:
                return .applicationSupportDirectory
            case .tempStorage:
                return .cachesDirectory
            }
        }
    }
    
    func directoryPathURL(for domain: DirectoryDomain) -> URL? {
        FileManager.default.urls(for: domain.value, in: .userDomainMask).first
    }
    
    func directoryPathString(for domain: DirectoryDomain) -> String? {
        //FileManager.default.urls(for: domain.value, in: .userDomainMask)
        NSSearchPathForDirectoriesInDomains(domain.value, .userDomainMask, true).first
    }
}

class FileHelper {
    static let shared = FileHelper(name: "\(FileHelper.dispatchQueueNamePrefix)default")
    
    //static let cacheDirectoryPrefix = "adkatech.com.cache."
    static let dispatchQueueNamePrefix = "adkatech.com.FileManagerHelper.dispatchQueueName."
    //var getFilePath: String
    /// Name of cache
    open var name: String = ""
    
    let queue: DispatchQueue
    let fileManager: FileManager
    
    /// Specify distinct name param, it represents folder name for disk cache
    public init(name: String, path: String? = nil) {
        self.name = name
        
        //        getFilePath = path ?? NSSearchPathForDirectoriesInDomains(.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        //        getFilePath = (getFilePath as NSString).appendingPathComponent(FileHelper.cacheDirectoryPrefix + name)
        
        queue = DispatchQueue(label: FileHelper.dispatchQueueNamePrefix + name)
        
        fileManager = FileManager()
    }
    
    func isExist(fileName: String?) -> Bool {
        guard let fileURL = getFileURL(for: fileName) else { return false }
        let isExist = fileManager.fileExists(atPath: fileURL.relativePath)
        return isExist
    }
    
    //    func hasDataOnDiskForKey(forKey key: String) -> Bool {
    //        return fileManager.fileExists(atPath: getFilePath(forKey: key))
    //    }
    //
    //    private func cacheFilePath(forKey key: String) -> String {
    //        let directory = (directoryPathString(for: .localStorage) ?? "") as NSString
    //        let fileName = key
    //        let fileURL = directory.appendingPathComponent(fileName)
    //        return fileURL
    //    }
    
    func getFileURL(for name: String?) -> URL? {
        let directoryURL = directoryPathURL(for: .localStorage)
        let fileName = name ?? "recentDownloadedFile"
        let fileURL = directoryURL?.appendingPathComponent(fileName)
        //let filePath = documentsURL.path Folder
        return fileURL
    }
    
    func getFilePath(forKey key: String) -> String {
        let directory = (directoryPathString(for: .localStorage) ?? "") as NSString
        let fileName = key
        let fileURL = directory.appendingPathComponent(fileName)
        return fileURL
    }
}

// MARK: Store data
extension FileHelper {
    func setData(_ data: Data, forKey key: String) {
        writeDataToDisk(data: data, key: key)
    }
    
    func data(forKey key: String) -> Data? {
        let data = readDataFromDisk(forKey: key)
        return data
    }
}

extension FileHelper {
    
    private func writeDataToDisk(data: Data, key: String) {
        queue.async { [weak self] in
            guard let self = self else { return }
            if self.hasDataOnDiskForKey(forKey: key) == false {
                self.createDirectoryIfNeeded()
            }
            let isSuccess = self.fileManager.createFile(atPath: self.getFilePath(forKey: key), contents: data, attributes: nil)
            Debugger().printOut("Created file: \(key) was \(isSuccess)", "\(Self.self)", context: .debug)
        }
    }
    
    /// Read data from disk for key
    private func readDataFromDisk(forKey key: String) -> Data? {
        guard hasDataOnDiskForKey(forKey: key) else { return nil }
        let data = fileManager.contents(atPath: getFilePath(forKey: key))
        return data
    }
    
    /// Check if has data on disk
    @discardableResult
    func hasDataOnDiskForKey(forKey key: String) -> Bool {
        return fileManager.fileExists(atPath: getFilePath(forKey: key))
    }
    
    @discardableResult
    func createDirectoryIfNeeded() -> Bool {
        var isDir: ObjCBool = true
        let isDirectoryExist = fileManager.fileExists(atPath: "", isDirectory: &isDir)
        if isDirectoryExist {
            return true
        } else {
            //creat
            guard let directory = directoryPathString(for: .localStorage) else {
                return false
            }
            do {
                try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                Debugger().printOut("Error while creating cache folder", context: .error)
                return false
            }
            return true
        }
    }
    
    func clearCache() {
        let cacheURL =  FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileManager = FileManager.default
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory( at: cacheURL, includingPropertiesForKeys: nil, options: [])
            for file in directoryContents {
                do {
                    try fileManager.removeItem(at: file)
                } catch let error as NSError {
                    //debugPrint("Oops! Something went wrong: \(error)")
                    Debugger().printOut(error, "\(Self.self)", context: .error)
                }
            }
        } catch let error as NSError {
            //print(error.localizedDescription)
            Debugger().printOut(error, "\(Self.self)", context: .error)
        }
    }
    
}
