//
//  SkyBookReaderViewController+SkyProviderDataSource.swift
//  BookStore
//
//  Created by Amr Elghadban on 13/11/2022.
//  Copyright © 2022 ADKA Tech. All rights reserved.
//

import UIKit

// MARK: - SkyBookReaderViewController+SkyProviderDataSource
extension SkyBookReaderViewController: SkyProviderDataSource {
    
    // SKYEPUB SDK CALLBACK
    // called when sdk needs to ask key to decrypt the encrypted epub. (encrypted by skydrm or any other drm which conforms to epub3 encrypt specification)
    // for more information about SkyDRM. please refer to the links below
    // https://www.dropbox.com/s/ctbe4yvhs60lq4n/SkyDRM%20Diagram.pdf?dl=1
    // https://www.dropbox.com/s/ch0kf0djrcxd241/SkyDRM%20Solution.pdf?dl=1
    // https://www.dropbox.com/s/xkxw4utpqq9frjw/SCS%20API%20Reference.pdf?dl=1
    func skyProvider(_ sp: SkyProvider!, keyForEncryptedData uuidForContent: String!, contentName: String!, uuidForEpub: String!) -> String! {
        let key = sd.keyManager.getKey(uuidForEpub, uuidForContent: uuidForContent)
        return key
    }
    
}
