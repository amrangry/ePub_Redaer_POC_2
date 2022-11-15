//
//  SkyBookReaderViewController+LineSpacing.swift
//  BookStore
//
//  Created by Amr Elghadban on 13/11/2022.
//  Copyright © 2022 ADKA Tech. All rights reserved.
//

import UIKit

// MARK: - SkyBookReaderViewController+LineSpacing
extension SkyBookReaderViewController {
    func getRealLineSpacing(_ lineSpaceIndex:Int) ->Int {
        var rs: Int = 0
        switch lineSpaceIndex {
        case 0:
            rs = -1
        case 1:
            rs = 125
        case 2:
            rs = 150
        case 3:
            rs = 165
        case 4:
            rs = 180
        case 5:
            rs = 200
        default:
            rs = 150
        }
        return rs
    }
    
    func decreaseLineSpacing() {
        if setting.lineSpacing != 0 {
            var lineSpacingIndex = setting.lineSpacing!
            lineSpacingIndex -= 1
            let realLineSpacing = self.getRealLineSpacing(lineSpacingIndex)
            let ret = rv.changeLineSpacing(realLineSpacing)
            if ret {
                setting.lineSpacing = lineSpacingIndex
            }
        }
    }
    
    func increaseLineSpacing() {
        if setting.lineSpacing != 5 {
            var lineSpacingIndex = setting.lineSpacing!
            lineSpacingIndex += 1
            let realLineSpacing = self.getRealLineSpacing(lineSpacingIndex)
            let ret = rv.changeLineSpacing(realLineSpacing)
            if ret {
                setting.lineSpacing = lineSpacingIndex
            }
        }
    }
    
    func getRealFontSize(fontSizeIndex:Int) ->Int {
        var rs:Int = 0
        switch fontSizeIndex {
        case 0:
            rs = 15
        case 1:
            rs = 17
        case 2:
            rs = 20
        case 3:
            rs = 24
        case 4:
            rs = 27
        default:
            rs = 20
        }
        return rs
    }
    
    @IBAction func decreaseLineSpacingDown(_ sender: Any) {
        decreaseLineSpacingButton.backgroundColor = .lightGray
    }
    
    @IBAction func decreaseLineSpacingPressed(_ sender: Any) {
        decreaseLineSpacingButton.backgroundColor = .clear
        self.decreaseLineSpacing()
    }
    
    @IBAction func increaseLineSpacingDown(_ sender: Any) {
        increaseLineSpacingButton.backgroundColor = .lightGray
    }
    
    @IBAction func increaseLineSpacingPressed(_ sender: Any) {
        increaseLineSpacingButton.backgroundColor = .clear
        self.increaseLineSpacing()
    }
}
