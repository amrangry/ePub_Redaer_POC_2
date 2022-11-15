//
//  SkyBookReaderViewController+Note.swift
//  BookStore
//
//  Created by Amr Elghadban on 13/11/2022.
//  Copyright © 2022 ADKA Tech. All rights reserved.
//

import UIKit

// MARK: - SkyBookReaderViewController+Note
extension SkyBookReaderViewController {
    
    @IBAction func notePressed(_ sender: Any) {
        hideMenuBox()
        rv.makeSelectionHighlight(currentColor)
        showNoteBox()
    }
    
    func hideNoteBox() {
        if self.noteBox.isHidden {
            return
        }
        self.saveNote()
        self.noteBox.removeFromSuperview()
        noteBox.isHidden = true
        arrow.isHidden = true
        noteTextView.text.removeAll()
        noteTextView.resignFirstResponder()
        hideBaseView()
    }
    
    func saveNote() {
        if self.noteBox.isHidden {
            return
        }
        if currentHighlight == nil {
            return
        }
        if let text = noteTextView.text {
            let newColor: UIColor!
            if (currentHighlight.highlightColor == 0) {
                newColor = self.getMarkerColor(colorIndex: 0)
            } else {
                newColor = self.UIColorFromRGB(rgbValue: UInt(currentHighlight.highlightColor))
            }
            
            if text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                currentHighlight.note = ""
                currentHighlight.isNote = false
            } else {
                currentHighlight.note = text
                currentHighlight.isNote = true
            }
            rv.changeHighlight(currentHighlight, color: newColor, note: text)
        }
    }
    
    func showNoteBox() {
        showBaseView()
        var startRect = rv.getStartRect(from: currentHighlight)
        var endRect = rv.getEndRect(from: currentHighlight)
        
        var topHegith:CGFloat = 50
        var bottomHeight:CGFloat = 50
        var noteX,noteY,noteWidth,noteHeight:CGFloat
        noteWidth = 280
        noteHeight = 230
        var arrowWidth:CGFloat = 20
        var arrowHeight:CGFloat = 20
        var arrowX:CGFloat = 0
        var arrowY:CGFloat = 0
        
        arrow.color = currentColor
        let delta:CGFloat = 60
        
        if (self.isPad()) { // iPad
            var toDownSide:Bool!
            var targetRect:CGRect!
            // detect there's room in top side
            if ((startRect.origin.y - noteHeight)<topHegith) {
                toDownSide = true  // reverse case
                targetRect = endRect
                isUpArrow = true
            } else {
                toDownSide = false   // normal case
                targetRect = startRect
                isUpArrow = true
            }
            
            if (!self.isPortrait()) { // landscape mode
                if (rv.isDoublePaged()) { // double Paged mode
                    // detect whether highlight is on left side or right side.
                    if (targetRect.origin.x < self.view.bounds.size.width/2) {
                        noteX = (self.view.bounds.size.width/2-noteWidth)/2
                    } else {
                        noteX = (self.view.bounds.size.width/2-noteWidth)/2 + self.view.bounds.size.width/2
                    }
                } else {
                    noteX = (targetRect.size.width-noteWidth)/2+targetRect.origin.x
                }
            } else { // portrait mode
                noteX = (targetRect.size.width-noteWidth)/2+targetRect.origin.x
            }
            
            if (noteX+noteWidth>self.view.bounds.size.width*0.9) {
                noteX = self.view.bounds.size.width*0.9 - noteWidth
            }
            if (noteX<self.view.bounds.size.width * 0.1) {
                noteX = self.view.bounds.size.width * 0.1
            }
            arrowX = (targetRect.size.width-arrowWidth)/2+targetRect.origin.x
            if (arrowX<noteX+10) {
                arrowX = noteX+10
            }
            if (arrowX>noteX+noteWidth-40) {
                arrowX = noteX+noteWidth-40
            }
            // set noteY according to isDownSide flag.
            if (!toDownSide) { // normal case - test ok
                noteY = targetRect.origin.y - noteHeight-10
                arrowY = noteY + noteHeight-5
                currentArrowFrame = CGRect(x:arrowX,y:arrowY,width:arrowWidth,height:arrowHeight)
            } else { // normal case
                noteY = targetRect.origin.y + delta
                arrowY = noteY-20
                currentArrowFrame = CGRect(x:arrowX,y:arrowY,width:arrowWidth,height:arrowHeight)
            }
        } else { // in case of iPhone, coordinates are fixed.
            if (self.isPortrait()) {
                noteY = (self.view.bounds.size.height - noteBox.frame.size.height)/2
            } else {
                noteY = (self.view.bounds.size.height - noteBox.frame.size.height)/2
                noteHeight = 150
                noteWidth = 500
            }
            noteX = (self.view.bounds.size.width - noteWidth)/2
        }
        
        currentNoteFrame = CGRect(x:noteX,y:noteY,width:noteWidth,height:noteHeight)
        
        noteBox.frame = currentNoteFrame
        noteBox.backgroundColor = currentColor
        self.view.addSubview(self.noteBox)
        self.noteBox.isHidden = false
    }
    
    @objc func noteIconPressed(_ sender: Any) {
        let noteIcon = sender as! UIButton
        let index = noteIcon.tag - 10000
        let pi: PageInformation = rv.getPageInformation()
        if let highlightsInPage = pi.highlightsInPage {
            let highlight = highlightsInPage[index] as! Highlight
            currentHighlight = highlight
            noteTextView.text = highlight.note
            currentStartRect = rv.getStartRect(from: currentHighlight)
            currentEndRect = rv.getEndRect(from: currentHighlight)
            self.showNoteBox()
        }
    }
    
    func getNoteIcon(highlight: Highlight, index:Int) -> UIButton {
        let noteIcon = UIButton(type: .custom)
        let iconImage = self.getNoteIconImageByHighlightColor(highlightColor: highlight.highlightColor)
        noteIcon.setImage(iconImage, for: .normal)
        noteIcon.addTarget(self, action: #selector(self.noteIconPressed(_:)), for: .touchUpInside) //<- use `#selector(...)`
        noteIcon.contentMode = .center
        var mx:CGFloat = 0
        var my:CGFloat = 0
        let mw:CGFloat = 32
        let mh:CGFloat = 32
        mx = self.view.bounds.size.width - 10 - mw
        my = CGFloat(highlight.top+32)
        if (self.isPad()) {
            if (!self.isPortrait()) { // doublePaged mode, landscape
                if (rv.isDoublePaged()) {
                    if (CGFloat(highlight.left)  < CGFloat(self.view.bounds.size.width/2)) {
                        mx = 50
                        my = CGFloat(highlight.top+3)
                    } else {
                        mx = self.view.bounds.size.width - 50 - mw
                        my = CGFloat(highlight.top+3)
                    }
                }
            } else { // portriat mode
                mx = self.view.bounds.size.width - 60 - mw
                my = CGFloat(highlight.top + 5)
            }
        }
        noteIcon.tag = 10000+index
        noteIcon.frame = CGRect(x:mx,y:my,width:mw,height:mh)
        return noteIcon
    }
    
    func getNoteIconImageByHighlightColor(highlightColor:UInt32)->UIImage {
        let index  = self.getMarkerIndexByRGB(rgb: UInt32(highlightColor))
        var image:UIImage!
        switch index {
        case 0:
            image = UIImage(named: "yellowMemo.png")
        case 1:
            image = UIImage(named: "greenMemo.png")
        case 2:
            image = UIImage(named: "blueMemo.png")
        case 3:
            image = UIImage(named: "redMemo.png")
        default:
            image = UIImage(named: "yellowMemo.png")
        }
        return image
    }
    
    func removeNoteIcons() {
        for view in self.view.subviews {
            if (view.tag >= 10000) {
                view.removeFromSuperview()
            }
        }
    }
    
    @IBAction func noteInHighlightBoxPressed(_ sender: Any) {
        hideHighlightBox()
        noteTextView.text = currentHighlight.note
        showNoteBox()
    }
    
    func processNoteIcons() {
        self.removeNoteIcons()
        let pi:PageInformation = rv.getPageInformation()
        var hasNoteIcon = false
        if let highlightsInPage = pi.highlightsInPage {
            for index in 0..<highlightsInPage.count {
                let highlight = highlightsInPage[index] as! Highlight
                if !highlight.isNote {
                    continue
                }
                let noteIcon = self.getNoteIcon(highlight:highlight, index: index)
                self.view.addSubview(noteIcon)
                self.view.bringSubviewToFront(noteIcon)
                hasNoteIcon = true
            }
            if (highlightsInPage.count != 0 && hasNoteIcon) { //swiftlint:disable:this empty_count
                rv.refresh()
            }
        }
    }
}
