//
//  ViewController.swift
//  EpubBookReader
//
//  Created by Amr Elghadban on 17/09/2022.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mediaSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mediaSwitch.isOn = true
        installSampleBooks() // if books are already installed, it will do nothing.
    }
    
    // install sample epubs from bundle.
    func installSampleBooks() {
        EPubReaderConfigurator.shared.installPublication(fileName: "Alice.epub")
        EPubReaderConfigurator.shared.installPublication(fileName: "Doctor.epub")
        EPubReaderConfigurator.shared.installPublication(fileName: "English_Book.epub")
        EPubReaderConfigurator.shared.installPublication(fileName: "Arabic_Book.epub")
    }

    @IBAction func mediaSwitchValueChange(_ sender: Any) {
        
    }
    
    @IBAction func openArabicBook(_ sender: Any) {
        let name = "Arabic_Book.epub"
        let fileName = name
        let ePubReader = EPubReaderConfigurator.shared
        ePubReader.config(fileName)
        ePubReader.loadBook()
        guard let viewController = ePubReader.getReaderViewController() else { return }
        open(viewController)
    }
    
    @IBAction func openEnglishBook(_ sender: Any) {
        let name = "English_Book.epub"
        let fileName = name
        let ePubReader = EPubReaderConfigurator.shared
        ePubReader.config(fileName)
        ePubReader.loadBook()
        guard let viewController = ePubReader.getReaderViewController() else { return }
        open(viewController)
    }
    
    @IBAction func downloadAndOpenEnglishBook(_ sender: Any) {
        let downloadURL = "http://bbebooksthailand.com/phpscripts/bbdownload.php?ebookdownload=FederalistPapers-EPUB2"
        let fileName = "FederalistPapers.epub"
        let ePubReader = EPubReaderConfigurator.shared
        ePubReader.config(fileName)
        if ePubReader.loadBook() {
            guard let viewController = ePubReader.getReaderViewController() else { return }
            open(viewController)
        } else {
            // need to download
            let downloadFolder = SkyConfigurator.shared.downloadsDirectoryFolderName ?? ""
            download(downloadURL, fileName: fileName, folderDirName: downloadFolder) { [weak self] response in
                if case .success(_) = response {
                    ePubReader.installPublication(fileName: fileName)
                    guard let viewController = ePubReader.getReaderViewController() else { return }
                    self?.open(viewController)
                }
            }
        }
    }
    
    func open(_ viewController: UIViewController) {
        viewController.modalPresentationStyle = .fullScreen
        let enableMediaOverlay = mediaSwitch.isOn
        (viewController as? SkyBookReaderViewController)?.enableMediaOverlay = enableMediaOverlay
        present(viewController, animated: false, completion: nil)
    }
    
}
