//
//  FixedViewController.h
//  CoreTest
//
//  Created by SkyTree on 11. 10. 19..
//  Copyright (c) 2011 Skytree Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

#define SpreadAuto          0
#define SpreadLandscape     1
#define SpreadPortrait      2
#define SpreadBoth          4
#define SpreadNone          8

@class FixedViewController, Book, Parallel,WebFrame,SearchResult;
@class Highlight;
@protocol ContentProvider;

/**
 FixedPageInfomation class contains information about a specific page of fixed layout epub.
*/
@interface FixedPageInformation :NSObject{
    /** bookCode */
    NSInteger bookCode;
    /** the page index */
    NSInteger pageIndex;
    /** the number of pages for this book */
    NSInteger numberOfPages;
    /** pagePosition as double (0.0f is the start point and 1.0f is the end point of book) */
    double pagePosition;
    /** the cached file path for this page. */
    NSString *cachedImagePath;
}

@property NSInteger bookCode;
@property NSInteger pageIndex;
@property NSInteger numberOfPages;
@property double pagePosition;
@property (nonatomic,retain) NSString * _Nullable cachedImagePath;

@end

@protocol FixedViewControllerDataSource <NSObject>
@optional
/** Javascript source for pageIndex can be passed to the engine if you like to implement some custom behaviors.  */
-(nullable NSString*)fixedViewController:(nullable FixedViewController*)fvc scriptForPage:(NSInteger)pageIndex;
/** CSS source for pageIndex can be passed to the engine if you like to implement some custom behaviors.  */
-(nullable NSString*)fixedViewController:(nullable FixedViewController*)fvc styleForPage:(NSInteger)pageIndex;
/** if cache file exists for pageIndex, you have to return YES or return NO */
-(BOOL)fixedViewController:(nullable FixedViewController*)fvc cacheExists:(int)pageIndex;

/** should return NSMutableArray holding highlight objects for the given chapter index. */
-(nullable NSMutableArray*)fixedViewController:(nullable FixedViewController*)fvc highlightsForChapter:(NSInteger)chapterIndex;
/** called when new highlight object must be inserted. */
-(void)fixedViewController:(nullable FixedViewController*)fvc insertHighlight:(nullable Highlight*)highlight NS_SWIFT_NAME(fixedViewController(_:didInsert:));
/** called when certain highlight should be deleted in the case like merging highlights. */
-(void)fixedViewController:(nullable FixedViewController*)fvc deleteHighlight:(nullable Highlight*)highlight NS_SWIFT_NAME(fixedViewController(_:didDelete:));
/** called when certain highlight should be updated in the case like changing color */
-(void)fixedViewController:(nullable FixedViewController*)fvc updateHighlight:(nullable Highlight*)highlight NS_SWIFT_NAME(fixedViewController(_:didUpdate:));


@end

@class ImageIndexed;

/** the FixedViewControllerDelegate object */
@protocol FixedViewControllerDelegate <NSObject>
@optional
/** called when single tap is detected @param position CGPoint object at tap position */
-(void)fixedViewController:(nullable FixedViewController*)fvc didDetectTapAtPositionInView:(CGPoint)positionInView positionInPage:(CGPoint)positionInPage NS_SWIFT_NAME(fixedViewController(_:didDetectTapAt:positionInPage:));
/** called when double tap is detected @param position CGPoint object at double tap position */
-(void)fixedViewController:(nullable FixedViewController*)fvc didDetectDoubleTapAtPositionInView:(CGPoint)positionInView positionInPage:(CGPoint)positionInPage NS_SWIFT_NAME(fixedViewController(_:didDetectDoubleTapAt:positionInPage:));

/** called when page is moved to or chapter is loaded at first time. @param pageInformation PageInformation object of current page. */
-(void)fixedViewController:(nullable FixedViewController*)fvc pageMoved:(nullable FixedPageInformation*)fixedPageInformation;

/** called when caching process for pages is started. @param index int the start index where caching process is started */
-(void)fixedViewController:(nullable FixedViewController*)fvc cachingStarted:(int)index;
/** called when caching process for pages is finished @param index int the start index where caching process is finished **/
-(void)fixedViewController:(nullable FixedViewController*)fvc cachingFinished:(int)index;
/** called when caching for one page is over. @param index the page index which is cached now. @param path the path of cached file. */
-(void)fixedViewController:(nullable FixedViewController*)fvc cached:(int)index image:(nullable UIImage*)image;

-(void)fixedViewController:(nullable FixedViewController*)fvc cached:(int)index path:(nullable NSString*)path;

/** called when playing one parallel started */
-(void)fixedViewController:(nullable FixedViewController*)fvc parallelDidStart:(nullable Parallel*)parallel;
/** called when playing one parallel finished */
-(void)fixedViewController:(nullable FixedViewController*)fvc parallelDidEnd:(nullable Parallel*)parallel;
/** called when playing all parallels finished */
-(void)parallesDidEnd:(nullable FixedViewController*)fvc;

/** called when the key is found. @param searchResult SearchResult object. */
-(void)fixedViewController:(nullable FixedViewController*)fvc didSearchKey:(nullable SearchResult*)searchResult;
/** called when search process for one chapter is finished @param searchResult SearchResult object. */
-(void)fixedViewController:(nullable FixedViewController*)fvc didFinishSearchForChapter:(nullable SearchResult*)searchResult;
/** called when all search process is finihsed @param searchResult SearchResult object. */
-(void)fixedViewController:(nullable FixedViewController*)fvc didFinishSearchAll:(nullable SearchResult*)searchResult;

/** called when user tries to go to the previous page at the first of book or to go to the next page at the last of book. */
-(void)fixedViewController:(nullable FixedViewController*)fvc failedToMove:(BOOL)toForward;



/** called when text selection is finished. @param highlight Highlight object @param startRect CGRect for  the first line range of selection area.  @param endRect CGRect for the last line range of selection area */
-(void)fixedViewController:(nullable FixedViewController*)fvc didSelectRange:(nullable Highlight*)highlight menuRect:(CGRect)menuRect;

/** called when highlight is hit by tap gesture. @param highlight Highlight object hit by tap gesture. @param position CGPoint at tap position */
-(void)fixedViewController:(nullable FixedViewController*)fvc didHitHighlight:(nullable Highlight*)highlight atPosition:(CGPoint)position NS_SWIFT_NAME(fixedViewController(_:didHitHighlight:at:));

/** called when link is hit by tap gesture. @param urlString the link address hit by tap */
-(void)fixedViewController:(nullable FixedViewController*)fvc didHitLink:(nullable NSString*)urlString;

@end

/** the FixedViewController Object */
@interface FixedViewController : UIViewController {
    /** the Book object which contains information about epub. */
    Book* book;
    /** FixedViewControllerDelegate to handle events from FixedViewController. */
    __weak id <FixedViewControllerDelegate>   delegate;
    /** FixedViewControllerDataSource to respond to the request from FixedViewController. */
    __weak id <FixedViewControllerDataSource> dataSource;
    /** the class for custom reader for epub. */
    id contentProviderClass;
    /** contentProvider */
    id<ContentProvider> contentProvider;
}

@property int bookCode;
@property int transitionType;
@property (nonatomic,retain) Book*  _Nonnull book;
@property (nonatomic,weak) id <FixedViewControllerDelegate>      _Nullable delegate;
@property (nonatomic,weak) id <FixedViewControllerDataSource>    _Nullable dataSource;

@property (nonatomic,retain) NSMutableArray * _Nonnull manifest;
@property (nonatomic,retain) NSMutableArray * _Nonnull spine;
@property (nonatomic,retain) NSMutableArray * _Nonnull spineForLinearNo;
@property (nonatomic,retain) NSMutableArray * _Nonnull guide;
@property (nonatomic,retain) NSMutableArray * _Nonnull navMap;

@property (nonatomic,setter=setFixedLayout:) BOOL isFixedLayout;
@property (nonatomic,readonly) BOOL isRTL;
@property (nonatomic) double fixedWidth,fixedHeight;

@property (nonatomic,copy) NSString * _Nullable version;
@property (nonatomic,copy) NSString * _Nullable baseDirectory;
@property (nonatomic,weak) NSString * _Nullable encryptKey;
@property (nonatomic,copy) NSString * _Nullable fileName;
@property (nonatomic,copy) NSString * _Nullable title,* _Nullable creator,* _Nullable publisher,* _Nullable subject,* _Nullable source,* _Nullable language;

/** intenal test only, do not use */
-(void)debug0;
-(void)debug1;
-(void)debug2;
-(void)debug3;


/** init with Start pageIndex
 @param startPageIndex is integer value to indicate the index of start page.
*/
-(nullable id)initWithStartPageIndex:(int)startPageIndex;
/** init with Start pageIndex
 @param startPageIndex  the integer value to indicate the index of start page.
 @param spread  rendition spread in opf (eg. SpreadNone, SpreadAuto, SpreadPortrait, SpreadLandscape, SpreadeBoth)
 */
-(nullable id)initWithStartPageIndex:(int)pageIndex spread:(int)spreadType;
/** init with Start position
 @param start   the double value to indicate the position of start page. (eg. 0.0f~1.0f)
 @param spread  rendition spread in opf (eg. SpreadNone, SpreadAuto, SpreadPortrait, SpreadLandscape, SpreadeBoth)
 */
-(nullable id)initWithStartPosition:(double)startPosition spread:(int)spreadType;


/** gets FixedPageInformation at the global position in book. @param pagePositionInBook is a double between 0 to 1 to indicate the position in entile book. */
-(nullable FixedPageInformation*)getFixedPageInformationAtPagePosition:(double)pagePosition;
/** gets FixedPageInformation at the given page index. @param pageIndex the page index */
-(nullable FixedPageInformation*)getFixedPageInformationAtPageIndex:(int)pageIndex;
/** returns PageInformation at current page. */
-(nullable FixedPageInformation*)getFixedPageInformation;
/**  goes to the page by the position(by pagePositionInChapter) in this book */
-(void)gotoPageByPagePosition:(double)pagePosition NS_SWIFT_NAME(gotoPage(pagePosition:));
/** change the background color for each page */
-(void)changeBackgroundColor:(nullable UIColor*)backgroundColor;
/** change the window color */
-(void)changeWindowColor:(nullable UIColor*)windowColor;
/**  goes to the page by NavPoint index */
-(void)gotoPageByNavMapIndex:(int)index NS_SWIFT_NAME(gotoPage(navMapIndex:));
/** delete all cached files in device */
-(void)clearCached;
/** set ContentProvider class */
-(void)setContentProviderClass:(nullable Class)contentProvider;
/** set ContentProvider */
-(void)setContentProvider:(nullable id<ContentProvider>)customProvider;
/** tells device can be rotate or not while caching process is going on. */
-(BOOL)canRotate;


/** goto the page of pageIndex in this chapter */
-(void)gotoPage:(int)pageIndex;
/** goto the next page in this chapter */
-(void)gotoNextPage;
/** goto the prev page in this chapter */
-(void)gotoPrevPage;
/** get page count of this book */
-(int)pageCountInBook;
/** get the current pageIndex in this chapter */
-(int)currentPageIndex;

/** change the color of element which has hash */
-(void)changeElementColor:(nullable NSString*)colorString hash:(nullable NSString*)hash pageIndex:(int)pageIndex;
/** restore the color of element lastly changed */
-(void)restoreElementColor;

/** returns MediaOverlay available */
-(BOOL)isMediaOverlayAvailable;
/** play the first Parallel in this page */
-(void)playFirstParallel;
/** pause playing parallel */
-(void)pausePlayingParallel;
/** stop playing parallel */
-(void)stopPlayingParallel;
/** play the parallel */
-(void)playParallel:(nullable Parallel*)parallel;
/** play the parallel at parallelIndx */
-(void)playParallelByIndex:(int)parallelIndex;
/** get the parallel at parallelIndx */
-(nullable Parallel*)getParallelByIndex:(int)parallelIndex;
/** get the count of parallels in this chapter */
-(int)parallelCount;
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

/** set license key */
-(void)setLicenseKey:(nullable NSString *)licenseKey;

/** set the delay time for rendering */
-(void)setTimeForRendering:(double)seconds;
/** set the delay time for caching page image  */
-(void)setTimeForCaching:(double)seconds;
/** delete all cached images */
-(void)deleteAllCaches;

/** release all resources explicitly */
-(void)destroy;

/** for landscape mode, set the image which should be located between two pages */
-(void)setPagesCenterImage:(nullable UIImage*)pagesCenterImage;
/** set the image which is used for resembling the stack of pages on both side of book. */
-(void)setPagesStackImage:(nullable UIImage*)pagesStackImage;

/** enable/disable navigation area on both sides */
-(void)setNavigationAreaEnabled:(BOOL)enabled;

/** get the cover image url */
-(nullable NSString*)getCoverURL;

/** start caching process */
-(void)startCaching;
/** stop caching process */
-(void)stopCaching;

/** execute Javascript for left page (when forLeft = YES) or for right page (forLeft = NO). in single page mode (portrait), forLeft should be YES. */
-(nullable NSString*)executeJavascript:(nullable NSString*)script forLeftPage:(BOOL)forLeft;
/**  execute Javascript only for left Page. use this in portrait mode. */
-(nullable NSString*)executeJavascript:(nullable NSString*)script;

/** use only one layer to render. caching adjacent pages will be disabled. */
-(void)useSingleLayer;

/** To avoid conflict with Drag/Drop behavior, enable/disable Swipe Gesture to move Page. default YES, only for Slide/None transition mode */
-(void)setSwipeGestureEnabled:(BOOL)enabled;

/** returns the device ram size */
-(int)platformMemory;
/** returns the model name of device */
-(nullable NSString *)platformString;

/** add Menu Item to iOS System MenuController */
-(void)addMenuItemForSelection:(nullable NSObject*)target title:(nullable NSString*)title selector:(nullable SEL)selector;

/**  set current Selection to Highlight; */
-(void)makeSelectionHighlight:(nullable UIColor*)color;
/**  makes current Selection to Highlight its style note. */
-(void)makeSelectionNote:(nullable UIColor*)color;
/**  clear current Highlight at mouse position; */
-(void)deleteHighlight:(nullable Highlight*)highlight NS_SWIFT_NAME(deleteHightlight(_:));
/** change the color of the highlight */
-(void)changeHighlight:(nullable Highlight*)highlight color:(nullable UIColor*)color NS_SWIFT_NAME(changeHighlight(_:color:));
/** change the text for note */
-(void)changeHighlight:(nullable Highlight *)highlight note:(nullable NSString *)note NS_SWIFT_NAME(changeHighlight(_:note:));
/** change the color and note of text. */
-(void)changeHighlight:(nullable Highlight *)highlight color:(nullable UIColor*)color note:(nullable NSString *)note NS_SWIFT_NAME(changeHighlight(_:color:note:));

/**  searches epub for the key. */
-(void)searchKey:(nullable NSString*)key;
/**  searches the key more */
-(void)searchMore;
/**  pauses searching */
-(void)pauseSearch;
/**  stops searching */
-(void)stopSearch;


/** return YES when spread is both or auto in landscape mode.  */
-(BOOL)isDoublePaged;

/** return NavPoint at naveIndex */
-(nullable NavPoint*)getNavPoint:(int)navIndex;

/** goto Page by NavPoint */
-(void)gotoPageByNavPoint:(nullable NavPoint*)np NS_SWIFT_NAME(gotoPage(napPoint:));

/** if value is true, page will be fit to Height. otherwise page will be fit to Width */
-(void)setFitToHeight:(BOOL)value;

/** set MaxLayer to pre load another pages */
-(void)setMaxLayer:(int)max;

/** set Page Scale Factor (0.1f~1.0f : 1.0f default)  - if pageScaleFactor is set under 1.0f, memory to allocate each page will be reduced to avoid memory exception. it is useful when each page has very long width or height */
-(void)setPageScaleFactor:(double)scaleFactor;

/** force to repaint webview when rendering has problem */
-(void)repaintWebView;

/** set the speed rate of MediaOverlay */
-(void)setMediaOverlayRate:(double)rate;

/** gotoPage by SearchResult */
-(void)gotoPageBySearchResult:(nullable SearchResult*)searchResult NS_SWIFT_NAME(gotoPage(searchResult:));

/** returns current zoomScale */
-(double)zoomScale;

// set the path of epub book.  since 8.5.0
-(void)setBookPath:(nullable NSString*)bookPath;

// get the title of chapter for given chapterIndex
-(nullable NSString*)getChapterTitle:(int)chapterIndex;


@end





