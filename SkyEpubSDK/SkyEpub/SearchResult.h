//
//  SearchResult.h
//  skyepub
//
//  Created by 하늘나무 on 2016. 3. 8..
//  Copyright © 2016년 SkyTree. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 SearchResult class contains the information about the searched text.
 */
@interface SearchResult:NSObject {
    /** the text containing the searched key. */
    NSString *text;
    /** the name of html node that contains the searched key. */
    NSString *nodeName;
    /** the index of the element that contains the searched key. */
    int uniqueIndex;
    /** the start offset in the text which contains the searched key. */
    int startOffset;
    /** the end offset in the text which contains the searched key. */
    int endOffset;
    /** the index of chapter where the searched key is found in. */
    int chapterIndex;
    /** the title of chapter. */
    NSString *chapterTitle;
    /** the index of the page where the searched key is found in. */
    int pageIndex;
    /** the position from the start of chapter. */
    double pagePositionInChapter;
    /** the global position from the beginning of the book. */
    double pagePositionInBook;
    /** the accumulated number of the searched items. */
    int numberOfSearched;
    /** the accumulated number of the searched texts in this chapter. */
    int numberOfSearchedInChapter;
    /** the number of Pages in the chapter */
    int numberOfPagesInChapter;
    /** the number of Chapters in book */
    int numberOfChaptersInBook;
}

@property (nonatomic,retain) NSString *text;
@property (nonatomic,retain) NSString *nodeName;
@property (nonatomic,retain) NSString *chapterTitle;
@property int uniqueIndex,startOffset,endOffset,chapterIndex,pageIndex,numberOfSearched,numberOfSearchedInChapter,numberOfPagesInChapter,numberOfChaptersInBook;
@property double pagePositionInChapter,pagePositionInBook;

@end

