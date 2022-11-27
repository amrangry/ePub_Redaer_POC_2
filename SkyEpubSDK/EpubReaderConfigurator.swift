//
//  EpubReaderConfigurator.swift
//  BookStore
//
//  Created by Amr Elghadban on 17/11/2022.
//  Copyright © 2022 ADKA Tech. All rights reserved.
//

import Foundation
import UIKit

//let fileName = downloadInfoObject.fileName
//let ePubReader = EpubReaderConfigurator()
//ePubReader.config(fileName)
//ePubReader.loadBook()
//guard let viewController = ePubReader.getReaderViewController() else { return }
//viewController.modalPresentationStyle = .fullScreen
//let router = NavigationRouter.shared
//router.navigateTo(viewController: viewController, navigationController: router.navigatorController!)
class EpubReaderConfigurator {
    
    static let shared = EpubReaderConfigurator()
    
    private init() {
        ePubConfigurator = SkyConfigurator.shared //UIApplication.shared.delegate as? AppDelegate
        ePubDataHandler = ePubConfigurator.data
        addSkyErrorNotificationObserver()
    }
    
    // MARK: - Controller MVVM
    private var fileName: String?
    private var ePubConfigurator: SkyConfigurator!
    private var ePubDataHandler: SkyData!
    
    func config(_ value: String?) {
        fileName = value
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
        
        Debugger().printOut("SkyError code \(code) level \(level) message: \(message)", context: .error)
    }
    
    
    func instalPublication(url: URL) {
       
    }
    
    func installPublication(fileName value: String) {
        ePubDataHandler.installEpub(fileName: value)
    }
    
    @discardableResult
    func loadBook() -> Bool {
        // install sample epubs from bundle.
        guard let fileName = fileName else { return false }
        let bookPath = ePubDataHandler.getBookPath(fileName: fileName)
        let isExists = FileManager.default.fileExists(atPath: bookPath) // must be downloaded and exist if reach this point
        guard isExists == true else { return false }
        guard ePubDataHandler.fetchBookInformation(fileName: fileName) != nil else {
            ePubDataHandler.configBook(fileName)
            guard ePubDataHandler.fetchBookInformation(fileName: fileName) != nil else { return false }
            return true
        }
        return true
        // isExists Yes  No                   No                Yes
        // info     Yes  Yes                  No                No
        // Action   Open download -> open     download -> Open  checkOpen
    }
    
    func getReaderViewController() -> UIViewController? {
        guard loadBook() else { return nil }
        guard let fileName = fileName else { return nil }
        guard let bi = ePubDataHandler.fetchBookInformation(fileName: fileName) else {
            return nil
        }
        let viewController = getReaderViewController(for: bi)
        return viewController
    }
    
    func getReaderViewController(for bi: BookInformation) -> UIViewController? {
        let storyboard = UIStoryboard(name: "SkyEpubStoryboard", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "SkyBookReaderViewController") as? SkyBookReaderViewController else {
            return nil
        }
        viewController.bookInformation = bi
        viewController.enableMediaOverlay = false
        return viewController
    }

}
