//
//  SkyBookReaderViewController+SIBox.swift
//  BookStore
//
//  Created by Amr Elghadban on 13/11/2022.
//  Copyright © 2022 ADKA Tech. All rights reserved.
//

import UIKit

// MARK: - SkyBookReaderViewController+SIBox
extension SkyBookReaderViewController {
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        self.updateSIBox()
    }
    
    @IBAction func sliderDragStarted(_ sender: Any) {
        self.showSIBox()
    }
    
    // about pagePosition concepts of skyepub, please refer to the link https://www.dropbox.com/s/heu7v0mjtyayh0q/PagePositionInBook.pdf?dl=1
    @IBAction func sliderDragEnded(_ sender: Any) {
        let position = Int32(slider.value)
        // if rv is global pagination mode,
        if rv.isGlobalPagination() {
            let pib = position
            let ppb = rv.getPagePositionInBook(pageIndexInBook: pib)
            rv.gotoPage(pagePositionInBook: ppb)  // goto the position in book by ppb which is calculated by pageIndex in book.
            print("sliderDragEnded for Global")
        } else {
            rv.gotoPage(pagePositionInBook: Double(slider.value), animated: false)
        }
        hideSIBox()
    }
    
    @IBAction func sliderDragEndedOutside(_ sender: Any) {
        
    }
    
    // SIBox - slider IndexBox
    func applyThemeToSIBox(theme:SkyEpubTheme) {
        siBox.layer.borderWidth = 1
        siBox.layer.cornerRadius = 10
        
        if currentThemeIndex == 0 || currentThemeIndex == 1 {
            siBox.backgroundColor = theme.iconColor
            siBox.layer.borderColor = theme.textColor.cgColor
            siBoxChapterTitleLabel.textColor = theme.backgroundColor
            siBoxPositionLabel.textColor = theme.backgroundColor
        } else {
            siBox.backgroundColor = theme.boxColor
            siBox.layer.borderColor = UIColor.darkGray.cgColor
            siBoxChapterTitleLabel.textColor = theme.textColor
            siBoxPositionLabel.textColor = theme.textColor
        }
    }
    
    func showSIBox() {
        var sx,sy,sw,sh:CGFloat
        sx = (view.frame.size.width-siBox.frame.size.width)/2
        sy = view.frame.height-135
        sw = siBox.frame.width
        sh = siBox.frame.height
        if !rv.isGlobalPagination() {
            sh = 42
            sy = sy + 10 //swiftlint:disable:this shorthand_operator
            siBoxPositionLabel.isHidden = true
        } else {
            sh = 52
            siBoxPositionLabel.isHidden = false
        }
        siBox.frame = CGRect(x:sx, y:sy, width:sw, height:sh)
        view.addSubview(siBox)
        applyThemeToSIBox(theme: currentTheme)
        siBox.isHidden = false
    }
    
    func hideSIBox() {
        if siBox.isHidden {
            return
        }
        siBox.isHidden = true
        siBox.removeFromSuperview()   // this line causes the constraint issues.
    }
    
    func updateSIBox() {
        var ppb: Double = 0
        var pi: PageInformation!
        let pib = slider.value
        
        if (rv.isGlobalPagination()) {
            ppb = rv.getPagePositionInBook(pageIndexInBook: Int32(pib))
        } else {
            ppb = Double(slider.value)
        }
        pi = rv.getPageInformationAtPagePosition(inBook: ppb)
        
        let ci = pi.chapterIndex
        var caption:String!
        
        if slider.value == slider.maximumValue {
            caption = "The End"
        } else if (pi.chapterTitle ?? "").isEmpty {
            caption = "Chapter \(ci)th"
        } else {
            caption = pi.chapterTitle
        }
        
        siBoxChapterTitleLabel.text = caption
        if rv.isGlobalPagination() {
            let gpi = Int(slider.value)
            siBoxPositionLabel.text = "\(gpi + 1)"
        } else {
            siBoxPositionLabel.text = ""
        }
    }
}
