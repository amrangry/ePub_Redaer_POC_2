//
//  ViewController.swift
//  EpubBookReader
//
//  Created by Amr Elghadban on 17/09/2022.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    var ad: SkyConfigurator!
    var sd: SkyData!
    
    var sortType: Int = 0
    var searchKey: String = ""
    var bis: NSMutableArray!
    
    func loadBis() {
        self.bis = sd.fetchBookInformations(sortType: self.sortType, key: searchKey)
    }
    
    func reload() {
        self.loadBis()
    }
    
    @IBOutlet weak var mediaSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mediaSwitch.isOn = true
        
        ad = SkyConfigurator.shared //UIApplication.shared.delegate as? AppDelegate
        sd = ad.data
        self.addSkyErrorNotificationObserver()
        installSampleBooks() // if books are already installed, it will do nothing.
        self.reload()
    }
    
    // install sample epubs from bundle.
    func installSampleBooks() {
        sd.installEpub(fileName: "Alice.epub")
        sd.installEpub(fileName: "Doctor.epub")
        sd.installEpub(fileName: "English_Book.epub")
        sd.installEpub(fileName: "Arabic_Book.epub")
    }
    
    func addSkyErrorNotificationObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveSkyErrorNotification(_:)),
                                               name: NSNotification.Name("SkyError"),
                                               object: nil)
    }
    
    // if any error is reported by sdk.
    @objc func didReceiveSkyErrorNotification(_ notification: Notification) {
        guard let code: String = notification.userInfo?["code"] as? String else { return }
        guard let level: String = notification.userInfo?["level"] as? String else { return }
        guard let message: String = notification.userInfo?["message"] as? String else { return }
        
        NSLog("SkyError code %d level %d message:%@",code,level,message)
    }
    
    //    // when top,left import button pressed, new epub file can be imported and installed from device's file system.
    //    @IBAction func importPressed(_ sender: Any) {
    //        let picker = UIDocumentPickerViewController(documentTypes: ["org.idpf.epub-container"], in: .import)
    //        picker.delegate = self
    //        picker.modalPresentationStyle = .fullScreen
    //        self.present(picker, animated: true, completion: nil)
    //    }
    //
    //    // when importing a epub file from local file system is over,  install the epub.
    //    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    //        if controller.documentPickerMode == .import {
    //            print(urls[0].path)
    //            sd.installEpub(url:urls[0])
    //            self.reload()
    //        }
    //    }
    
    //    @IBAction func readButtonPressed(_ sender: Any) {
    //        guard let name = bookName else { return }
    //        guard let bookPath = Bundle.main.path(forResource: name, ofType: "epub") else {
    //            return
    //        }
    //
    //        let url = URL(fileURLWithPath: bookPath, isDirectory: false)
    //        openBook()
    //    }
    
    @IBAction func mediaSwitchValueChange(_ sender: Any) {
        
    }
    
    @IBAction func openArabicBook(_ sender: Any) {
        //let bi:BookInformation = self.bis.object(at: 0) as! BookInformation
        let name = "Arabic_Book.epub"
        guard let bi = sd.fetchBookInformation(fileName: name) else { return }
        openBook(bi)
    }
    
    @IBAction func openEnglishBook(_ sender: Any) {
        let name = "English_Book.epub"
        guard let bi = sd.fetchBookInformation(fileName: name) else { return }
        openBook(bi)
    }
    
    @IBAction func downloadAndOpenEnglishBook(_ sender: Any) {
        let downloadURL = "http://bbebooksthailand.com/phpscripts/bbdownload.php?ebookdownload=FederalistPapers-EPUB2"
        let fileName = "FederalistPapers.epub"
        let downloadFolder = SkyConfigurator.downloadsDirectoryFolderName ?? ""
        if let bi = sd.fetchBookInformation(fileName: fileName) {
            let bookPath = sd.getBookPath(fileName: fileName)
            let isExists = FileManager.default.fileExists(atPath: bookPath)
            if (isExists) {
                openBook(bi)
            } else {
                // need to download
                let downloadFolder = SkyConfigurator.downloadsDirectoryFolderName ?? ""
                download(downloadURL, fileName: fileName, folderDirName: downloadFolder) { [weak self] response in
                    if case .success(_) = response {
                        self?.sd.copyFileFromDownloadsToBooks(fileName: fileName)
                        self?.openBook(bi)
                    }
                }
            }
            //            let bookPath2 = sd.getDownloadPath(fileName: fileName)
            //            let isExistsInDownloads = fileManager.fileExists(atPath: bookPath)
            //            if (isExists) {
            //            openBook(bi)
        } else {
            let downloadFolder = SkyConfigurator.downloadsDirectoryFolderName ?? ""
            download(downloadURL, fileName: fileName, folderDirName: downloadFolder ) { [weak self] response in
                switch response {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    guard let file = result as? String else {
                        print("not string")
                        return
                    }
                    //sourcePath = sourcePath.replacingOccurrences(of: "file://", with: "")
                    let startWithValue = "file://"
                    if (file.starts(with: startWithValue) == false) {
                        print("here")
                    }
                    
                    self?.sd.installEpub(fileName: fileName)
                    guard let bi = self?.sd.fetchBookInformation(fileName: fileName) else { return }
                    self?.openBook(bi)
                }
            }
        }
    }
    
    func openBook(_ bi: BookInformation) {
        let storyboard = UIStoryboard(name: "SkyEpubStoryboard", bundle: nil)
        let bvc = storyboard.instantiateViewController(withIdentifier: "SkyBookReaderViewController") as? SkyBookReaderViewController
        bvc?.modalPresentationStyle = .fullScreen
        bvc?.bookInformation = bi
        let enableMediaOverlar = mediaSwitch.isOn
        bvc?.enableMediaOverlay = enableMediaOverlar
        present(bvc!, animated: false, completion: nil)
    }
}

//typealias CallResponse<T> = ((NetworkResult<T>) -> Void)?
typealias ResultResponse<T> = ((Result<T, Error>) -> Void)

extension ViewController {
    
    func download(_ urlString: String, fileName: String, folderDirName: String, completion: @escaping ResultResponse<Any>) {
        var finalFileName = fileName
        let downloadsFolderName = folderDirName + "/"
        if (fileName.starts(with: downloadsFolderName) == false) {
            finalFileName = "\(downloadsFolderName)\(fileName)"
        }
        let destination: DownloadRequest.Destination = { _, _ in
            let fileURL = FileHelper.shared.getFileURL(for: finalFileName) ?? URL(fileURLWithPath: finalFileName)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        let progressQueue = DispatchQueue(label: "com.alamofire.progressQueue", qos: .utility)
        let request = AF.download(urlString,
                                  method: .get,
                                  parameters: nil,
                                  encoding: JSONEncoding.default,
                                  headers: nil,
                                  interceptor: nil,
                                  requestModifier: nil,
                                  to: destination)
            .validate(statusCode: 200 ... 500)
        //            .downloadProgress(queue: DispatchQueue.global(qos: .utility)) { progress in
        //                print("Progress: \(progress.fractionCompleted)")
        //            }
        //            .downloadProgress { progress in
        //                    print("Download Progress: \(progress.fractionCompleted)")
        //            }
            .downloadProgress(queue: progressQueue) { progress in
                print("Download Progress: \(progress.fractionCompleted)")
            }
            .responseData(queue: .main) { response in
                switch response.result {
                case .success:
                    if let destinationURL = response.fileURL?.path {
                        completion(.success(destinationURL))
                    } else {
                        let error = NSError(domain: "Network", code: 200) as! Error
                        //"Couldn't get destination url"
                        completion(.failure(error))
                    }
                case .failure(let error):
                    // check if file exists before
                    if let destinationURL = response.fileURL {
                        if FileManager.default.fileExists(atPath: destinationURL.path) {
                            // File exists, so no need to override it. simply return the path.
                            completion(.success(destinationURL))
                            print()
                        } else {
                            completion(.failure(error))
                        }
                    } else {
                        completion(.failure(error))
                    }
                }
                
            }
        request.resume()
    }
    
}
