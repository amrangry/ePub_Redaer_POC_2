// SkyEpub for iOS Advanced Demo IV  - Swift language
//
//  SkyDatabase.swift
//  SkyAD
//
//  Created by 하늘나무 on 2020/09/12.
//  Copyright © 2020 Dev. All rights reserved.
//

import UIKit

extension String {
    func encodeUrl() -> String? {
        return self.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
    }
    func decodeUrl() -> String? {
        return self.removingPercentEncoding
    }
}

// Data Management Module for Database or File. 
class SkyData:NSObject ,SkyProviderDataSource {
    var database: FMDatabase!
    var keyManager:SkyKeyManager!
    
    override init() {
        super.init()
        let docPath = self.getDocumentsPath()
        print(docPath)
        let dbPath = self.getDatabasePath()
        print(dbPath)
        keyManager = SkyKeyManager.init(clientId: "A3UBZzJNCoXmXQlBWD4xNo", clientSecret: "zfZl40AQXu8xHTGKMRwG69")
        self.checkDatabase()
    }
    
    // get documents folder
    func getDocumentsPath() ->String {
        var documentsPath : String
        documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return documentsPath
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
    
    // create downloads folder to save downloaded files.
    func createDownloadsDirectory() {
        let docPath = self.getDocumentsPath()
        let downloadsDir = docPath + "/downloads"
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: downloadsDir) {
            do {
                try fileManager.createDirectory(atPath: downloadsDir, withIntermediateDirectories: true, attributes: nil)
                print(downloadsDir+" is created successfully")
            } catch {
                print("Couldn't create downloads directory")
            }
        }else {
            print(downloadsDir+" has been already created!")
        }
    }
    
    func createCachesDirectory() {
        let docPath = self.getDocumentsPath()
        let cachessDir = docPath + "/caches"
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: cachessDir) {
            do {
                try fileManager.createDirectory(atPath: cachessDir, withIntermediateDirectories: true, attributes: nil)
                print(cachessDir+" is created successfully")
            } catch {
                print("Couldn't create caches directory")
            }
        }else {
            print(cachessDir+" has been already created!")
        }
    }
    
    func getBooksDirectory()->String {
        self.createBooksDirectory()
        let path = self.getDocumentsPath()+"/books"
        return path
    }
    
    func getDownloadsDirectory()->String {
        self.createDownloadsDirectory()
        let path = self.getDocumentsPath()+"/downloads"
        return path
    }
    
    func getEPubDirectory(fileName:String)->String {
        let pureName = fileName.prefix(fileName.count-5)
        let booksDir = self.getBooksDirectory()
        let ePubDir = booksDir+"/"+pureName;
        return ePubDir
    }
    
    func getDownloadPath(fileName:String) ->String {
        let downloadsDir = self.getDownloadsDirectory()
        let path = downloadsDir+"/"+fileName
        return path
    }
    
    func getBookPath(fileName:String) ->String {
        let booksDir = self.getBooksDirectory()
        let path = booksDir+"/"+fileName
        return path
    }
    
    func getCoverPath(fileName:String)->String {
        let booksDir = self.getBooksDirectory()
        let coverName = fileName.replacingOccurrences(of: "epub", with: "jpg")
        let coverPath = booksDir+"/"+coverName
        return coverPath;
    }
    
    func createEPubDirectory(fileName:String) {
        let ePubDir = self.getEPubDirectory(fileName: fileName)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: ePubDir) {
            do {
                try fileManager.createDirectory(atPath: ePubDir, withIntermediateDirectories: true, attributes: nil)
                print(ePubDir+" is created successfully")
            } catch {
                print("Couldn't create downloads directory")
            }
        } else {
            print(ePubDir+" has been already created!")
        }
    }
    
    func copyFileFromBundleToDownloads(fileName:String) {
        let fileManager = FileManager.default
        let downloadPath = self.getDownloadPath(fileName:fileName)
        
        let bundle = Bundle.main
        let path = bundle.resourcePath! + "/" + fileName
        do {
            try fileManager.copyItem(atPath: path, toPath: downloadPath)
        } catch {
            print(error)
        }
    }
    
    func copyFileFromDownloadsToBooks(fileName:String) {
        let fileManager = FileManager.default
        let sourcePath = self.getDownloadPath(fileName: fileName)
        let targetPath = self.getBooksDirectory()+"/"+fileName;
        do {
            try fileManager.copyItem(atPath: sourcePath, toPath: targetPath)
        } catch {
            print(error)
        }
    }
    
    func copyFileFromURLToBooks(url:URL) {
        let fileManager = FileManager.default
        let sourcePath:String = self.getFilePathFromURL(url: url)
        let fileName = (sourcePath as NSString).lastPathComponent
        let targetPath = self.getBooksDirectory()+"/"+fileName;
        do {
            try fileManager.copyItem(atPath: sourcePath, toPath: targetPath)
        } catch {
            print(error)
        }
    }
    
    func getFilePathFromURL(url:URL)->String {
        let fileManager = FileManager.default
        var sourcePath:String = url.absoluteString
        sourcePath = sourcePath.replacingOccurrences(of: "file://", with: "")
        sourcePath = sourcePath.decodeUrl()!
        return sourcePath
    }
    
    func getFileNameFromURL(url:URL)->String {
        let filePath = self.getFilePathFromURL(url: url)
        let fileName = (filePath as NSString).lastPathComponent
        return fileName
    }
    
    func installEpub(fileName:String) {
        let bookPath = self.getBookPath(fileName: fileName)
        let fileManager = FileManager.default
        let isExists = fileManager.fileExists(atPath: bookPath)
        if (isExists) {
            print("Book already installed.")
            return
        }
        self.copyFileFromBundleToDownloads(fileName: fileName)
        self.copyFileFromDownloadsToBooks(fileName: fileName)
        let bi:BookInformation = BookInformation.init(bookName: fileName, baseDirectory:self.getBooksDirectory())
        bi.fileName = fileName
        let skyProvider:SkyProvider = SkyProvider()
        skyProvider.dataSource = self
        skyProvider.book = bi.book
        bi.contentProvider = skyProvider
        bi.make()
        
        print("Book Code: \(bi.bookCode)")
        self.insertBookInformation(bi)
        return
    }
    
    func installEpub(url:URL) {
        let fileManager = FileManager.default
        let fileName = self.getFileNameFromURL(url: url)
        let bookPath = self.getBookPath(fileName: fileName)
        let isExists = fileManager.fileExists(atPath: bookPath)
        if (isExists) {
            return
        }
        self.copyFileFromURLToBooks(url: url)
        let bi:BookInformation = BookInformation.init(bookName: fileName, baseDirectory:self.getBooksDirectory())
        bi.fileName = fileName
        let skyProvider:SkyProvider = SkyProvider()
        skyProvider.dataSource = self
        skyProvider.book = bi.book
        bi.contentProvider = skyProvider
        bi.make()
        self.insertBookInformation(bi)
        return
    }
    
    
    func skyProvider(_ sp: SkyProvider!, keyForEncryptedData uuidForContent: String!, contentName: String!, uuidForEpub: String!) -> String! {
        let key = keyManager.getKey(uuidForEpub, uuidForContent: uuidForContent)
        return key;
    }
    
    
    func getDatabasePath() -> String {
        let path = self.getDocumentsPath()+"/book.sqlite"
        return path
    }
    
    func getDDLFromBundle()-> String {
        var contents:String!
        if let filepath = Bundle.main.path(forResource: "Books", ofType: "sql") {
            do {
                contents = try String(contentsOfFile: filepath)
                print(contents!)
            } catch {
                contents = ""
                print("Failed to get contents of Books.sql in Bundle.")
            }
        } else {
            contents =  "";
            print("Books.sql is not found.")
        }
        return contents
    }
    
    // Database Functions
    func openDatabase() -> Bool {
        self.closeDatabase()
        var result = false
        if !FileManager.default.fileExists(atPath: getDatabasePath()) {
            database = FMDatabase(path: self.getDatabasePath())
            if database != nil {
                if database.open() {
                    let ddl = self.getDDLFromBundle()
                    database.executeStatements(ddl)
                    let sql = "INSERT INTO Setting(BookCode,FontName,FontSize,LineSpacing,Foreground,Background,Theme,Brightness,TransitionType,LockRotation,DoublePaged,Allow3G,GlobalPagination,MediaOverlay,TTS,AutoStartPlaying,AutoLoadNewChapter,HighlightTextToVoice) VALUES(0,'Book Fonts',2,0,-1,-1,0,1,2,0,1,0,0,1,1,0,1,1)"
                    database.executeUpdate(sql, withArgumentsIn: [])
                    result = true
                    // At the end close the database.
                    database.close()
                    print("Database Successfully Created.")
                }else {
                    print("Could not open the database.")
                }
            }
        }else {
            let dbPath = self.getDatabasePath()
            database = FMDatabase(path: dbPath)
            database.open()
            print("Database Successfully Opened.")
            result = true
        }
        return result
    }
    
    func closeDatabase() {
        if database != nil {
            database.close()
        }
    }
    
    func checkDatabase() {
        if (database == nil || !database.isOpen) {
            if !openDatabase() {
                print("unabled to open database !!!!!")
            }
        }
    }
    
    
    func updateSetting(setting:SkyEpubSetting!) {
        checkDatabase()
        if setting.fontName == nil {
            setting.fontName = ""
        }
        let sql = "UPDATE Setting SET FontName=?, FontSize=? , LineSpacing=? , Foreground=? , Background=? , Theme=? , Brightness=?, TransitionType=? , LockRotation=? , DoublePaged=?,Allow3G=?,GlobalPagination=?,MediaOverlay=?,TTS=?,AutoStartPlaying=?,AutoLoadNewChapter=?,HighlightTextToVoice=? where BookCode=0"
        do {
            try database.executeUpdate(sql, values:[setting.fontName,setting.fontSize,setting.lineSpacing,setting.foreground,setting.background,setting.theme,setting.brightness,setting.transitionType,setting.lockRotation ? 1:0 ,setting.doublePaged ? 1:0,setting.allow3G ? 1:0,setting.globalPagination ? 1:0,setting.mediaOverlay ? 1:0 ,setting.tts ? 1:0,setting.autoStartPlaying ? 1:0,setting.autoLoadNewChapter ? 1:0,setting.highlightTextToVoice ? 1:0])
        }catch {
            print(error.localizedDescription)
        }
    }
    
    
    func fetchSetting() ->SkyEpubSetting! {
        checkDatabase()
        let sql = "SELECT * FROM Setting where BookCode=0"
        do {
            let results = try database.executeQuery(sql, values: [])
            while results.next() {
                let setting = SkyEpubSetting()
                setting.bookCode =                      0
                setting.fontName                        =   results.string(forColumn: "FontName")
                setting.fontSize                        =   Int(results.int(forColumn:"FontSize"))
                setting.lineSpacing                     =   Int(results.int(forColumn:"LineSpacing"))
                setting.foreground                      =   Int(results.int(forColumn:"Foreground"))
                setting.background                      =   Int(results.int(forColumn:"Background"))
                setting.theme                           =   Int(results.int(forColumn:"Theme"))
                setting.brightness                      =   Double(results.double(forColumn:"Brightness"))
                setting.transitionType                  =   Int(results.int(forColumn:"TransitionType"))
                setting.lockRotation                    =   results.int(forColumn:"LockRotation") != 0 ? true:false
                setting.doublePaged                     =   results.int(forColumn:"DoublePaged") != 0 ? true:false
                setting.allow3G                         =   results.int(forColumn:"Allow3G") != 0 ? true:false
                setting.globalPagination                =   results.int(forColumn:"GlobalPagination") != 0 ? true:false
                setting.mediaOverlay                    =   results.int(forColumn:"MediaOverlay") != 0 ? true:false
                setting.tts                             =   results.int(forColumn:"TTS") != 0 ? true:false
                setting.autoStartPlaying                =   results.int(forColumn:"AutoStartPlaying") != 0 ? true:false
                setting.autoLoadNewChapter              =   results.int(forColumn:"AutoLoadNewChapter") != 0 ? true:false
                setting.highlightTextToVoice            =   results.int(forColumn:"HighlightTextToVoice") != 0 ? true:false
                return setting
            }
        }catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    
    // BookInformation
    func insertBookInformation(_ bi:BookInformation)  {
        checkDatabase()
        let ns = self.getNowString()
        let sql = "INSERT INTO Book (Title,Author,Publisher,Subject,Type,Date,Language,Filename,IsFixedLayout,IsRTL,Position,Spread) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)"
        do {
            try database.executeUpdate(sql, values: [(bi.title ?? ""), (bi.creator ?? ""), (bi.publisher ?? ""), (bi.subject ?? ""), (bi.type ?? ""),ns, (bi.language  ?? ""), bi.fileName, bi.isFixedLayout ? 1:0 ,bi.isRTL ? 1:0 ,-1.0,bi.spread])
        }catch {
            print(error.localizedDescription)
        }
    }
    
    func updateBookPosition(bookInformation:BookInformation) {
        let bi:BookInformation = bookInformation
        let ns = self.getNowString()
        let sql = "UPDATE Book SET Position=?,LastRead=?,IsRead=? where BookCode=?"
        do {
            try database.executeUpdate(sql, values: [bi.position,ns,1,bi.bookCode])
        }catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteBookByBookCode(bookCode:Int) {
        checkDatabase()
        let bi:BookInformation = self.fetchBookInformation(bookCode: bookCode)
        let bookPath = self.getBookPath(fileName: bi.fileName)
        let coverPath = self.getCoverPath(fileName: bi.fileName)
        let documentPath = self.getDocumentsPath()
        let cacheFolder = "\(documentPath)/caches/"
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: bookPath) {
            do {
                try fileManager.removeItem(atPath: bookPath)
            }catch{
                print(error)
            }
        }
        if fileManager.fileExists(atPath: coverPath) {
            do {
                try fileManager.removeItem(atPath: coverPath)
            }catch{
                print(error)
            }
        }
        if bi.isFixedLayout {
            let filesEnumerator = FileManager.default.enumerator(atPath: cacheFolder)
            while let fileName = filesEnumerator?.nextObject() as? String {
                let prefix = "sb\(bookCode)"
                if fileName.hasPrefix(prefix) { // checks the extension
                    do {
                        let path = "\(cacheFolder)\(fileName)"
                        try fileManager.removeItem(atPath: path)
                    }catch {
                        print(error)
                    }
                }
            }
        }
        var sql = "DELETE FROM Book where BookCode=\(bookCode)"
        database.executeUpdate(sql, withArgumentsIn: [])
        sql = "DELETE FROM Highlight where BookCode=\(bookCode)"
        database.executeUpdate(sql, withArgumentsIn: [])
        sql = "DELETE FROM Bookmark where BookCode=\(bookCode)"
        database.executeUpdate(sql, withArgumentsIn: [])
        sql = "DELETE FROM ItemRef where BookCode=\(bookCode)"
        database.executeUpdate(sql, withArgumentsIn: [])
    }
    
    func fetchBookInformations(sortType:Int,key:String)->NSMutableArray {
        var orderBy:String = ""
        if (sortType==0) {
            orderBy = " ORDER BY Title"
        }else if (sortType==1) {
            orderBy = " ORDER BY Author"
        }else if (sortType==2) {
            orderBy = " ORDER BY LastRead DESC"
        }
        var condition:String = ""
        if !(key ?? "").isEmpty {
            condition = " WHERE Title like '%%\(key)%%' OR Author like '%%\(key)%%'"
            //            condition = " WHERE Title like '%\(key)%' OR Author like '%\(key)%'"
        }
        let sql = "Select * from Book " + condition + orderBy
        return self.fetchBookInformations(sql:sql)
    }
    
    func getNumberOfBooks() -> Int {
        checkDatabase()
        let sql = "SELECT COUNT(*) as Count FROM Book"
        do {
            let results = try database.executeQuery(sql, values: [])
            while results.next() {
                let count = Int(results.int(forColumn: "Count"))
                return count
            }
        }catch {
            print(error.localizedDescription)
        }
        return -1
    }
    
    func fetchBookInformations(sql:String)->NSMutableArray {
        checkDatabase()
        let rets = NSMutableArray()
        do {
            let results = try database.executeQuery(sql, values: [])
            while results.next() {
                let bi:BookInformation = BookInformation()
                bi.title            =   results.string(forColumn: "Title")
                bi.creator          =   results.string(forColumn: "Author")
                bi.publisher        =   results.string(forColumn: "Publisher")
                bi.subject          =   results.string(forColumn: "Subject")
                bi.date             =   results.string(forColumn: "Date")
                bi.language         =   results.string(forColumn: "Language")
                bi.fileName         =   results.string(forColumn: "FileName")
                bi.url              =   results.string(forColumn: "URL")
                bi.coverUrl         =   results.string(forColumn: "CoverURL")
                bi.lastRead         =   results.string(forColumn: "LastRead")
                
                bi.bookCode         =   Int32(results.int(forColumn:"BookCode"))
                bi.type             =   results.string(forColumn: "Type")
                bi.fileSize         =   Int32(results.int(forColumn:"FileSize"))
                bi.customOrder      =   Int32(results.int(forColumn:"CustomOrder"))
                bi.downSize         =   Int32(results.int(forColumn:"DownSize"))
                bi.spread           =   Int32(results.int(forColumn:"Spread"))
                
                bi.position         =   Double(results.double(forColumn:"Position"))
                
                bi.isRead           =   results.int(forColumn:"IsRead") != 0 ? true:false
                bi.isRTL            =   results.int(forColumn:"IsRTL") != 0 ? true:false
                bi.isVerticalWriting =  results.int(forColumn:"IsVerticalWriting") != 0 ? true:false
                bi.isFixedLayout    =   results.int(forColumn:"IsFixedLayout") != 0 ? true:false
                bi.isGlobalPagination = results.int(forColumn:"IsGlobalPagination") != 0 ? true:false
                bi.isDownloaded     =   results.int(forColumn:"IsDownloaded") != 0 ? true:false
                rets.add(bi)
            }
        }catch {
            print(error.localizedDescription)
        }
        return rets
    }
    
    func fetchBookInformation(bookCode:Int)->BookInformation! {
        checkDatabase()
        let sql = "SELECT * FROM Book where BookCode=\(bookCode)"
        do {
            let results = try database.executeQuery(sql, values: [])
            while results.next() {
                let bi:BookInformation = BookInformation()
                bi.title            =   results.string(forColumn: "Title")
                bi.creator          =   results.string(forColumn: "Author")
                bi.publisher        =   results.string(forColumn: "Publisher")
                bi.subject          =   results.string(forColumn: "Subject")
                bi.date             =   results.string(forColumn: "Date")
                bi.language         =   results.string(forColumn: "Language")
                bi.fileName         =   results.string(forColumn: "FileName")
                bi.url              =   results.string(forColumn: "URL")
                bi.coverUrl         =   results.string(forColumn: "CoverURL")
                bi.lastRead         =   results.string(forColumn: "LastRead")
                
                bi.bookCode         =   Int32(results.int(forColumn:"BookCode"))
                bi.type             =   results.string(forColumn: "Type")
                bi.fileSize         =   Int32(results.int(forColumn:"FileSize"))
                bi.customOrder      =   Int32(results.int(forColumn:"CustomOrder"))
                bi.downSize         =   Int32(results.int(forColumn:"DownSize"))
                bi.spread           =   Int32(results.int(forColumn:"Spread"))
                
                bi.position         =   Double(results.double(forColumn:"Position"))
                
                bi.isRead           =   results.int(forColumn:"IsRead") != 0 ? true:false
                bi.isRTL            =   results.int(forColumn:"IsRTL") != 0 ? true:false
                bi.isVerticalWriting =  results.int(forColumn:"IsVerticalWriting") != 0 ? true:false
                bi.isFixedLayout    =   results.int(forColumn:"IsFixedLayout") != 0 ? true:false
                bi.isGlobalPagination = results.int(forColumn:"IsGlobalPagination") != 0 ? true:false
                bi.isDownloaded     =   results.int(forColumn:"IsDownloaded") != 0 ? true:false
                return bi
            }
        }catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func fetchBookInformation(fileName: String) -> BookInformation? {
        checkDatabase()
        //'%%\(key)%%'
        let sql = "SELECT * FROM Book where FileName LIKE '%\(fileName)%'"
        do {
            let results = try database.executeQuery(sql, values: [])
            while results.next() {
                let bi:BookInformation = BookInformation()
                bi.title            =   results.string(forColumn: "Title")
                bi.creator          =   results.string(forColumn: "Author")
                bi.publisher        =   results.string(forColumn: "Publisher")
                bi.subject          =   results.string(forColumn: "Subject")
                bi.date             =   results.string(forColumn: "Date")
                bi.language         =   results.string(forColumn: "Language")
                bi.fileName         =   results.string(forColumn: "FileName")
                bi.url              =   results.string(forColumn: "URL")
                bi.coverUrl         =   results.string(forColumn: "CoverURL")
                bi.lastRead         =   results.string(forColumn: "LastRead")
                
                bi.bookCode         =   Int32(results.int(forColumn:"BookCode"))
                bi.type             =   results.string(forColumn: "Type")
                bi.fileSize         =   Int32(results.int(forColumn:"FileSize"))
                bi.customOrder      =   Int32(results.int(forColumn:"CustomOrder"))
                bi.downSize         =   Int32(results.int(forColumn:"DownSize"))
                bi.spread           =   Int32(results.int(forColumn:"Spread"))
                
                bi.position         =   Double(results.double(forColumn:"Position"))
                
                bi.isRead           =   results.int(forColumn:"IsRead") != 0 ? true:false
                bi.isRTL            =   results.int(forColumn:"IsRTL") != 0 ? true:false
                bi.isVerticalWriting =  results.int(forColumn:"IsVerticalWriting") != 0 ? true:false
                bi.isFixedLayout    =   results.int(forColumn:"IsFixedLayout") != 0 ? true:false
                bi.isGlobalPagination = results.int(forColumn:"IsGlobalPagination") != 0 ? true:false
                bi.isDownloaded     =   results.int(forColumn:"IsDownloaded") != 0 ? true:false
                return bi
            }
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    // Highlight Routines ================================================================================================================================================
    func fetchHighlights(bookCode:Int,chapterIndex:Int) -> NSMutableArray {
        checkDatabase()
        let rets = NSMutableArray()
        let sql = "SELECT * FROM Highlight where BookCode=\(bookCode) and ChapterIndex=\(chapterIndex)"
        do {
            let results = try database.executeQuery(sql, values: [])
            while results.next() {
                let highlight = Highlight()
                highlight.bookCode          = Int32(bookCode)
                highlight.code              = Int32(results.int(forColumn:"Code"))
                highlight.chapterIndex      = Int32(chapterIndex)
                highlight.startIndex        = Int32(results.int(forColumn:"StartIndex"))
                highlight.startOffset       = Int32(results.int(forColumn:"StartOffset"))
                highlight.endIndex          = Int32(results.int(forColumn:"EndIndex"))
                highlight.endOffset         = Int32(results.int(forColumn:"EndOffset"))
                highlight.highlightColor    = UInt32(results.int(forColumn:"Color"))
                highlight.text              = results.string(forColumn: "Text")
                highlight.note              = results.string(forColumn: "Note")
                highlight.isNote            = results.int(forColumn:"IsNote") != 0 ? true:false
                highlight.datetime          = results.string(forColumn: "CreatedDate")
                rets.add(highlight)
            }
        }catch {
            print(error.localizedDescription)
        }
        return rets
    }
    
    func fetchHighlights(bookCode:Int) -> NSMutableArray {
        checkDatabase()
        let rets = NSMutableArray()
        let sql = "SELECT * FROM Highlight where BookCode=\(bookCode) order by ChapterIndex"
        do {
            let results = try database.executeQuery(sql, values: [])
            while results.next() {
                let highlight = Highlight()
                highlight.bookCode          = Int32(bookCode)
                highlight.code              = Int32(results.int(forColumn:"Code"))
                highlight.chapterIndex      = Int32(results.int(forColumn:"ChapterIndex"))
                highlight.startIndex        = Int32(results.int(forColumn:"StartIndex"))
                highlight.startOffset       = Int32(results.int(forColumn:"StartOffset"))
                highlight.endIndex          = Int32(results.int(forColumn:"EndIndex"))
                highlight.endOffset         = Int32(results.int(forColumn:"EndOffset"))
                highlight.highlightColor    = UInt32(results.int(forColumn:"Color"))
                highlight.text              = results.string(forColumn: "Text")
                highlight.note              = results.string(forColumn: "Note")
                highlight.isNote            = results.int(forColumn:"IsNote") != 0 ? true:false
                highlight.datetime          = results.string(forColumn: "CreatedDate")
                rets.add(highlight)
            }
        }catch {
            print(error.localizedDescription)
        }
        return rets
    }
    
    
    func isSameHighlight(firstHighlight:Highlight?,secondHighlight:Highlight?) ->Bool {
        if let first = firstHighlight, let second = secondHighlight {
            if (first.bookCode==second.bookCode && first.startIndex == second.startIndex && first.endIndex == second.endIndex && first.startOffset==second.startOffset && first.endOffset==second.endOffset && first.chapterIndex==second.chapterIndex) {
                return true;
            }else {
                return false;
            }
        }
        return false;
    }
    
    func insertHighlight(highlight:Highlight) {
        checkDatabase()
        let ns = self.getNowString()
        if highlight.text == nil {
            highlight.text = ""
        }
        if highlight.note == nil {
            highlight.note = ""
        }
        let sql = "INSERT INTO Highlight (BookCode,ChapterIndex,StartIndex,StartOffset,EndIndex,EndOffset,Color,Text,Note,IsNote,CreatedDate) VALUES(?,?,?,?,?,?,?,?,?,?,?)"
        do {
            try database.executeUpdate(sql, values: [highlight.bookCode,highlight.chapterIndex,highlight.startIndex,highlight.startOffset,highlight.endIndex,highlight.endOffset,highlight.highlightColor,highlight.text!,highlight.note!, highlight.isNote ? 1:0 ,ns])
        }catch {
            print(error.localizedDescription)
        }
    }
    
    
    func deleteHighlight(highlight:Highlight) {
        checkDatabase()
        let sql = "DELETE FROM Highlight where BookCode=\(highlight.bookCode) and ChapterIndex=\(highlight.chapterIndex) and StartIndex=\(highlight.startIndex) and StartOffset=\(highlight.startOffset) and EndIndex=\(highlight.endIndex) and EndOffset=\(highlight.endOffset)"
        database.executeUpdate(sql, withArgumentsIn: [])
    }
    
    func updateHighlight(highlight:Highlight) {
        checkDatabase()
        let ns = self.getNowString()
        if highlight.text == nil {
            highlight.text = ""
        }
        if highlight.note == nil {
            highlight.note = ""
        }
        let sql = "UPDATE Highlight SET StartIndex=?,StartOffset=?,EndIndex=?,EndOffset=?,Color=?,Text=?,Note=?,IsNote=?,CreatedDate=? where BookCode=? and ChapterIndex=? and StartIndex=? and StartOffset=? and EndIndex=? and EndOffset=?"
        do {
            try database.executeUpdate(sql, values: [highlight.startIndex,highlight.startOffset,highlight.endIndex,highlight.endOffset,highlight.highlightColor,highlight.text,highlight.note, highlight.isNote ? 1:0 ,ns, highlight.bookCode,highlight.chapterIndex,highlight.startIndex,highlight.startOffset,highlight.endIndex,highlight.endOffset])
        }catch {
            print(error.localizedDescription)
        }
    }
    
    // Bookmark Routines ================================================================================================================================================
    
    
    func isBookmarked(pageInformation:PageInformation)->Bool {
        let code = self.getBookmarkCode(pageInformation: pageInformation)
        if code == -1 {
            return false
        }else {
            return true
        }
    }
    
    func toggleBookmark(pageInformation:PageInformation) {
        let code = self.getBookmarkCode(pageInformation: pageInformation)
        if code == -1 {
            self.insertBookmark(pageInformation: pageInformation)
        }else {
            self.deleteBookmark(code: code)
        }
    }
    
    func getNowString() ->String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: Date())
        return dateString
    }
    
    func isFixedLayout(bookCode:Int)->Bool {
        let bi:BookInformation = self.fetchBookInformation(bookCode:bookCode)
        if bi.isFixedLayout {
            return true
        }else {
            return false
        }
    }
    
    func insertBookmark(pageInformation:PageInformation) {
        checkDatabase()
        let ppb = pageInformation.pagePositionInBook
        let ppc = pageInformation.pagePositionInChapter
        let ci = pageInformation.chapterIndex
        let bc = pageInformation.bookCode
        let ns = self.getNowString()
        
        let sql = "INSERT INTO Bookmark (BookCode,ChapterIndex,PagePositionInChapter,PagePositionInBook,CreatedDate) VALUES(\(bc),\(ci),\(ppc),\(ppb),'\(ns)')"
        database.executeUpdate(sql, withArgumentsIn: [])
    }
    
    func deleteBookmark(code:Int) {
        checkDatabase()
        let sql = "DELETE FROM Bookmark where Code = \(code)"
        database.executeUpdate(sql, withArgumentsIn: [])
    }
    
    func deleteBookmark(pageInformation:PageInformation) {
        checkDatabase()
        let code = pageInformation.code
        self.deleteBookmark(code: code)
    }
    
    func getBookmarkCode(pageInformation:PageInformation) ->Int {
        checkDatabase()
        let isFixedLayout = self.isFixedLayout(bookCode: pageInformation.bookCode)
        if isFixedLayout {
            let sql = "SELECT Code from Bookmark where BookCode=\(pageInformation.bookCode) and ChapterIndex=\(pageInformation.chapterIndex)"
            do {
                let results = try database.executeQuery(sql, values: [])
                while results.next() {
                    let code = Int(results.int(forColumn:"Code"))
                    return code
                }
            }catch {
                print(error.localizedDescription)
            }
        }else {
            let pageDelta = 1.0/Double(pageInformation.numberOfPagesInChapter)
            let target = pageInformation.pagePositionInChapter
            
            let sql = "SELECT Code,PagePositionInChapter from Bookmark where BookCode=\(pageInformation.bookCode) and ChapterIndex=\(pageInformation.chapterIndex)"
            do {
                let results = try database.executeQuery(sql, values: [])
                while results.next() {
                    let code = Int(results.int(forColumn:"Code"))
                    let ppc = results.double(forColumn: "PagePositionInChapter")
                    if target>=(ppc-pageDelta/2) && target<=(ppc+pageDelta/2) {
                        return code
                    }
                }
            }catch {
                print(error.localizedDescription)
            }
        }
        return -1
    }
    
    func fetchBookmarks(bookCode:Int) -> NSMutableArray {
        let rets = NSMutableArray()
        do {
            let sql = "SELECT * FROM Bookmark where BookCode=\(bookCode) ORDER BY ChapterIndex,PagePositionInBook"
            let results = try database.executeQuery(sql, values: [])
            while results.next() {
                let pg:PageInformation = PageInformation()
                pg.bookCode = bookCode
                pg.code = Int(results.int(forColumn:"Code"))
                pg.chapterIndex = Int(results.int(forColumn:"ChapterIndex"))
                pg.pagePositionInChapter = Double(results.double(forColumn:"PagePositionInChapter"))
                pg.pagePositionInBook = Double(results.double(forColumn:"PagePositionInBook"))
                pg.pageDescription = results.string(forColumn: "Description")
                pg.datetime = results.string(forColumn: "CreatedDate")
                rets.add(pg)
            }
        }catch {
            print(error.localizedDescription)
        }
        return rets
    }
    
    // PagingInformation ===========================================================================================================
    func deletePagingInformation(pagingInformation pgi:PagingInformation!) {
        checkDatabase()
        let sql = String(format:"DELETE FROM Paging WHERE BookCode=%d AND ChapterIndex=%d AND FontName='%@' AND FontSize=%d AND LineSpacing=%d AND Width=%d AND Height=%d AND HorizontalGapRatio=%f AND VerticalGapRatio=%f AND IsPortrait=%d AND IsDoublePagedForLandscape=%d",pgi.bookCode,    pgi.chapterIndex,        pgi.fontName,        pgi.fontSize,        pgi.lineSpacing,    pgi.width,        pgi.height,        pgi.horizontalGapRatio,        pgi.verticalGapRatio,        pgi.isPortrait ? 1:0,    pgi.isDoublePagedForLandscape ? 1:0 )
        database.executeUpdate(sql, withArgumentsIn: [])
    }
    
    func insertPagingInformation(pagingInformation pgi:PagingInformation!) {
        checkDatabase()
        if let tgi = self.fetchPagingInformation(pagingInformation: pgi) {
            self.deletePagingInformation(pagingInformation: tgi)
        }
        if (pgi.fontName ?? "") == "Book Fonts" {
            pgi.fontName = ""
        }
        let sql = "INSERT INTO Paging (BookCode,ChapterIndex,NumberOfPagesInChapter,FontName,FontSize,LineSpacing,Width,height,VerticalGapRatio,HorizontalGapRatio,IsPortrait,IsDoublePagedForLandscape) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)"
        do {
            try database.executeUpdate(sql, values: [pgi.bookCode,pgi.chapterIndex,pgi.numberOfPagesInChapter,pgi.fontName,pgi.fontSize,pgi.lineSpacing,pgi.width,pgi.height,pgi.verticalGapRatio,pgi.horizontalGapRatio, pgi.isPortrait ? 1:0,pgi.isDoublePagedForLandscape ? 1:0 ])
        }catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchPagingInformation(pagingInformation:PagingInformation!)->PagingInformation! {
        checkDatabase()
        if let pgi = pagingInformation {
            if (pgi.fontName ?? "") == "Book Fonts" {
                pgi.fontName = ""
            }
            let sql = String(format:"SELECT * FROM Paging WHERE BookCode=%d AND ChapterIndex=%d AND FontName='%@' AND FontSize=%d AND LineSpacing=%d AND Width=%d AND Height=%d AND HorizontalGapRatio=%f AND VerticalGapRatio=%f AND IsPortrait=%d AND IsDoublePagedForLandscape=%d",
                             pgi.bookCode,    pgi.chapterIndex,        pgi.fontName,        pgi.fontSize,        pgi.lineSpacing,    pgi.width,        pgi.height,        pgi.horizontalGapRatio,        pgi.verticalGapRatio,        pgi.isPortrait ? 1:0,    pgi.isDoublePagedForLandscape ? 1:0);
            
            do {
                let results = try database.executeQuery(sql, values: [])
                while results.next() {
                    let pg = PagingInformation()
                    pg.bookCode = Int(results.int(forColumn:"BookCode"))
                    pg.code = Int32(results.int(forColumn:"Code"))
                    pg.chapterIndex = Int(results.int(forColumn:"ChapterIndex"))
                    pg.numberOfPagesInChapter = Int(results.int(forColumn:"NumberOfPagesInChapter"))
                    pg.fontName = results.string(forColumn: "FontName")
                    pg.fontSize = Int(results.int(forColumn:"FontSize"))
                    pg.lineSpacing = Int(results.int(forColumn:"LineSpacing"))
                    pg.width = Int32(results.int(forColumn:"Width"))
                    pg.height = Int32(results.int(forColumn:"Height"))
                    pg.verticalGapRatio = Double(results.double(forColumn:"VerticalGapRatio"))
                    pg.horizontalGapRatio = Double(results.double(forColumn:"HorizontalGapRatio"))
                    pg.isPortrait = results.int(forColumn:"IsPortrait") != 0 ? true:false
                    pg.isDoublePagedForLandscape =  results.int(forColumn:"IsDoublePagedForLandscape") != 0 ? true:false
                    return pg
                }
            }catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    // NSInteger ->   Int
    // int       ->   Int32
    func fetchPagingInformations(sql:String!) ->NSMutableArray! {
        let rets = NSMutableArray()
        do {
            let results = try database.executeQuery(sql, values: [])
            while results.next() {
                let pg = PagingInformation()
                
                pg.bookCode = Int(results.int(forColumn:"BookCode"))
                pg.code = Int32(results.int(forColumn:"Code"))
                pg.chapterIndex = Int(results.int(forColumn:"ChapterIndex"))
                pg.numberOfPagesInChapter = Int(results.int(forColumn:"NumberOfPagesInChapter"))
                pg.fontName = results.string(forColumn: "FontName")
                pg.fontSize = Int(results.int(forColumn:"FontSize"))
                pg.lineSpacing = Int(results.int(forColumn:"LineSpacing"))
                pg.width = Int32(results.int(forColumn:"Width"))
                pg.height = Int32(results.int(forColumn:"Height"))
                pg.verticalGapRatio = Double(results.double(forColumn:"VerticalGapRatio"))
                pg.horizontalGapRatio = Double(results.double(forColumn:"HorizontalGapRatio"))
                pg.isPortrait = results.int(forColumn:"IsPortrait") != 0 ? true:false
                pg.isDoublePagedForLandscape =  results.int(forColumn:"IsDoublePagedForLandscape") != 0 ? true:false
                
                rets.add(pg)
            }
        }catch {
            print(error.localizedDescription)
        }
        return rets
    }
    
    func fetchPagingInformations(bookCode:Int)->NSMutableArray! {
        checkDatabase()
        let sql = "SELECT * FROM Paging WHERE BookCode=\(bookCode) AND ChapterIndex=0"
        return self.fetchPagingInformations(sql: sql)
    }
    
    func fetchPagingInformations(pagingInformation pgi:PagingInformation)->NSMutableArray! {
        checkDatabase()
        let sql = String(format:"SELECT * FROM Paging WHERE BookCode=%d AND FontName='%@' AND FontSize=%d AND LineSpacing=%d AND Width=%d AND Height=%d AND HorizontalGapRatio=%f AND VerticalGapRatio=%f AND IsPortrait=%d AND IsDoublePagedForLandscape=%d Order By ChapterIndex",
                         pgi.bookCode,         pgi.fontName,        pgi.fontSize,        pgi.lineSpacing,    pgi.width,        pgi.height,        pgi.horizontalGapRatio,        pgi.verticalGapRatio,        pgi.isPortrait ? 1:0,    pgi.isDoublePagedForLandscape ? 1:0 );
        return self.fetchPagingInformations(sql: sql)
    }
    
    func fetchPagingInformationsForScan(bookCode:Int, numberOfChapters:Int)->NSMutableArray!  {
        checkDatabase()
        let sps:NSMutableArray = self.fetchPagingInformations(bookCode: bookCode)
        for i in 0 ..< sps.count {
            let sp:PagingInformation = sps.object(at: i) as! PagingInformation
            let tps:NSMutableArray = self.fetchPagingInformations(pagingInformation: sp)
            if tps.count == numberOfChapters {
                return tps
            }
        }
        return nil
    }
    
    // ItemRef ========================================================================================================
    func insertItemRef(itemRef:ItemRef!) {
        checkDatabase()
        /*
         let sql = "INSERT INTO ItemRef (BookCode,ChapterIndex,Title,Text,HRef,IdRef) Values(\(itemRef.bookCode),\(itemRef.chapterIndex),'','test text','','')"
         database.executeUpdate(sql, withArgumentsIn: [])
         */
        
        let sql = "INSERT INTO ItemRef (BookCode,ChapterIndex,Title,Text,HRef,IdRef) VALUES(?,?,?,?,?,?)"
        do {
            try database.executeUpdate(sql, values: [itemRef.bookCode,itemRef.chapterIndex,itemRef.title! ,itemRef.text! ,itemRef.href!  ,itemRef.idref! ])
        }catch {
            print(error.localizedDescription)
        }
    }
    
    func updateItemRef(itemRef:ItemRef) {
        checkDatabase()
        let sql = "UPDATE ItemRef SET Title=?,Text=? where BookCode=? and ChapterIndex=?"
        do {
            try database.executeUpdate(sql, values: [itemRef.title! ,itemRef.text! ,itemRef.bookCode,itemRef.chapterIndex])
        }catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteItemRefs(bookCode:Int) {
        checkDatabase()
        let sql = "DELETE FROM ItemRef where BookCode=\(bookCode)"
        database.executeUpdate(sql, withArgumentsIn: [])
    }
    
    func fetchItemRef(bookCode:Int, chapterIndex:Int) -> ItemRef! {
        checkDatabase()
        let sql = "SELECT * FROM ItemRef where BookCode=\(bookCode) and ChapterIndex=\(chapterIndex)"
        do {
            let results = try database.executeQuery(sql, values: [])
            while results.next() {
                let itemRef = ItemRef()
                itemRef.bookCode = Int32(results.int(forColumn:"BookCode"))
                itemRef.chapterIndex = Int32(results.int(forColumn:"ChapterIndex"))
                itemRef.title   = results.string(forColumn: "Title")
                itemRef.text    = results.string(forColumn: "Text")
                itemRef.href    = results.string(forColumn: "Href")
                itemRef.fullPath = results.string(forColumn: "FullPath")
                itemRef.idref   = results.string(forColumn: "IdREF")
                return itemRef
            }
        }catch {
            print(error.localizedDescription)
        }
        return nil
    }
}
