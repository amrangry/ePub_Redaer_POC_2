//
//  SkyBookReaderViewController+ReflowableViewControllerDataSource.swift
//  BookStore
//
//  Created by Amr Elghadban on 13/11/2022.
//  Copyright © 2022 ADKA Tech. All rights reserved.
//

import UIKit

// MARK: - ReflowableViewControllerDataSource, ReflowableViewControllerDelegate
extension SkyBookReaderViewController: ReflowableViewControllerDataSource, ReflowableViewControllerDelegate {
    
    // SKYEPUB SDK CALLBACK
    // called when page is moved.
    // PageInformation object contains all information about current page position.
    func reflowableViewController(_ rvc: ReflowableViewController, pageMoved pageInformation:PageInformation) {
        let ppb = pageInformation.pagePositionInBook
        //let pageDelta = ((1/pageInformation.numberOfChaptersInBook)/pageInformation.numberOfPagesInChapter)
        if rv.isGlobalPagination() {
            if !rv.isPaging() {
                slider.minimumValue = 0
                slider.maximumValue = Float(pageInformation.numberOfPagesInBook-1)
                slider.value = Float(pageInformation.pageIndexInBook)
                let cgpi = rv.getPageIndexInBook(pagePositionInBook:pageInformation.pagePositionInBook )
                print("slider.maximumValue                          \(Float(pageInformation.numberOfPagesInBook-1))")
                print("pageInformation.pageIndexInBook              \(pageInformation.pageIndexInBook)")
                print("rv.getPageIndexInBookByPagePosition(inBook:  \(cgpi)")
            }
        } else {
            slider.value = Float(ppb)
        }
        self.bookInformation.position = pageInformation.pagePositionInBook
        titleLabel.text = rvc.title
        changePageLabels(pageInformation: pageInformation)
        isBookmarked = sd.isBookmarked(pageInformation: pageInformation)
        currentPageInformation = pageInformation
        if autoStartPlayingWhenNewChapterLoaded && isChapterJustLoaded {
            if (rv.isMediaOverlayAvailable() && setting.mediaOverlay) || (rv.isTTSEnabled() && setting.tts && isAutoPlaying) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.rv.playFirstParallelInPage()
                    self.changePlayAndPauseButton()
                }
            }
        }
        
        isChapterJustLoaded = false
        
        let time = DispatchTime.now() + .seconds(0)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.processNoteIcons()
            self.processBookmark()
        }
    }
    
    // SKYEPUB SDK CALLBACK
    // called when a new chapter has been just loaded.
    func reflowableViewController(_ rvc: ReflowableViewController?, didChapterLoad chapterIndex: Int32) {
        if rv.isMediaOverlayAvailable() && setting.mediaOverlay {
            rv.setTTSEnabled(false)
            self.showMediaBox()
        } else if  rv.isTTSEnabled() {
            self.showMediaBox()
        } else {
            self.hideMediaBox()
        }
        isChapterJustLoaded = true
    }
    
    // SKYEPUB SDK CALLBACK - DataSource
    // all highlights which belong to the chapter should be returned to SDK.
    // for more information about SkyEpub highlight system, please refer to https://www.dropbox.com/s/knnbxqdn077aace/Highlight%20Offsets.pdf?dl=1
    func reflowableViewController(_ rvc: ReflowableViewController?, highlightsForChapter chapterIndex: Int) -> NSMutableArray? {
        let highlights = sd.fetchHighlights(bookCode: self.bookCode, chapterIndex:chapterIndex)
        return highlights
    }
    
    // SKYEPUB SDK CALLBACK
    // called when a new highlight is about to be inserted.
    func reflowableViewController(_ rvc: ReflowableViewController?, didInsert highlight: Highlight?) {
        if let value = highlight {
            sd.insertHighlight(highlight: value)
        }
        currentHighlight = highlight
        self.processNoteIcons()
        
    }
    
    // SKYEPUB SDK CALLBACK
    // called when a new highlight is about to be deleted.
    func reflowableViewController(_ rvc: ReflowableViewController?, didDelete highlight: Highlight?) {
        if let value = highlight {
            sd.deleteHighlight(highlight: value)
        }
        self.processNoteIcons()
    }
    
    // SKYEPUB SDK CALLBACK
    // called when a new highlight is about to be updated.
    func reflowableViewController(_ rvc: ReflowableViewController?, didUpdate highlight: Highlight?) {
        if let value = highlight {
            sd.updateHighlight(highlight: value)
        }
        self.processNoteIcons()
    }
    
    // SKYEPUB SDK CALLBACK
    // called when user touches on a highlight.
    func reflowableViewController(_ rvc: ReflowableViewController?, didHitHighlight highlight: Highlight?, at position: CGPoint, startRect: CGRect, endRect: CGRect) {
        currentHighlight = highlight
        if let value = highlight {
            currentColor = UIColorFromRGB(rgbValue: UInt(value.highlightColor))
        }
        self.showHighlightBox(startRect: startRect, endRect: endRect)
    }
    
    // SKYEPUB SDK CALLBACK
    // called when User selects text.
    func reflowableViewController(_ rvc: ReflowableViewController?, didSelectRange highlight: Highlight?, start startRect: CGRect, end endRect: CGRect) {
        currentHighlight = highlight
        currentStartRect = startRect
        currentEndRect = endRect
        showMenuBox(start:startRect,end:endRect)
    }
    
    // SKYEPUB SDK CALLBACK
    // called while user is changing the selection of text.
    func reflowableViewController(_ rvc: ReflowableViewController?, didSelectionChanged selectedText: String?) {
        self.hideMenuBox()
        self.hideHighlightBox()
    }
    
    // SKYEPUB SDK CALLBACK
    // called when user cancels text selection.
    func reflowableViewController(_ rvc: ReflowableViewController?, didSelectionCanceled lastSelectedText: String?) {
        self.hideMenuBox()
    }
    
    // SKYEPUB SDK CALLBACK
    // if you need to modify text to speech (like numbers, punctuation or etc), you can send over the modified text of original rawString.
    func reflowableViewController(_ rvc: ReflowableViewController?, postProcessText rawString: String?) -> String? {
        return rawString
    }
    
    func reflowableViewController(_ rvc: ReflowableViewController?, didHitLink urlString: String?) {
        //print("didHitLink "+urlString)
    }
    
    func reflowableViewController(_ rvc: ReflowableViewController?, didHitAudio urlString: String?) {
        //print("didHitAudio")
    }
    
    func reflowableViewController(_ rvc: ReflowableViewController?, didHitImage urlString: String?) {
        // print("didHitImage "+urlString)
    }
    
    func reflowableViewController(_ rvc: ReflowableViewController?, didHitVideo urlString: String?) {
        // print("didHitVideo")
    }
    
    // custom javascript
    func reflowableViewController(_ rvc: ReflowableViewController?, scriptForChapter chapterIndex: Int) -> String? {
        return ""
    }
    /*
     // SKYEPUB SDK CALLBACKS - not used yet in this project.
     
     func reflowableViewController(_ rvc: ReflowableViewController?, parallelsForTTS chapterIndex: Int32, text: String?) -> NSMutableArray! {
     <#code#>
     }
     
     func reflowableViewController(_ rvc: ReflowableViewController?, didHitLinkForLinearNo urlString: String?) {
     <#code#>
     }
     
     func reflowableViewController(_ rvc: ReflowableViewController?, didDetectDoubleTapAt position: CGPoint) {
     <#code#>
     }
     
     func reflowableViewController(_ rvc: ReflowableViewController?, didHitBookmark pageInformation: PageInformation!, isBookmarked: Bool) {
     <#code#>
     }
     
     func pageTransitionStarted(_ rvc: ReflowableViewController?) {
     <#code#>
     }
     
     func pageTransitionEnded(_ rvc: ReflowableViewController?) {
     <#code#>
     }
     
     
     func reflowableViewController(_ rvc: ReflowableViewController?, styleForChapter chapterIndex: Int) -> String? {
     <#code#>
     }
     
     func reflowableViewController(_ rvc: ReflowableViewController?, isBookmarked pageInformation: PageInformation!) -> Bool {
     <#code#>
     }
     
     func bookmarkImage(_ rvc: ReflowableViewController?, isBookmarked: Bool) -> UIImage! {
     <#code#>
     }
     
     func bookmarkRect(_ rvc: ReflowableViewController?, isBookmarked: Bool) -> CGRect {
     <#code#>
     }
     */
    
    func reflowableViewController(_ rvc: ReflowableViewController?, failedToMove toForward: Bool) {
        //
    }
    
    // SKYEPUB SDK CALLBACK
    // called when playing a parallel starts in MediaOverlay or TTS
    // make the text of speech highlight while playing.
    func reflowableViewController(_ rvc: ReflowableViewController?, parallelDidStart parallel: Parallel?) {
        if let value = parallel {
            if rv.pageIndexInChapter() != value.pageIndex {
                rv.gotoPage(pageIndexInChapter: value.pageIndex)
            }
            if (setting.highlightTextToVoice) {
                if !rv.isTTSEnabled() {     // for MediaOverlay
                    rv.changeElementColor("#FFFF00", hash: value.hash!)
                } else {                     // for TTS
                    rv.markParallelHighlight(parallel, color: self.getMarkerColor(colorIndex: 1))
                }
            }
        }
        currentParallel = parallel
    }
    
    // SKYEPUB SDK CALLBACK
    // called when playing a parallel ends in MediaOverlay or TTS
    func reflowableViewController(_ rvc: ReflowableViewController?, parallelDidEnd parallel: Parallel?) {
        if !rv.isTTSEnabled() {
            if setting.highlightTextToVoice {
                rv.restoreElementColor()
            }
            if isLoop {
                rv.playPrevParallel()
            }
        } else {
            if setting.highlightTextToVoice {
                rv.removeParallelHighlights()
            }
        }
    }
    
    // SKYEPUB SDK CALLBACK
    // called when user touches on any area of book.
    func reflowableViewController(_ rvc: ReflowableViewController?, didDetectTapAt position: CGPoint) {
        print("Ta[ Detacted")
        if isControlsShown && menuBox.isHidden && colorBox.isHidden && highlightBox.isHidden {
            self.hideControls()
            self.hideMediaBox()
        } else {
            self.showControls()
            if (rv.isMediaOverlayAvailable() && setting.mediaOverlay) || rv.isTTSEnabled() {
                self.showMediaBox()
            }
        }
        self.hideHighlightBox()
        self.hideColorBox()
    }
    
    // SKYEPUB SDK CALLBACK???
    // called whenever new custom drawing for highlight is required.
    func reflowableViewController(_ rvc: ReflowableViewController?, drawHighlight highlightRect: CGRect, context: CGContext!, highlight highlightColor: UIColor!, highlight: Highlight!) {
        if (!highlight.isTemporary) {
            if (self.highlightDrawnOnFront()) {
                context.clear(highlightRect)
                context.setBlendMode(.overlay)
                context.setFillColor(UIColor.blue.withAlphaComponent(0.7).cgColor)
                context.fill(highlightRect)
            } else {
                let markerImage = self.getMakerImageFromColor(color: highlightColor)
                context.draw(markerImage.cgImage!, in: highlightRect)
            }
        } else {
            if (!rv.isVerticalWriting()) {
                let markerImage = getMakerImageFromColor(color: highlightColor)
                let thinkness:CGFloat = 6.0
                let bottomRect = CGRect(x:highlightRect.origin.x,y:highlightRect.origin.y+highlightRect.size.height-thinkness+2, width:highlightRect.size.width, height:thinkness)
                context.draw(markerImage.cgImage!, in: bottomRect)
            } else {
                let markerImage = self.getMakerImageFromColor(color: highlightColor)
                let thickness:CGFloat = 6.0
                let bottomRect = CGRect(x:highlightRect.origin.x,y:highlightRect.origin.y, width:thickness,height:highlightRect.size.height)
                context.draw(markerImage.cgImage!, in: bottomRect)
            }
        }
    }
    
    // SKYEPUB SDK CALLBACK
    // called when Global Pagination starts.
    func reflowableViewController(_ rvc: ReflowableViewController?, didStartPaging bookCode: Int32) {
        disableControlBeforePagination()
    }
    
    // SKYEPUB SDK CALLBACK
    // called whenever each chapter is paginated.
    // PagingInformation contains about all factors that can affect the numberOfPages of each chapter like numberOfPages, chapterIndex, the width or height of book, font and line spacing.
    func reflowableViewController(_ rvc: ReflowableViewController?, didPaging pagingInformation: PagingInformation?) {
        if let value = pagingInformation {
            //print("didPaging for \(pagingInformation.chapterIndex)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                self.processPaging(pagingInformation: value)
            }
        }
        
    }
    
    // SKYEPUB SDK CALLBACK
    // called when Global Pagination ends.
    func reflowableViewController(_ rvc: ReflowableViewController?, didFinishPaging bookCode: Int32) {
        self.enableControlAfterPagination()
    }
    
    // SKYEPUB SDK CALLBACK
    func reflowableViewController(_ rvc: ReflowableViewController?, numberOfPagesForPagingInformation pagingInformation:PagingInformation!) -> Int {
        //
        let pgi:PagingInformation! = sd.fetchPagingInformation(pagingInformation: pagingInformation)
        var nc = 0
        if pgi==nil {
            nc = 0
        } else {
            nc = pgi.numberOfPagesInChapter
        }
        return nc
    }
    
    // SKYEPUB SDK CALLBACK
    // if there's stored paging information which matches given paging information, return it to sdk to avoid repaging of the same chapter with the same conditions.
    func reflowableViewController(_ rvc: ReflowableViewController?, pagingInformationForPagingInformation pagingInformation: PagingInformation!) -> PagingInformation! {
        let pgi = sd.fetchPagingInformation(pagingInformation: pagingInformation)
        return pgi
    }
    
    // SKYEPUB SDK CALLBACK
    // returns all paging information about one book to SDK
    func reflowableViewController(_ rvc: ReflowableViewController?, anyPagingInformationsForBookCode bookCode: Int32, numberOfChapters: Int32) -> NSMutableArray! {
        return sd.fetchPagingInformationsForScan(bookCode: Int(bookCode), numberOfChapters: Int(numberOfChapters))
    }
    
    // SKYEPUB SDK CALLBACK
    // called when text inforamtion is extracted from each chapter. text information of each chapter can be stored external storage with or without encrypting.
    // and they will be used for searching, text speech, highlight or etc.
    func reflowableViewController(_ rvc: ReflowableViewController?, textExtracted bookCode: Int32, chapterIndex: Int32, text: String?) {
        let itemRef:ItemRef! = sd.fetchItemRef(bookCode: Int(bookCode), chapterIndex: Int(chapterIndex))
        if itemRef != nil {
            if !((text ?? "").isEmpty) {
                itemRef.text = text
                sd.updateItemRef(itemRef: itemRef)
            }
        } else {
            let newRef:ItemRef! = ItemRef()
            newRef.bookCode = bookCode
            newRef.chapterIndex = chapterIndex
            newRef.title = ""
            newRef.idref = ""
            newRef.href = ""
            newRef.fullPath = ""
            newRef.text = text
            sd.insertItemRef(itemRef: newRef)
        }
    }
    
    // SKYEPUB SDK CALLBACK
    // returns the text of chapter which is stored in permanent storage to SDK.
    func reflowableViewController(_ rvc: ReflowableViewController?, textForBookCode bookCode: Int32, chapterIndex: Int32) -> String! {
        //        NSLog(@"textForBookCode")
        let itemRef:ItemRef! = sd.fetchItemRef(bookCode: Int(bookCode), chapterIndex: Int(chapterIndex))
        if (itemRef == nil) {
            return nil
        }
        let ret: String! = String(itemRef.text)
        return ret
    }
    
    // SKYEPUB SDK CALLBACK
    // called when key is found while searching.
    func reflowableViewController(_ rvc: ReflowableViewController?, didSearchKey searchResult: SearchResult!) {
        self.addSearchResult(searchResult: searchResult, mode:.normal)
    }
    
    // SKYEPUB SDK CALLBACK
    // called after all searching process is over.
    func reflowableViewController(_ rvc: ReflowableViewController?, didFinishSearchAll searchResult: SearchResult!) {
        self.addSearchResult(searchResult: searchResult, mode:.finished)
    }
    
    // SKYEPUB SDK CALLBACK
    // called after searching process for one chapter is over.
    func reflowableViewController(_ rvc: ReflowableViewController?, didFinishSearchForChapter searchResult: SearchResult!) {
        rvc?.pauseSearch()
        rvc?.isSearching = false
        let cn = Int(searchResult?.numberOfSearched ?? 0) - Int(lastNumberOfSearched)
        if cn > 150 {
            self.addSearchResult(searchResult: searchResult, mode:.more)
            lastNumberOfSearched = Int(searchResult.numberOfSearched)
        } else {
            rvc?.searchMore()
        }
    }
    
    // SKYEPUB SDK CALLBACK
    // called after playing all parallels are finished in MediaOverlay or TTS.
    func parallesDidEnd(_ rvc: ReflowableViewController?) {
        rv.restoreElementColor()
        rv.stopPlayingParallel()
        self.changePlayAndPauseButton()
        isAutoPlaying = true
        if autoMoveChapterWhenParallesFinished {
            autoStartPlayingWhenNewChapterLoaded = true
            rv.gotoNextChapter()
        }
    }
    
}

