//
//  ReflowableViewController.h
//  Created by SkyTree on 11. 8. 29..
//  Copyright (c) 2011 Skytree Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

#define PAGING_NORMAL       0
#define PAGING_SCAN         1
#define PAGING_ESTIMATION   2

@class Highlight,ReflowableViewController,Book,SearchResult;
@protocol ContentProvider;


/**
 PageInfomation class contains information about a specific page of epub.
 */
@interface PageInformation :NSObject{
    /** BookCode */
    NSInteger bookCode;
    /** Code */
    NSInteger code;
    /** the index of the chapter that this page belongs to */
    NSInteger chapterIndex;
    /** the number of chapter that epub has. */
    NSInteger numberOfChaptersInBook;
    /** the page index from the start of this chapter. */
    NSInteger pageIndex;
    /** the total page number of this chapter. */
    NSInteger numberOfPagesInChapter;
    /** the title of this chapter. */
    NSString* chapterTitle;
    /** all Highlights in this page. */
    NSMutableArray *highlightsInPage;
    /** the position from the start of this chapter. */
    double pagePositionInChapter;
    /** the global postion from the start of this book. */
    double pagePositionInBook;
    /** the text in this page. */
    NSString *pageDescription;
    bool isLoadedChapter;
    /** the index of the first element in this page. */
    NSInteger startIndex;
    /** the index of the end element in this page. */
    NSInteger endIndex;
    /** the page index from the start of book */
    NSInteger pageIndexInBook;
    /** the total number of pages in book */
    NSInteger numberOfPagesInBook;
    /**  the offset of the first character in page. */
    NSInteger firstCharacterOffsetInPage;
    /** the length of text in page */
    NSInteger textLengthInPage;
    /** datatime **/
    NSString* datetime;
}

@property NSInteger code,bookCode;
@property NSInteger chapterIndex;
@property NSInteger numberOfChaptersInBook;
@property NSInteger pageIndex;
@property NSInteger numberOfPagesInChapter;
@property (nonatomic,retain) NSString* _Nullable chapterTitle;
@property (nonatomic,retain) NSMutableArray * _Nullable highlightsInPage;
@property double pagePositionInChapter;
@property double pagePositionInBook;
@property (nonatomic,retain) NSString* _Nullable pageDescription;
@property bool isLoadedChapter;
@property NSInteger startIndex,endIndex;
@property NSInteger pageIndexInBook,numberOfPagesInBook;
@property NSInteger firstCharacterOffsetInPage,textLengthInPage;
@property (nonatomic,retain) NSString* _Nullable datetime;
@end

/**
 PagingInformation class contains the information about paging for one chapter.
 */
@interface PagingInformation :NSObject {
    int code;
    /** the code of book which is loaded now */
    NSInteger bookCode;
    /** the index of chapter which is paginated now */
    NSInteger chapterIndex;
    /** the number of pages in this chapter */
    NSInteger numberOfPagesInChapter;
    /** the font name that is used for this paging. */
    NSString *fontName;
    /** the font size that is used for this paging. */
    NSInteger fontSize;
    /** the width of webView */
    int width;
    /** the height of webView */
    int hegith;
    /** the line space that is used for this paging. */
    NSInteger lineSpacing;
    /** the vertical gap ratio that is used for this paging. */
    double verticalGapRatio;
    /** the horizontal gap ratio that is used for this paging. */
    double horizontalGapRatio;
    /** denote the device was portrait or not */
    BOOL isPortrait;
    /** double paged in landscape mode */
    BOOL isDoublePagedForLandscape;
}

@property (nonatomic,retain) NSString * fontName;
@property NSInteger bookCode,chapterIndex,numberOfPagesInChapter,fontSize,lineSpacing;
@property double verticalGapRatio,horizontalGapRatio;
@property BOOL isPortrait,isDoublePagedForLandscape;
@property int code,width,height;

-(BOOL)isEqualTo:(nonnull PagingInformation*)pgi;
@end


/**
 ReflowableViewControllerDataSource is the protocol containing methods to be implemented to respond to the request from ReflowableViewController.
 */
@protocol ReflowableViewControllerDataSource <NSObject>
@optional
/** should return NSMutableArray holding highlight objects for the given chapter index. */
-(nullable NSMutableArray*)reflowableViewController:(nullable ReflowableViewController*)rvc highlightsForChapter:(NSInteger)chapterIndex;
/** called when new highlight object must be inserted. */
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc insertHighlight:(nullable Highlight*)highlight NS_SWIFT_NAME(reflowableViewController(_:didInsert:));
/** called when certain highlight should be deleted in the case like merging highlights. */
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc deleteHighlight:(nullable Highlight*)highlight NS_SWIFT_NAME(reflowableViewController(_:didDelete:));
/** should return the number of pages for specific PagingInformation in global pagination mode*/
-(NSInteger)reflowableViewController:(nullable ReflowableViewController*)rvc numberOfPagesForPagingInformation:(nullable PagingInformation*)pagingInformation NS_SWIFT_NAME(reflowableViewController(_:numberOfPagesForPagingInformation:));

// 3.5.5
/** called when certain highlight should be updated in the case like changing color */
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc updateHighlight:(nullable Highlight*)highlight NS_SWIFT_NAME(reflowableViewController(_:didUpdate:));
/** Javascript source for chapterIndex can be passed to the engine if you like to implement some custom behaviors.  */
-(nullable NSString*)reflowableViewController:(nullable ReflowableViewController*)rvc scriptForChapter:(NSInteger)chapterIndex;
/** CSS source for chapterIndex can be passed to the engine if you like to implement some custom behaviors.  */
-(nullable NSString*)reflowableViewController:(nullable ReflowableViewController*)rvc styleForChapter:(NSInteger)chapterIndex;
/** should tell the engine whether a given pagePositionInBook value is bookmarked or not */
-(BOOL)reflowableViewController:(nullable ReflowableViewController*)rvc isBookmarked:(nullable PageInformation*)pageInformation;
/** should return the bookmarked image for rendering */
-(nullable UIImage*)bookmarkImage:(nullable ReflowableViewController*)rvc isBookmarked:(BOOL)isBookmarked;
/** should return the CGRect of the bookmarked image for rendering */
-(CGRect)bookmarkRect:(nullable ReflowableViewController*)rvc isBookmarked:(BOOL)isBookmarked;

// 8.0
-(nullable PagingInformation*)reflowableViewController:(nullable ReflowableViewController*)rvc pagingInformationForPagingInformation:(nullable PagingInformation*)pagingInformation NS_SWIFT_NAME(reflowableViewController(_:pagingInformationForPagingInformation:));
-(nullable NSString*)reflowableViewController:(nullable ReflowableViewController*)rvc textForBookCode:(int)bookCode chapterIndex:(int)chapterIndex;
-(nullable NSMutableArray*)reflowableViewController:(nullable ReflowableViewController*)rvc anyPagingInformationsForBookCode:(int)bookCode numberOfChapters:(int)numberOfChapters;
-(nullable NSMutableArray*)reflowableViewController:(nullable ReflowableViewController*)rvc parallelsForTTS:(int)chapterIndex text:(nullable NSString*)text;

@end

@class Parallel;
/**
 ReflowableViewControllerDelegate is the protocol containing functions which should be implemented to handle the events from ReflowableViewController.
 */
@protocol ReflowableViewControllerDelegate <NSObject>
@optional
/** called when text selection is finished. @param highlight Highlight object @param startRect CGRect for  the first line range of selection area.  @param endRect CGRect for the last line range of selection area */
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc didSelectRange:(nullable Highlight*)highlight startRect:(CGRect)startRect endRect:(CGRect)endRect;
/** called when single tap is detected @param position CGPoint object at tap position */
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc didDetectTapAtPosition:(CGPoint)position NS_SWIFT_NAME(reflowableViewController(_:didDetectTapAt:));
/** called when double tap is detected @param position CGPoint object at double tap position */
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc didDetectDoubleTapAtPosition:(CGPoint)position NS_SWIFT_NAME(reflowableViewController(_:didDetectDoubleTapAt:));
/** called when page is moved to or chapter is loaded at first time. @param pageInformation PageInformation object of current page. */
-(void)reflowableViewController:(nonnull ReflowableViewController*)rvc pageMoved:(nonnull PageInformation*)pageInformation;
/** called when the key is found. @param searchResult SearchResult object. */
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc didSearchKey:(nullable SearchResult*)searchResult;
/** called when search process for one chapter is finished @param searchResult SearchResult object. */
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc didFinishSearchForChapter:(nullable SearchResult*)searchResult;
/** called when all search process is finihsed @param searchResult SearchResult object. */
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc didFinishSearchAll:(nullable SearchResult*)searchResult;
/** called when global pagination for all chapters is started */
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc didStartPaging:(int)bookCode;
/** called when paginating one chapter is over. */
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc didPaging:(nullable PagingInformation*)pagingInformation;
/** called when global pagination for all chapters is finished */
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc didFinishPaging:(int)bookCode;

/** called when new chapter is loaded */
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc didChapterLoad:(int)chapterIndex;

/** called when playing one parallel started */
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc parallelDidStart:(nullable Parallel*)parallel;
/** called when playing one parallel finished */
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc parallelDidEnd:(nullable Parallel*)parallel;
/** called when playing all parallels finished */
-(void)parallesDidEnd:(nullable ReflowableViewController*)rvc;
/** called before TTS is about to speak aloud and requests the text to be modified (e.g. speak differently for numbers or text inside parenthesis) */
-(nullable NSString*)reflowableViewController:(nullable ReflowableViewController*)rvc postProcessText:(nullable NSString*)rawString;

// 3.5.5
/** called when highlight is hit by tap gesture. @param highlight Highlight object hit by tap gesture. @param position CGPoint at tap position */
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc didHitHighlight:(nullable Highlight*)highlight atPosition:(CGPoint)position startRect:(CGRect)startRect endRect:(CGRect)endRect NS_SWIFT_NAME(reflowableViewController(_:didHitHighlight:at:startRect:endRect:));
// 3.6.2
/** called when link is hit by tap gesture. @param urlString the link address hit by tap */
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc didHitLink:(nullable NSString*)urlString;
/** called when image is hit by tap gesture. @param urlString the image source hit by tap */
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc didHitImage:(nullable NSString*)urlString;
// 7.2.5
/** called when video is hit by tap gesture. @param urlString the image source hit by tap */
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc didHitVideo:(nullable NSString*)urlString;
/** called when audio is hit by tap gesture. @param urlString the image source hit by tap */
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc didHitAudio:(nullable NSString*)urlString;

// 4.2.5
/** called when link for ItemRef which has linear='no' is hit by tap gesture. @param urlString the link address hit by tap */
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc didHitLinkForLinearNo:(nullable NSString*)urlString;


-(void)pageTransitionStarted:(nullable ReflowableViewController*)rvc;
-(void)pageTransitionEnded:(nullable ReflowableViewController*)rvc;
/** called when text selection is cancelled */
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc didSelectionCanceled:(nullable NSString*)lastSelectedText;
/** called when seletected text is changed */
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc didSelectionChanged:(nullable NSString*)selectedText;
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc didHitBookmark:(nullable PageInformation*)pageInformation isBookmarked:(BOOL)isBookmarked;

// 4.0
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc drawHighlightRect:(CGRect)highlightRect  context:(nullable CGContextRef)context highlightColor:(nullable UIColor*)highlightColor highlight:(nullable Highlight*)highlight;

// 6.2.0
/** called when user tries to go to the previous page at the first of book or to go to the next page at the last of book. */
-(void)reflowableViewController:(nullable ReflowableViewController*)rvc failedToMove:(BOOL)toForward;

-(void)reflowableViewController:(nullable ReflowableViewController*)rvc textExtracted:(int)bookCode chapterIndex:(int)chapterIndex text:(nullable NSString*)text;

@end


/**
 the ReflowableViewController Object
 */
@interface ReflowableViewController : UIViewController {
    /** the Book object which contains information about epub. */
    Book* book;
    /** ReflowableViewControllerDelegate to handle events from ReflowableViewController. */
    id <ReflowableViewControllerDelegate>   delegate;
    /** ReflowableViewControllerDataSource to respond to the request from ReflowableViewController. */
    id <ReflowableViewControllerDataSource> dataSource;
    /** the class for custom reader for epub. */
    id contentProviderClass;
    /** the UIView object for background under the text */
    __weak UIView *backgroundView;
    /** the customView for user interface */
    UIView* customView;
    /** contentProvider */
    id<ContentProvider> contentProvider;
}

@property int transitionType;
@property BOOL rotationLocked,isSearching;
@property (nonatomic,weak) id <ReflowableViewControllerDelegate>      _Nullable delegate;
@property (nonatomic,weak) id <ReflowableViewControllerDataSource>    _Nullable dataSource;

@property (nonatomic,weak) UIView * _Nullable backgroundView;
@property (nonatomic,retain) UIView*  _Nullable customView;
@property (nonatomic,retain) Book* _Nullable book;
@property (nonatomic,retain) MediaOverlay* _Nullable mediaOverlay;

@property int bookCode,fontSize,lineSpacing;
@property (nonatomic,setter=setFixedLayout:) BOOL isFixedLayout;

@property (nonatomic,retain) NSMutableArray * _Nonnull manifest;
@property (nonatomic,retain) NSMutableArray * _Nonnull spine;
@property (nonatomic,retain) NSMutableArray * _Nonnull spineForLinearNo;
@property (nonatomic,retain) NSMutableArray * _Nonnull guide;
@property (nonatomic,retain) NSMutableArray * _Nonnull navMap;

@property (nonatomic,copy) NSString * _Nullable version;
@property (nonatomic,copy) NSString * _Nullable baseDirectory;
@property (nonatomic,copy) NSString * _Nullable fontName;
@property (nonatomic,copy) NSString * _Nullable fileName;
@property (nonatomic,copy) NSString * _Nullable title,* _Nullable creator,* _Nullable publisher,* _Nullable subject,* _Nullable source,* _Nullable language;


/** init ReflowableView with start position in book */
-(nonnull id)initWithStartPagePositionInBook:(double)pagePositionInBook;
/** gets PageInformation at the global position in book. @param pagePositionInBook is a double between 0 to 1 to indicate the position in entile book. */
-(nullable PageInformation*)getPageInformationAtPagePositionInBook:(double)pagePositionInBook;
/** returns PageInformation at current page. */
-(nonnull PageInformation*)getPageInformation;
/**  goes to the page by global position in book. */
-(void)gotoPageByPagePositionInBook:(double)pagePositionInBook NS_SWIFT_NAME(gotoPage(pagePositionInBook:));
/**  goes to the page by global position in book with Animation effect - PageTransitionCurl mode only */
-(void)gotoPageByPagePositionInBook:(double)pagePositionInBook animated:(BOOL)animated NS_SWIFT_NAME(gotoPage(pagePositionInBook:animated:));
/**  goes to the page by the position(by pagePositionInChapter) in the chapter(by chapterIndex) */
-(void)gotoPageByPagePosition:(double)pagePositionInChapter inChapter:(int)chapterIndex NS_SWIFT_NAME(gotoPage(pagePosition:chapterIndex:));
/**  goes to the page by the element index in the chapter by chapterIndex */
-(void)gotoPageByUniqueIndex:(int)index inChapter:(int)chapterIndex NS_SWIFT_NAME(gotoPage(uniqueIndex:chapterIndex:));
/**  goes to the page by NavPoint index */
-(void)gotoPageByNavMapIndex:(int)index NS_SWIFT_NAME(gotoPage(navMapIndex:));
/**  goes to the page by Highlight object, highlight must contain chapterIndex. */
-(void)gotoPageByHighlight:(nullable Highlight*)highlight NS_SWIFT_NAME(gotoPage(highlight:));
/**  goes to the page by SearchResult Object */
-(void)gotoPageBySearchResult:(nullable SearchResult*)searchResult NS_SWIFT_NAME(gotoPage(searchResult:));

/**  changes font name and size of ReflowableViewController and reload the current chapter.*/
-(BOOL)changeFontName:(nullable NSString*)fontName fontSize:(NSInteger)fontSize;
/**  changes font name,size and lineSpacing of ReflowableViewController and reload the current chapter.*/
-(BOOL)changeFontName:(nullable NSString *)fontName fontSize:(NSInteger)fontSize lineSpacing:(NSInteger)lineSpacing;
/**  resets all font settings to default */
-(BOOL)changeFontToDefault;
/**  changes the line spacing between lines and reload. lineSpacing is the value of px. */
-(BOOL)changeLineSpacing:(NSInteger)lineSpacing;
/**  changes foreground and background color of ReflowableViewController and reload the current chapter. */
-(void)changeForegroundColor:(nullable UIColor*)foregroundColor backgroundColor:(nullable UIColor*)backgroundColor;
/** changes foreground color of ReflowableViewController and reload the current chapter. */
-(void)changeForegroundColor:(nullable UIColor*)foregroundColor;
/** changes background color of ReflowableViewController and reload the current chapter. */
-(void)changeBackgroundColor:(nullable UIColor *)backgroundColor;
/**  changes the background image For landscape with clientRect */
-(void)setBackgroundImageForLandscape:(nullable UIImage*)backgroundImage contentRect:(CGRect)rect;
/**  changes the background image For Portrait with clientRect */
-(void)setBackgroundImageForPortrait:(nullable UIImage*)backgroundImage contentRect:(CGRect)rect;
/**  set the marker image for highlight. */
-(void)setMarkerImage:(nullable UIImage*)markerImage;
/**  set current Selection to Highlight; */
-(void)makeSelectionHighlight:(nullable UIColor*)color;
/**  makes current Selection to Highlight its style note. */
-(void)makeSelectionNote:(nullable UIColor*)color;
/**  clear current Highlight at mouse position; */
-(void)deleteHightlight:(nullable Highlight*)highlight NS_SWIFT_NAME(deleteHightlight(_:));
/**  reloads current chapter & highlights */
-(BOOL)reloadData;
/**  erases all highlights and reload highlights from dataSource. */
-(void)reloadHighlights;
/**  reloads NCX file. */
-(void)reloadNCX;
/**  searches epub for the key. */
-(void)searchKey:(nullable NSString*)key;
/**  searches the key more */
-(void)searchMore;
/**  pauses searching */
-(void)pauseSearch;
/**  stops searching */
-(void)stopSearch;
/**  unselects the text selection. */
-(void)unselect;
-(void)normalizeAll;
/**  executes javascript source. */
-(nullable NSString*)executeScript:(nullable NSString*)script;
/** set vertical gap */
-(void)setVerticalGapRatio:(double)ratio;
/** set horizontal gap */
-(void)setHorizontalGapRatio:(double)ratio;
/** set double page support for landscape view */
-(void)setDoublePagedForLandscape:(BOOL)isDoublePagedForLandscape;
/** set global pagination */
-(void)setGlobalPaging:(BOOL)isGlobalPaging;

/** show indicator while loading new chapter or not. */
-(void)showIndicatorWhileLoadingChapter:(BOOL)show;
/** show indicator while paginating whole chapters or not. */
-(void)showIndicatorWhilePaging:(BOOL)show;
/** show indicator while device is rotated or not */
-(void)showIndicatorWhileRotating:(BOOL)show;
/** allow fast page transition or not */
-(void)allowPageTransitionFast:(BOOL)isFast;

/** goto the page of pageIndex in this chapter */
-(void)gotoPageInChapter:(int)pageIndex NS_SWIFT_NAME(gotoPage(pageIndexInChapter:));
/** goto the next page in this chapter */
-(void)gotoNextPageInChapter;
/** goto the prev page in this chapter */
-(void)gotoPrevPageInChapter;
/** get page count of this chapter */
-(long)pageCountInChapter;
/** get the current pageIndex in this chapter */
-(long)pageIndexInChapter;
/** goto the next chapter */
-(void)gotoPrevChapter;
/** goto the prev chapter */
-(void)gotoNextChapter;


/** returns MediaOverlay available */
-(BOOL)isMediaOverlayAvailable;
/** play the first Parallel in this page */
-(void)playFirstParallelInPage;
/** load the first Parallel in this page but let it be paused */
-(void)loadFirstParallelInPage;
/** pause playing parallel */
-(void)pausePlayingParallel;
/** stop playing parallel */
-(void)stopPlayingParallel;
/** play the parallel */
-(void)playParallel:(nullable Parallel*)parallel;
/** play the parallel at parallelIndx */
-(void)playParallelByIndex:(int)parallelIndex NS_SWIFT_NAME(playParallel(index:));
/** get the parallel at parallelIndx */
-(nullable Parallel*)getParallelByIndex:(int)parallelIndex NS_SWIFT_NAME(getParallel(index:));
/** get the count of parallels in this chapter */
-(int)parallelCountInChapter;
/** play the next parallel */
-(void)playNextParallel;
/** play the prev parallel */
-(void)playPrevParallel;
/** resume playing the paused parallel */
-(void)resumePlayingParallel;
/** tells whether playing is paused or not. */
-(BOOL)isPlayingPaused;
/** tells whether medaiOverlay started or not. */
-(BOOL)isPlayingStarted;
/** return the index of current parallel */
-(int)getCurrentParallelIndex;

/** change the color of element which has hash */
-(void)changeElementColor:(nullable NSString*)colorString hash:(nullable NSString*)hash;
/** restore the color of element lastly changed */
-(void)restoreElementColor;

-(void)debug0;
-(void)debug1;
-(void)debug2;
/** loads the chapter by index and go to the first page. */
-(void)gotoChapter:(int)chapterIndex;
/**  goes to the page by pageIndex in current chapter. */
-(void)gotoPage:(int)pageIndex;
/** set ContentProvider class */
-(void)setContentProviderClass:(nullable Class)contentProvider;
/** set ContentProvider */
-(void)setContentProvider:(nullable id<ContentProvider>)customProvider;

/** use DOM structure for highlight text. */
-(void)useDOMHighlight:(BOOL)useDOM;

// 3.5.5
/** change the color of the highlight */
-(void)changeHighlight:(nullable Highlight*)highlight color:(nullable UIColor*)color NS_SWIFT_NAME(changeHighlight(_:color:));
/** change the text for note */
-(void)changeHighlight:(nullable Highlight *)highlight note:(nullable NSString *)note NS_SWIFT_NAME(changeHighlight(_:note:));
/** change the color and note of text. */
-(void)changeHighlight:(nullable Highlight *)highlight color:(nullable UIColor*)color note:(nullable NSString *)note NS_SWIFT_NAME(changeHighlight(_:color:note:));
/** check where book is double paged or not. */
-(BOOL)isDoublePaged;
/** tells the engine to rebuild internal cache images for curl transition */
-(void)refresh;
/** tells the engine to repaint viewer */
-(void)repaint;
/** gets the start rectangle from a highlight */
-(CGRect)getStartRectFromHighlight:(nullable Highlight*)highlight;
/** gets the end rectangle from  a highlight */
-(CGRect)getEndRectFromHighlight:(nullable Highlight*)highlight;
/** return pagePositionInBook value for given page of current chapter */
-(double)getPagePositionInBook:(int)pageIndex;

/** backup current position */
-(void)backupPosition;
/** goto the position backuped */
-(void)restorePosition;

/** Hide the contents of book */
-(void)hidePages;
/** show the contents of book */
-(void)showPages;
/** tell the pages of viewer is shown or hidden */
-(BOOL)isPagesShown;

/** set license key */
-(void)setLicenseKey:(nullable NSString *)licenseKey;
/** enable system System MenuController when text is selected */
-(void)setMenuControllerEnabled:(BOOL)isEnabled;

/** convert screen coordination x to web coordination x */
-(int)toWebX:(int)vx;
/** convert web coordination x to screen coordination x */
-(int)toViewX:(int)wx;
/** convert screen coordination y to web coordination y */
-(int)toWebY:(int)vy;
/** convert web coordination y to screen coordination y */
-(int)toViewY:(int)wy;

// 3.7.1
/** ReflowablableView init with start chapter index and hashLocation. */
-(nonnull id)initWithStartChapterIndex:(int)ci hashLocation:(nullable NSString*)hashLocation;
/** goto Page with start chapter index and hashLocation. */
-(void)gotoPageByChapterIndex:(int)ci hashLocation:(nullable NSString*)hashLocation NS_SWIFT_NAME(gotoPage(chapterIndex:hashLocation:));
/** goto Page with NavPoint */
-(void)gotoPageByNavPoint:(nullable NavPoint*)navPoint NS_SWIFT_NAME(gotoPage(navPoint:));
/** ReflowablableView init with start NavPoint index */
-(nonnull id)initWithStartNavPoint:(nullable NavPoint*)np; // 5.2


// 3.8.1
/** gets the number of chapters in book */
-(int)getNumberOfChaptersInBook;
/** gets the index of the current page in book - global pagination mode only */
-(int)getPageIndexInBook;
/** gets the total number of pages in book - global pagination mode only */
-(int)getNumberOfPagesInBook;

// 3.8.2
/** set the color of blank area */
-(void)setBlankColor:(nullable UIColor*)blankColor;

// 3.9.0
/** returns whether current book is Right To Left reading or not */
-(BOOL)isRTL;

// 3.9.2
-(void)setDelayTimeForProcessContentInRecalc:(double)time;
-(void)setDelayTimeForProcessContentInRecalcPagesForRotation:(double)time;
-(void)setDelayTimeForShowWebViewInProcessContent:(double)time;
-(void)setDelayTimeForBringContentViewToFrontInShowWebView:(double)time;
-(void)setDelayTimeForMakeAndResetPageImagesInShowWebViewForPaing:(double)time;
-(void)setDelayTimeForSetPageReadyInShowWebView:(double)time;

// 4.0
/** enable custom drawing for highlight mark */
-(void)setCustomDrawHighlight:(BOOL)isCustomDraw;

// 4.2.2
/** destroy all objects in ReflowableView explicitly */
-(void)destroy;

// 4.2.6
/** enforce reading flow to "Right to Left" */
-(void)setRTL:(BOOL)isRTL;
/** get NavPoint Object by Nav Index */
-(nullable NavPoint*)getNavPoint:(int)navIndex;

// 4.6.1
/** get the cover image url */
-(nullable NSString *)getCoverURL;

// 5.0
/** returns YES when GlobalPagination is set */
-(BOOL)isGlobalPagination;
/** returns YES while Pagination is running */
-(BOOL)isPaging;
/** returns chapter index by page index when globalpagination is set */
-(int)getChapterIndexByPageIndexInBook:(int)pageIndexInBook NS_SWIFT_NAME(getChapterIndex(pageIndexInBook:));
/** returns page index in chapter by page index in book when globalpagination is set */
-(int)getPageIndexByPageIndexInBook:(int)pageIndexInBook NS_SWIFT_NAME(getPageIndex(pageIndexInBook:));
/** returns the number of pages in chapter by chapter index */
-(int)getNumberOfPagesInChapter:(int)ci NS_SWIFT_NAME(getNumberOfPagesInChapter(chapterIndex:));
/** returns pagePosition in chapter  by page index in book when globalpagination is set */
-(double)getPagePositionByPageIndexInBook:(int)pageIndexInBook NS_SWIFT_NAME(getPagePosition(pageIndexInBook:));
/** returns pagePosition in book  by page index in book when globalpagination is set */
-(double)getPagePositionInBookByPageIndexInBook:(int)pageIndexInBook NS_SWIFT_NAME(getPagePositionInBook(pageIndexInBook:));

// 5.0.8
/** set the max number of webviews */
-(void)setMaxWebViews:(int)max;

// 5.1.0
/** set GlobalOffset to YES/NO */
-(void)setGlobalOffset:(BOOL)isGlobalOffset;

// 5.1.2
/** draw Highlight on the top of epub, not under it. */
-(void)setDrawingHighlightOnFront:(BOOL)value;

// 5.2
/**  executes javascript source. */
-(nullable NSString*)executeJavascript:(nullable NSString*)script;

// 6.0
/** returns whether current book is VerticalWriting mode or not */
-(BOOL)isVerticalWriting;
/** returns whether current device is portrait or not */
-(BOOL)isPortrait;

// 6.0.8
/** return whether ScrollMode is activated or not */
-(BOOL)isScrollMode;
/** activate Scroll Mode */
-(void)setScrollModeEnable;
/** activate/deactivate Scroll Mode */
-(void)setScrollMode:(BOOL)value;
/** return pageIndexInBook by pagePositionIn Book when globalPagination is activated. */
-(int)getPageIndexInBookByPagePositionInBook:(double)pagePositionInBook NS_SWIFT_NAME(getPageIndexInBook(pagePositionInBook:));

// 6.1.3
/** keep the original background color of book if value is YES */
-(void)keepBackgroundColor:(BOOL)value;

// 6.2.7
/** set Navatation Area Ratio on both left and right side */
-(void)setNavigationAreaWidthRatio:(float)navigationAreaWidthRatio;

// 6.2.9
/** select text with startIndex, startOffset, endIndex,endOffset */
-(void)createSelectionWithStartIndex:(int)startNodeIndex withStartOffset:(int)startOffset withEndIndex:(int)endNodeIndex withEndOffset:(int)endOffset;

// 7.0.0
/** mark highlight with Highlight Object */
-(void)markHighlight:(nullable Highlight*)highlight NS_SWIFT_NAME(markHighlight(_ highlight:));
/** mark Parallel highlight with color - (TextToSpeech Only) */
-(void)markParallelHighlight:(nullable Parallel*)parallel color:(nullable UIColor*)color;
/** remove all highlights which were created for parallel. (TextToSpeech Only) */
-(void)removeParallelHighlights;



/** set TextToSpeech enabled */
-(void)setTTSEnabled:(BOOL)enabled;
/** returns whether TextToSpeech is enabled */
-(BOOL)isTTSEnabled;

/*
 Arabic (Saudi Arabia) - ar-SA
 Chinese (China) - zh-CN
 Chinese (Hong Kong SAR China) - zh-HK
 Chinese (Taiwan) - zh-TW
 Czech (Czech Republic) - cs-CZ
 Danish (Denmark) - da-DK
 Dutch (Belgium) - nl-BE
 Dutch (Netherlands) - nl-NL
 English (Australia) - en-AU
 English (Ireland) - en-IE
 English (South Africa) - en-ZA
 English (United Kingdom) - en-GB
 English (United States) - en-US
 Finnish (Finland) - fi-FI
 French (Canada) - fr-CA
 French (France) - fr-FR
 German (Germany) - de-DE
 Greek (Greece) - el-GR
 Hebrew (Israel) - he-IL
 Hindi (India) - hi-IN
 Hungarian (Hungary) - hu-HU
 Indonesian (Indonesia) - id-ID
 Italian (Italy) - it-IT
 Japanese (Japan) - ja-JP
 Korean (South Korea) - ko-KR
 Norwegian (Norway) - no-NO
 Polish (Poland) - pl-PL
 Portuguese (Brazil) - pt-BR
 Portuguese (Portugal) - pt-PT
 Romanian (Romania) - ro-RO
 Russian (Russia) - ru-RU
 Slovak (Slovakia) - sk-SK
 Spanish (Mexico) - es-MX
 Spanish (Spain) - es-ES
 Swedish (Sweden) - sv-SE
 Thai (Thailand) - th-TH
 Turkish (Turkey) - tr-TR
 */

/** set TextToSpeech language for utterance, default en-US */
-(void)setTTSLanguage:(nullable NSString*)language;
/** set the pitch of utterance */
-(void)setTTSPitch:(float)pitch;
/** set the rate of utterance */
-(void)setTTSRate:(float)rate;

-(void)setSpeechSynthesizer:(nullable id)speechSynthesizer;

/** set NavitationArea to turn page enabled or disabled when it is tapped */
-(void)setNavigationAreaEnabled:(BOOL)value;

/** modifies html content or text inside epub programatically, */
-(void)addContentModifier:(nullable NSString*)target replaceWith:(nullable NSString*)replacement forExtension:(nullable NSString*)extension;

/** enable/disable the fonts inside epub */
-(void)setBookFontEnabled:(BOOL)value;

/** enable/disable the stylesheet(.css) inside epub */
-(void)setBookStyleEnabled:(BOOL)value;

/** enable/disable the stylesheet (.css) inside epub if book is created by sigil editor */
-(void)setSigilStyleEnabled:(BOOL)value;

/** force to repaint current webview */
-(void)repaintWebView;
    
/** extend text selection to right page or left page  */
-(void)extendSelection:(BOOL)toRight;

/** if true (default), sdk will adjust the size of image, video or etc to fit the screen size. */
-(void)setAutoAdjustContent:(BOOL)adjusted;

/** if true (default), sdk turns page by swiping gesture. if false is set, swiping to turn page will be prevented when pageTransition is NONE,SLIDE (not curl) */
-(void)setSwipeEnabled:(BOOL)enabled;

/** return SDK version */
-(int)getVersion;

/** Reset and Restart Internal Server */
-(void)resetServer;

/** check Internal Server is responding */
-(BOOL)checkServer;

/** set the sdk to check and monitor the internal server running */
-(void)setAutoCheckServerEnabled:(BOOL)enabled;

/** set the sdk to start scan automatically when new book is newly opened */
-(void)setAutoStartScan:(BOOL)isAuto;

// PAGING_NORMAL       0  : not used
// PAGING_SCAN         1
// PAGING_ESTIMATION   2
// set pagingMode when globalPagination is used, default is PAGING_ESTIMATION
-(void)setPagingMode:(int)pagingMode;

// to prevent fast and continuous turning pages in curling mode, set the delaytime to re-enable user interaction after page turned.
// default value is now 0.5 second.
-(void)setDelayTimeForUserInteractionEnabled:(double)time;

// returns the NavPoint matched to current page index.
-(nullable NavPoint*)getCurrentNavPoint;

// set the scale for indicator to resize indicator.
-(void)setIndicatorScale:(double)scale;
// if true, globalPagination process will start automatically after changing the font, lineSpacing or of current chapter.
-(void)setAutoStartGlobalPaging:(BOOL)isAuto;
// get the number of chapters to process globalPagination.
-(int)getNumberOfChaptersToPaging;
// set the maximum number of webViews for scanning.
-(void)setMaxScanViews:(int)max;

// enable, disable HTML elements backgroud color
-(void)setHTMLBackgroundColorEnabled:(BOOL)value;

// return navigationAreaWidthRatio;
-(double)getNavigationAreaWidthRatio;

// return horizontal gap ration
-(double)getHorizontalGapRatio;

// return vertical gap ration
-(double)getVerticalGapRatio;

// set the margin top ration of vertiocal gap ratio, eg) if verticalGapRatio is 0.3, only 70% area will be used to display the content of book, and when marginTopRation is 0.8 , topOffset of display area will be 0.8 * 0.3 of the height of screen.
-(void)setMarginTopRatio:(double)marginTopRatio;

-(BOOL)shouldOptimizeHighlightRects;

// optimze the highlgight rects for a highlight to reduce the overlapped rects or etc.
// default value is false (not optimizise)
-(void)setHighlightRectsOptimized:(BOOL)value;

// Enable page-break property in css file if value is true;
-(void)setPageBreakIgnored:(BOOL)value;

// set delay time for activating new chapter to prevent skipping a chapter while fast and continuous tapping.
-(void)setDelayTimeForActivating:(double)time;

// set voice rate(voice speed)  for MediaOverlay. 1.0f is default, 2.0f is twice times faster than normal.
-(void)setMediaOverlayRate:(double)rate;

// set the path of epub file
// if setBookPath is used, baseDirectory and fileName are extracted automatically from bookPath.
-(void)setBookPath:(nullable NSString*)bookPath;

// return the title of chapter for given chapterIndex
-(nullable NSString*)getChapterTitle:(int)chapterIndex;


@end






