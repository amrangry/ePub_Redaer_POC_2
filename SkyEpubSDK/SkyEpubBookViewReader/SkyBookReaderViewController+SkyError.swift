//
//  SkyBookReaderViewController+SkyError.swift
//  BookStore
//
//  Created by Amr Elghadban on 13/11/2022.
//  Copyright © 2022 ADKA Tech. All rights reserved.
//

import Foundation

// MARK: - SkyBookReaderViewController+SkyError
extension SkyBookReaderViewController {
    
    func addSkyErrorNotificationObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveSkyErrorNotification(_:)),
                                               name: NSNotification.Name("SkyError"),
                                               object: nil)
    }
    
    func removeSkyErrorNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("SkyError"), object: nil)
    }
    
    // if any error is reported by sdk.
    @objc func didReceiveSkyErrorNotification(_ notification: Notification) {
        guard let code: String = notification.userInfo?["code"] as? String else { return }
        guard let level: String = notification.userInfo?["level"] as? String else { return }
        guard let message: String = notification.userInfo?["message"] as? String else { return }
        NSLog("SkyError code %d level %d message:%@",code,level,message)
    }
    
}
