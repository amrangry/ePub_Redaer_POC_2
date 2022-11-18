//
//  SkyConfigurator.swift
//  EpubBookReader
//
//  Created by Amr Elghadban on 11/11/2022.
//

import Foundation

class SkyConfigurator {
    static let shared = SkyConfigurator()
    
    var data: SkyData!
    
    private enum CodeKeys: String {
        case booksFolderName = "ePub_books_dir"
        case downloadsFolderName = "ePub_books_downloads_dir"
        case clientId = "A3UBZzJNCoXmXQlBWD4xNo"
        case clientSecret = "zfZl40AQXu8xHTGKMRwG69"
    }
    
    static var booksDirectoryFolderName: String?
    
    static var downloadsDirectoryFolderName: String?
    
    static var clientId: String?
    
    static var clientSecret: String?
    
    private init() {
        
    }
    
    func configureSkyEpubData(booksDirectoryFolderName: String = CodeKeys.booksFolderName.rawValue,
                              downloadsDirectoryFolderName: String = CodeKeys.downloadsFolderName.rawValue,
                              clientId: String = CodeKeys.clientId.rawValue,
                              clientSecret: String = CodeKeys.clientSecret.rawValue) {
        
        SkyConfigurator.booksDirectoryFolderName = booksDirectoryFolderName
        SkyConfigurator.downloadsDirectoryFolderName = downloadsDirectoryFolderName
        SkyConfigurator.clientId = clientId
        SkyConfigurator.clientSecret = clientSecret
        
        self.data = SkyData(booksDirectoryFolderName: booksDirectoryFolderName,
                            downloadsDirectoryFolderName: downloadsDirectoryFolderName,
                            clientId: clientId,
                            clientSecret: clientSecret)
    }
    
}
