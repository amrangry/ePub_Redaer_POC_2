//
//  SkyBookReaderViewController+UITableView.swift
//  BookStore
//
//  Created by Amr Elghadban on 13/11/2022.
//  Copyright © 2022 ADKA Tech. All rights reserved.
//

import UIKit

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SkyBookReaderViewController: UITableViewDelegate, UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var ret:Int = 0
        if (tableView.tag==200) {
            ret  = rv.navMap.count
        } else if (tableView.tag==201) {
            ret  = self.highlights.count
        } else if (tableView.tag==202) {
            ret  = self.bookmarks.count
        }
        return ret
    }
    
    // for more information about navMap and navPoint in epub, please refer to https://www.dropbox.com/s/yko3mq35if9ix68/NavMap.pdf?dl=1
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row
        if (tableView.tag==200) {
            // constructs the table of contents.
            // navMap and navPoint contains the information of TOC (table of contents)
            let cnp:NavPoint! = rv.getCurrentNavPoint()
            if let cell:SkyEpubContentsTableViewCell = contentsTableView.dequeueReusableCell(withIdentifier: "SkyEpubContentsTableViewCell", for: indexPath) as? SkyEpubContentsTableViewCell {
                let np:NavPoint = rv.navMap.object(at: index) as! NavPoint
                var leadingSpaceForDepth:String = ""
                for _ in 0..<np.depth {
                    leadingSpaceForDepth += "   "
                }
                cell.chapterTitleLabel.text = leadingSpaceForDepth + np.text
                cell.positionLabel.text = ""
                cell.chapterTitleLabel.textColor = currentTheme.textColor
                cell.positionLabel.textColor = currentTheme.textColor
                
                if np.chapterIndex == currentPageInformation.chapterIndex {
                    cell.chapterTitleLabel.textColor = UIColor.systemIndigo
                }
                if cnp != nil && np == cnp {
                    cell.chapterTitleLabel.textColor = UIColor.systemBlue
                }
                
                return cell
            }
        } else if (tableView.tag==201) {
            // constructs the table of highlights
            if let cell:SkyEpubNotesTableViewCell = notesTableView.dequeueReusableCell(withIdentifier: "SkyEpubNotesTableViewCell", for: indexPath) as? SkyEpubNotesTableViewCell {
                let highlight:Highlight = highlights.object(at: index) as! Highlight
                cell.positionLabel.text = rv.getChapterTitle(highlight.chapterIndex)
                cell.highlightTextLabel.text = highlight.text
                cell.noteTextLabel.text = highlight.note
                cell.datetimeLabel.text = highlight.datetime
                
                cell.positionLabel.textColor = currentTheme.textColor
                cell.highlightTextLabel.textColor = .black
                cell.noteTextLabel.textColor = currentTheme.textColor
                cell.datetimeLabel.textColor = currentTheme.textColor
                
                cell.highlightTextLabel.backgroundColor =  UIColorFromRGB(rgbValue: UInt(highlight.highlightColor))
                return cell
            }
        } else if (tableView.tag==202) {
            // constructs the table of bookmarks
            if let cell:SkyEpubBookmarksTableViewCell = bookmarksTableView.dequeueReusableCell(withIdentifier: "SkyEpubBookmarksTableViewCell", for: indexPath) as? SkyEpubBookmarksTableViewCell {
                let pg:PageInformation = bookmarks.object(at: index) as! PageInformation
                cell.positionLabel.text = rv.getChapterTitle(Int32(pg.chapterIndex))
                cell.datetimeLabel.text = pg.datetime
                cell.datetimeLabel.textColor = currentTheme.textColor
                cell.positionLabel.textColor = currentTheme.textColor
                return cell
            }
        }
        return UITableViewCell()
    }
    
    // called when user presses one item of tables
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        if (tableView.tag==200) {
            let np:NavPoint = rv.navMap.object(at: index) as! NavPoint
            rv.gotoPage(navPoint: np)
            self.hideListBox()
        } else if (tableView.tag==201) {
            let highlight:Highlight = highlights.object(at: index) as! Highlight
            rv.gotoPage(highlight: highlight)
            self.hideListBox()
        } else if (tableView.tag==202) {
            let pg:PageInformation = bookmarks.object(at: index) as! PageInformation
            rv.gotoPage(pagePositionInBook: pg.pagePositionInBook, animated: false)
            self.hideListBox()
        }
    }
    
    // bookmarks and highlights list are editable to delete a item from the list.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (tableView.tag==201 || tableView.tag==202) {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let index = indexPath.row
            if (tableView.tag==201) {
                let highlight:Highlight = highlights.object(at: index) as! Highlight
                self.sd.deleteHighlight(highlight: highlight)
                self.reloadHighlights()
            } else if (tableView.tag==202) {
                let pi:PageInformation = bookmarks.object(at: index) as! PageInformation
                self.sd.deleteBookmark(pageInformation: pi)
                self.reloadBookmarks()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let index = indexPath.row
        var height:CGFloat = 70
        if (tableView.tag == 200) {
            height = 40
        } else if (tableView.tag == 201) {
            let highlight:Highlight = highlights.object(at: index) as! Highlight
            if highlight.isNote {
                height = 125
            } else {
                height = 100
            }
        } else if (tableView.tag == 202) {
            height = 67
        }
        return height
    }
}
