//
//  ViewController.swift
//  EpubBookReader
//
//  Created by Amr Elghadban on 17/09/2022.
//

import UIKit

class ViewController: UIViewController {

    var ad:AppDelegate!
    var sd:SkyData!
    
    var sortType:Int = 0
    var searchKey:String = ""
    var bis:NSMutableArray!
    
    func loadBis() {
        self.bis = sd.fetchBookInformations(sortType: self.sortType, key: searchKey)
    }
    func reload() {
        self.loadBis()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        ad = UIApplication.shared.delegate as? AppDelegate
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
    
    func openBook(_ bi: BookInformation) {
        let storyboard = UIStoryboard(name: "BookReaderStoryboard", bundle: nil)
        let bvc = storyboard.instantiateViewController(withIdentifier: "BookViewController") as? BookViewController
        bvc?.modalPresentationStyle = .fullScreen
        bvc?.bookInformation = bi
        present(bvc!, animated: false, completion: nil)
    }
}

