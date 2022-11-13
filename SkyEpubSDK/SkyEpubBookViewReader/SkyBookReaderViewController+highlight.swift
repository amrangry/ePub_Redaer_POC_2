//
//  SkyBookReaderViewController+highlight.swift
//  BookStore
//
//  Created by Amr Elghadban on 13/11/2022.
//  Copyright © 2022 ADKA Tech. All rights reserved.
//

import UIKit

// MARK: - SkyBookReaderViewController+highlight
extension SkyBookReaderViewController {
    
    @IBAction func highlightPressed(_ sender: Any) {
        hideMenuBox()
        showHighlightBox()
        // makeSelectionHighlight will make selected text highlight and call didInsert highlight call back.
        rv.makeSelectionHighlight(currentColor)
    }
    
    func reloadHighlights() {
        self.highlights = self.sd.fetchHighlights(bookCode: self.bookCode)
        notesTableView.reloadData()
    }
    
    func showHighlightBox() {
        showBaseView()
        self.view.addSubview(highlightBox)
        highlightBox.frame.origin.x = currentMenuFrame.origin.x
        highlightBox.frame.origin.y = currentMenuFrame.origin.y
        highlightBox.backgroundColor = currentColor
        highlightBox.isHidden = false
        showArrow(type: 1)
    }
    
    func highlightDrawnOnFront() -> Bool {
        return false
    }
    
    func showHighlightBox(startRect: CGRect, endRect: CGRect) {
        calcMenuFrames(start: startRect, end: endRect)
        self.showHighlightBox()
    }
    
    func hideHighlightBox() {
        self.highlightBox.removeFromSuperview()
        highlightBox.isHidden = true
        arrow.isHidden = true
        hideBaseView()
    }
}
