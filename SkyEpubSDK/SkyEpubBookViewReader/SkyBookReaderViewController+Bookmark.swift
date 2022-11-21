//
//  SkyBookReaderViewController+Bookmark.swift
//  BookStore
//
//  Created by Amr Elghadban on 13/11/2022.
//  Copyright © 2022 ADKA Tech. All rights reserved.
//

import UIKit

// MARK: - SkyBookReaderViewController+Bookmark
extension SkyBookReaderViewController {
    
    @IBAction func bookmarkPressed(_ sender: Any) {
        self.toggleBookmark()
    }
    
    func processBookmark() {
        if self.isBookmarked {
            bookmarkButton.setImage(UIImage(named: "bookmarked"), for: .normal)
        } else {
            bookmarkButton.setImage(UIImage(named: "bookmark"), for: .normal)
        }
    }
    
    func toggleBookmark() {
        sd.toggleBookmark(pageInformation: rv.getPageInformation())
        self.isBookmarked = !self.isBookmarked
        self.processBookmark()
    }
    
    func reloadBookmarks() {
        self.bookmarks = self.sd.fetchBookmarks(bookCode: self.bookCode)
        bookmarksTableView.reloadData()
    }
    
}
