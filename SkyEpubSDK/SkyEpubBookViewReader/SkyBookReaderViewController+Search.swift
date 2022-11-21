//
//  SkyBookReaderViewController+Search.swift
//  BookStore
//
//  Created by Amr Elghadban on 13/11/2022.
//  Copyright © 2022 ADKA Tech. All rights reserved.
//

import UIKit

// MARK: - SkyBookReaderViewController+Search
extension SkyBookReaderViewController {
    
    @IBAction func searchPressed(_ sender: Any) {
        self.showSearchBox(isCollapsed: true)
    }
    
    @IBAction func searchCancelPressed(_ sender: Any) {
        self.hideSearchBox()
    }
    
    @objc func gotoSearchPressed(_ sender: UIButton) {
        let gotoSearchButton: UIButton = sender
        if (gotoSearchButton.tag == -1) {
            self.hideSearchBox()
        } else if (gotoSearchButton.tag == -2) {
            searchScrollHeight -= gotoSearchButton.bounds.size.height
            searchScrollView.contentSize = CGSize(width: gotoSearchButton.bounds.size.width, height: searchScrollHeight)
            gotoSearchButton.superview!.removeFromSuperview()
            rv.searchMore()
        } else {
            self.hideSearchBox()
            let sr = searchResults.object(at: gotoSearchButton.tag) as! SearchResult
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // goto the position of searchResult.
                self.rv.gotoPage(searchResult: sr)
            }
        }
    }
    
    func addSearchResult(searchResult: SearchResult, mode: SkySearchResultType) {
        var headerText: String = ""
        var contentText: String = ""
        
        let resultView = Bundle.main.loadNibNamed("SkyEpubSearchResultView", owner: self, options: nil)?.first as! SkyEpubSearchResultView
        let gotoButton = resultView.searchResultButton!
        
        if (mode == .normal) {
            let ci = searchResult.chapterIndex
            let chapterTitle = rv.getChapterTitle(ci)
            var displayPageIndex = searchResult.pageIndex+1
            var displayNumberOfPages = searchResult.numberOfPagesInChapter
            if  rv.isDoublePaged() {
                displayPageIndex = displayPageIndex*2 //swiftlint:disable:this shorthand_operator
                displayNumberOfPages = displayNumberOfPages*2 //swiftlint:disable:this shorthand_operator
            }
            
            if (chapterTitle ?? "").isEmpty {
                if searchResult.numberOfPagesInChapter != -1 {
                    headerText = String(format: "%@ %d %@ %d/%d",NSLocalizedString("chapter",comment: ""),ci,NSLocalizedString("page",comment: ""),displayPageIndex,displayNumberOfPages)
                } else {
                    headerText = String(format:"%@ %d ",NSLocalizedString("chapter",comment: ""),ci)
                }
            } else {
                if searchResult.numberOfPagesInChapter != -1 {
                    headerText = String(format: "%@ %@ %d/%d",chapterTitle!,NSLocalizedString("page",comment: ""),displayPageIndex,displayNumberOfPages)
                } else {
                    headerText = String(format:"%@",chapterTitle!)
                }
            }
            
            contentText = searchResult.text
            searchResults.add(searchResult)
            
            gotoButton.tag = searchResults.count - 1
        } else if (mode == .more) {
            headerText =  NSLocalizedString("search_more",comment: "")
            contentText = String(format: "%d %@", searchResult.numberOfSearched, NSLocalizedString("found", comment: ""))
            gotoButton.tag =  -2
        } else if (mode == .finished) {
            headerText =  NSLocalizedString("search_finished", comment: "")
            contentText = String(format:"%d %@", searchResult.numberOfSearched, NSLocalizedString("found", comment: ""))
            gotoButton.tag =  -1
        }
        
        resultView.headerLabel.text = headerText
        resultView.contentLabel.text = contentText
        
        resultView.headerLabel.textColor = currentTheme.textColor
        resultView.contentLabel.textColor = currentTheme.textColor
        resultView.bottomLine.backgroundColor = currentTheme.borderColor
        resultView.bottomLine.alpha = 0.65
        
        gotoButton.addTarget(self, action: #selector(self.gotoSearchPressed(_:)), for: .touchUpInside)
        
        var rx, ry, rw, rh: CGFloat
        rx = 0
        ry = searchScrollHeight
        rw = searchScrollView.bounds.size.width
        rh = 90
        
        resultView.frame = CGRect(x: rx, y: ry, width: rw, height: rh)
        
        searchScrollView.addSubview(resultView)
        searchScrollHeight += rh
        searchScrollView.contentSize = CGSize(width: rw, height: searchScrollHeight)
        var co = searchScrollHeight-searchScrollView.bounds.size.height
        if ( co <= 0) {
            co = 0
        }
        searchScrollView.contentOffset  = CGPoint(x: 0, y: co)
    }
    
}
