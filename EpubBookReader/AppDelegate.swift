//
//  AppDelegate.swift
//  EpubBookReader
//
//  Created by Amr Elghadban on 17/09/2022.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var view: UIView = UIView()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.installSamples()
        return true
    }
    
    
    // get documents folder
    func getDocumentsPath() ->String {
        var documentsPath : String
        documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                            .userDomainMask, true)[0]
        return documentsPath
    }
    // create books folder to store epub books under documents folder.
    func createBooksDirectory() {
        let docPath = self.getDocumentsPath()
        let booksDir = docPath + "/books"
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: booksDir) {
            do {
                try fileManager.createDirectory(atPath: booksDir, withIntermediateDirectories: true,
                                                attributes: nil)
                print(booksDir+" is created successfully")
            } catch {
                print("Couldn't create bools directory")
            }
        }else {
            print(booksDir+" has been already created!")
        }
    }
    func getBooksDirectory()->String {
        self.createBooksDirectory()
        let path = self.getDocumentsPath()+"/books"
        return path
    }
    func getBookPath(fileName:String) ->String {
        let booksDir = self.getBooksDirectory()
        let path = booksDir+"/"+fileName
        return path
    }
    func copyFileFromBundleToBooks(fileName:String) {
        let fileManager = FileManager.default
        
        let bookPath = self.getBookPath(fileName:fileName)
        let bundle = Bundle.main
        let path = bundle.resourcePath! + "/" + fileName
        do {
            try fileManager.copyItem(atPath: path, toPath: bookPath)
        } catch {
            print(error)
        }
    }
    
    func installSamples() {
        let fileName = "Arabic_Book.epub"
        let samplePath = self.getBookPath(fileName: fileName)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: samplePath) {
            createBooksDirectory()
            copyFileFromBundleToBooks(fileName: fileName)
        }else {
            print(fileName+" has been already installed!")
        }
    }
    
}

