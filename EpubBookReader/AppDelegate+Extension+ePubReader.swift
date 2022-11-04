//
//  AppDelegate+Extension+ePubReader.swift
//  EpubBookReader
//
//  Created by Amr Elghadban on 04/11/2022.
//

import Foundation

extension AppDelegate {
    
    func getBooksDirectory()->String {
        self.createBooksDirectory()
        let path = self.getDocumentsPath()+"/books"
        return path
    }
    
    // create books folder to store epub books under documents folder.
    func createBooksDirectory() {
        let docPath = self.getDocumentsPath()
        let booksDir = docPath + "/books"
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: booksDir) {
            do {
                try fileManager.createDirectory(atPath: booksDir, withIntermediateDirectories: true, attributes: nil)
                print(booksDir+" is created successfully")
            } catch {
                print("Couldn't create bools directory")
            }
        }else {
            print(booksDir+" has been already created!")
        }
    }
    
    // get documents folder
    func getDocumentsPath() ->String {
        var documentsPath : String
        documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return documentsPath
    }
}
