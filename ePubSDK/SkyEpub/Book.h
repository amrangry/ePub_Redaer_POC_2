//
//  Book.h
//  eBook
//
//  Created by 허지웅 on 10. 5. 11..
//  Copyright 2010 Techdigm Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchResult.h"

#define SpreadAuto          0
#define SpreadLandscape     1
#define SpreadPortrait      2
#define SpreadBoth          4
#define SpreadNone          8


#define DevicePhone         0
#define DeviceTablet        1
#define DeviceDesktop       2
#define DeviceConsole       3
#define DeviceWeb           4

#define RightRead           0
#define RightExtract        1
#define RightPrint          2

#define MediaStarted        0
#define MediaPaused         1
#define Media

@class Encryption;
@class PagingInformation;

@interface Item : NSObject
{
    NSString *href;
    NSString *identifier;
    NSString *mediaType;
    NSString *mediaOverlayIdentifier;
    NSString *properties;
    BOOL hasMediaOverlay;
}

@property (nonatomic,retain) NSString *href;
@property (nonatomic,retain) NSString *identifier;
@property (nonatomic,retain) NSString *mediaType;
@property (nonatomic,retain) NSString *mediaOverlayIdentifier;
@property (nonatomic,retain) NSString *properties;
@property BOOL hasMediaOverlay;

@end

@interface ItemRef : NSObject
{
    int bookCode;
    int chapterIndex;
    NSString *idref;
    NSString *linear;
    NSString *fullPath;
    NSString *href;
    NSString *mediaOverlayPath;
    BOOL hasMediaOverlay;
    double percent;
    NSString* title;
    NSString *text;
    int scanState;
    PagingInformation* pagingInformation;
}

@property int bookCode;
@property int chapterIndex;
@property (nonatomic,retain) NSString *idref;
@property (nonatomic,retain) NSString *linear;
@property (nonatomic,retain) NSString *fullPath;
@property (nonatomic,retain) NSString *href;
@property (nonatomic,retain) NSString *mediaOverlayPath;
@property BOOL hasMediaOverlay;
@property int scanState;
@property double percent;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *text;
@property (nonatomic,retain) PagingInformation *pagingInformation;
@end

@interface Reference : NSObject
{
    NSString *href;
    NSString *type;
    NSString *title;
}

@property (nonatomic,retain) NSString *href;
@property (nonatomic,retain) NSString *type;
@property (nonatomic,retain) NSString *title;

@end

/**
 NavPoint class holds information about navPoint entry in NavMap included in ncx file of epub.
 */
@interface NavPoint : NSObject
{
    /** chapterIndex */
    int chapterIndex;
    /** hash */
    NSString *hashLocation;
    /** identifer */
    NSString *identifier;
    /** play order */
    int playOrder;
    /** description */
    NSString *text;
    /** the relative path of content file */
    NSString *content;
    NSString *originalContent;
    /** the depth of indentation */
    int depth;
}

@property (nonatomic,retain) NSString *identifier,*text,*content,*originalContent,*hashLocation; //버그픽스
@property int chapterIndex,playOrder,depth; // 버그픽스

@end


@interface PlatformOption :NSObject {
    NSString *name;
    NSString *value;
}
@property (nonatomic,retain) NSString *name,*value;
@end

@interface Platform :NSObject {
    NSString *name;
    NSMutableArray *platformOptions;
}
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSMutableArray *platformOptions;

@end

@interface DisplayOptions : NSObject {
    NSMutableArray *platforms;
}
@property (nonatomic,retain) NSMutableArray *platforms;
@end

@interface MediaOverlayObject : NSObject {
    Byte kind;
}
@property Byte kind;

@end


@interface Sequence :MediaOverlayObject {
    NSMutableArray *mos;
    NSString *identifier;
    NSString *textReference;
    NSString *type;
}
@property (nonatomic,retain) NSMutableArray *mos;
@property (nonatomic,retain) NSString* identifier;
@property (nonatomic,retain) NSString* textReference;
@property (nonatomic,retain) NSString* type;
-(void)print;
-(NSMutableArray*)getParallelsByPageIndex:(int)pageIndex;
-(NSMutableArray*)getParallels;
@end

@interface Audio :MediaOverlayObject {
    NSString *identifier;
    NSString *source;
    NSString *clipBegin;
    NSString *clipEnd;
    NSTimeInterval intervalBegin;
    NSTimeInterval intervalEnd;
    NSString *fullPath;
}
@property (nonatomic,retain) NSString* identifier;
@property (nonatomic,retain) NSString* source;
@property (nonatomic,retain) NSString* fullPath;
@property (nonatomic,retain) NSString* clipBegin;
@property (nonatomic,retain) NSString* clipEnd;
@property NSTimeInterval intervalBegin;
@property NSTimeInterval intervalEnd;
-(void)calc;
-(void)print;
@end


@interface Text :MediaOverlayObject {
    NSString *identifier;
    NSString *source;
    
    NSString* content;
    long startOffset;
    long endOffset;
}
@property (nonatomic,retain) NSString* identifier;
@property (nonatomic,retain) NSString* source;

@property (nonatomic,retain) NSString* content;
@property long startOffset;
@property long endOffset;

-(void)print;
@end

@interface Parallel:MediaOverlayObject {
    NSString* hash;
    int parallelIndex;
    int pageIndex;
    NSString *identifier;
    NSString *type;
    Audio *audio;
    Text *text;
}
@property (nonatomic,retain) NSString* identifier;
@property (nonatomic,retain) NSString* type;
@property (nonatomic,retain) Audio* audio;
@property (nonatomic,retain) Text* text;
@property (nonatomic,retain) NSString* hash;
@property int pageIndex,parallelIndex;
-(void)print;
-(id)initWithTextContent:(NSString*)textContent bookCode:(int)bookCode chapterIndex:(int)chapterIndex startOffset:(int)startOffset endOffset:(int)endOffset;
@end


@class SkyPlayer;
@protocol SkyPlayerDelegate <NSObject>
-(void)didComplete:(SkyPlayer*)skyPlayer;
@end


@class AVPlayer;
@interface SkyPlayer:NSObject {
    AVPlayer* player;
    NSURL* mediaURL;
    NSTimeInterval clipBegin,clipEnd;
    NSTimeInterval currentTime;
    double delta;
    BOOL isPaused;
    NSTimer *timer;
    double rate;
    id <SkyPlayerDelegate>delegate;
}
@property (nonatomic,retain) AVPlayer* player;
@property (nonatomic,retain) NSURL *mediaURL;
@property (nonatomic,retain) id delegate;
@property BOOL isPaused;
-(void)play:(NSURL*)url clipBegin:(NSTimeInterval)begin clipEnd:(NSTimeInterval)end;
-(void)pause;
-(void)stop;
-(void)resume;
-(void)setRate:(double)rate;
@end


@class MediaOverlay;
@protocol MediaOverlayDataSource <NSObject>
-(void)makeParallels:(NSMutableArray*)parallels forMediaOverlay:(MediaOverlay*)mediaOverlay;
-(int)pageIndexForMediaOverlay:(MediaOverlay*)mediaOverlay;
@end

@protocol MediaOverlayDelegate <NSObject>
-(void)mediaOverlay:(MediaOverlay*)mediaOverlay didStateChanged:(int)state;
-(void)mediaOverlay:(MediaOverlay*)mediaOverlay didParallelStart:(Parallel*)parallel;
-(void)mediaOverlay:(MediaOverlay*)mediaOverlay didParallelComplete:(Parallel*)parallel;
-(NSString*)mediaOverlay:(MediaOverlay*)mediaOverlay postProcessText:(NSString*)rawString;
-(void)parallelsDidComplete:(MediaOverlay*)mediaOverlay;
@end

@interface MediaOverlay:NSObject <SkyPlayerDelegate> {
    SkyPlayer* player;
    Parallel *currentParallel;
    NSMutableArray* parallels;
    int parallelIndex;
    BOOL isStarted;
    __weak id <MediaOverlayDataSource> dataSource;
    __weak id <MediaOverlayDelegate> delegate;
}
@property (nonatomic,weak) id delegate;
@property (nonatomic,weak) id dataSource;
@property (nonatomic,retain) SkyPlayer* player;
@property BOOL isStarted;

-(void)playParallel:(Parallel*)parallel;
-(void)playParallels;
-(void)playParallelByIndex:(int)pi;
-(void)playLastParallel;
-(Parallel*)getParallel:(int)pi;
-(int)parallelCount;
-(int)getCurrentParallelIndex;
-(void)playNext;
-(void)playPrev;
-(void)play;
-(void)pause;
-(BOOL)isStarted;
-(BOOL)isPaused;
-(void)clear;
-(void)reset;
-(void)stop;
-(void)resume;
-(int)getCurrentParallelIndex;
-(void)stopPlayer;
-(void)stopPlayerOnly;
-(void)setRate:(double)rate;
@end


@interface TTS:NSObject <SkyPlayerDelegate> {
    NSMutableArray* parallels;
    int parallelIndex;
    
    int bookCode;
    int chapterIndex;
    int firstCharacterOffsetInPage;
    
    NSString* text;
    
    __weak id <MediaOverlayDataSource> dataSource;
    __weak id <MediaOverlayDelegate> delegate;
}
@property (nonatomic,weak) id delegate;
@property (nonatomic,weak) id dataSource;
@property BOOL isStarted;
@property int bookCode;
@property int chapterIndex;
@property int firstCharacterOffsetInPage;
@property (nonatomic,retain) NSString* text;

-(id)initWithSynthesizer:(id)synthesizer;
-(void)setLanguage:(NSString*)language;

-(void)setPitch:(float)pitch;
-(void)setRate:(float)rate;
-(void)setText:(NSString*)text bookCode:(int)bookCode chapterIndex:(int)chapterIndex firstCharacterOffsetInPage:(int)firstCharacterOffsetInPage parallels:(NSMutableArray*)parallels;
-(void)playParallel:(Parallel*)parallel;
-(void)playParallels;
-(void)loadParallels;
-(void)playParallelByIndex:(int)pi;
-(void)playParallelsAfterOffset:(int)offset;
-(void)playLastParallel;

-(Parallel*)getParallel:(int)pi;
-(int)parallelCount;
-(int)getCurrentParallelIndex;
-(void)playNext;
-(void)playPrev;
-(void)play;
-(void)pause;
-(BOOL)isStarted;
-(BOOL)isPaused;
-(void)clear;
-(void)reset;
-(void)stop;
-(void)resume;
-(int)getCurrentParallelIndex;
-(void)stopPlayer;
@end


@interface Device:NSObject {
    int deviceId;
    BOOL isAvailable;
}
@property int deviceId;
@property BOOL isAvailable;
@end

@interface Contents:NSObject {
    BOOL displayAllChapters;
    BOOL watermarkAllChapters;
    BOOL isWatermarked;
    int  startChapterIndex;
    int  endChapterIndex;
    int  startChapterIndexForWatermark;
    int  endChapterIndexForWatermark;
    NSString* watermarkText;
}
@property BOOL displayAllChapters;
@property BOOL watermarkAllChapters;
@property BOOL isWatermarked;
@property int  startChapterIndex;
@property int  endChapterIndex;
@property int  startChapterIndexForWatermark;
@property int  endChapterIndexForWatermark;
@property (nonatomic,copy) NSString* watermarkText;
@end;

@interface Lend :NSObject {
    BOOL isLendable;
    long lendSeconds;
    NSDate *expireDate;
    NSDate *expireDateTime;
}
@property BOOL isLendable;
@property long lendSeconds;
@property (nonatomic,retain) NSDate *expireDate;
@property (nonatomic,retain) NSDate *expireDateTime;
@end;


@interface Right :NSObject {
    int rightId;
    NSMutableArray* devices;
    BOOL forAllDevices;
}
@property int rightId;
@property (nonatomic,retain) NSMutableArray* devices;
@property BOOL forAllDevices;
-(id)initWithRightId:(int)rightId;
-(Device*)getDevice:(int)deviceId;
-(BOOL)supportsAllDevices;
-(BOOL)supportsNoneDevice;
-(void)excludeAllDevices;
-(void)includeAllDevices;
@end;


@interface ReadRight :Right {
    Lend *lend;
    Contents* contents;
}
@property (nonatomic,retain) Lend *lend;
@property (nonatomic,retain) Contents *contents;
@end;

@interface PrintRight :Right {
    int countMax;
    Lend *lend;
    Contents* contents;
    int resolutionMin;
    int resolutionMax;
}
@property int resolutionMin;
@property int resolutionMax;
@property int countMax;
@property (nonatomic,retain) Lend *lend;
@property (nonatomic,retain) Contents *contents;
@end;

@interface ExtractRight :Right {
    int countMax;
    Lend *lend;
    BOOL allAvailable;
    BOOL highlightAvailable;
    BOOL noteAvailable;
    BOOL bookmarkAvailable;
    BOOL excerptAvailable;
    BOOL screenshotAvailable;
}
@property int countMax;
@property (nonatomic,retain) Lend *lend;
@property BOOL allAvailable;
@property BOOL highlightAvailable;
@property BOOL noteAvailable;
@property BOOL bookmarkAvailable;
@property BOOL excerptAvailable;
@property BOOL screenshotAvailable;
-(BOOL)supportsAllExtracts;
-(void)excludeAllExtracts;
-(void)includeAllExtracts;
@end;




@interface Rights : NSObject {
    ReadRight* readRight;
    ExtractRight* extractRight;
    PrintRight* printRight;
}
@property (nonatomic,retain) ReadRight* readRight;
@property (nonatomic,retain) ExtractRight* extractRight;
@property (nonatomic,retain) PrintRight* printRight;
@end

@interface ContentModifier : NSObject {
    NSString *target;
    NSString *replacement;
    NSString *extension;
}
@property (nonatomic,retain) NSString* target;
@property (nonatomic,retain) NSString* replacement;
@property (nonatomic,retain) NSString* extension;
@end

@interface Book  : NSObject <NSXMLParserDelegate> {
    /** book code */
    int bookCode;
    /** default font size */
    int fontSize;
    /** default font name */
    NSString *fontName;
    NSString *bookCover;
    /** fileName for epub */
    NSString *fileName;
    NSString *ePubPath;
    NSString *opfPath;
    NSString *opfDir;
    NSString *ncxPath;
    NSString *ncxName;
    NSString *imagePath;
    int parserType;
    int ncxType;
    NSMutableString *currentElementValue;
    
    /** the title of epub */
    NSString *title;
    /** the creator of epub */
    NSString *creator;
    /** the publisher of epub */
    NSString *publisher;
    /** the subject of epub */
    NSString *subject;
    /** the source of epub */
    NSString *source;
    /** the rights of epub */
    Rights *rights;
    /** the right of epub */
    NSString *right;
    /** the identifier of epub */
    NSString *identifier;
    /** the language of epub */
    NSString *language;
    /** the date of epub */
    NSString *date;
    /** the type of epub */
    NSString *type;
    /** the description of epub */
    NSString* description;
    
    NSString* stackNo;
    
    int chapterIndex;
    int readCount;
    double pagePercent;
    BOOL isRent;
    BOOL isSerial;
    BOOL isDeleted;
    NSDate* dueDate;
    NSString* downloadDate;
    NSString* lastReadDate;
    
    NSMutableArray *Manifest;
    NSMutableArray *Spine;
    NSMutableArray *SpineForLinearNo;
    NSMutableArray *Guide;
    /** Navigation Map containing NavPoint Objects */
    NSMutableArray *NavMap;
    
    NSMutableArray* ContentModifiers;
    
    NSString *currentImagePath;
    BOOL isCartoon;
    BOOL isFixedLayout;
    int fixedWidth;
    int fixedHeight;
    float fixedAspectRatio;
    
    int pTagCount;
    int imgTagCount;
    
    NSXMLParser *containerXMLParser;
    NSXMLParser *opfParser;
    NSXMLParser *ncxParser;
    NSXMLParser *chapterParser;
    NavPoint *currentNavPoint;
    
    NSString *ncxId;
    /** the default lineSpace between text lines */
    int lineSpacing;
    int depth; // 버그픽스
    
    DisplayOptions *displayOptions;
    NSString *displayOptionsXMLPath;
    NSString *baseDirectory;
    
    BOOL isRTL;
    BOOL isVerticalWriting;
    
    BOOL isPubCoder;
    BOOL isSigil;
    Item* coverItem;
    
    int spread;
    
    BOOL isEncrypted;
    Encryption* encryption;
    BOOL hasRights;
}

/** parses xml files in epub */
-(BOOL)checkServer;
-(BOOL)parseXML:(NSString*)fileName;
-(BOOL)parseChapter:(NSString*)path;
-(BOOL)parseNcx;
-(BOOL)parseOpf;
-(Sequence*)parseMediaOverlay:(ItemRef *)itemRef;
-(BOOL)parseContainerXML;
-(NSString *)getChapterTitle:(int)chapterIndex;
-(BOOL)parseOpfSampleBook;
-(BOOL)parseXMLSampleBook:(NSString *)name;
-(int)getChapterIndexByNCXIndex:(int)ni;
-(int)getChapterIndexByNavPoint:(NavPoint*)navPoint;
-(NSString*)getOriginalContentByNCXIndex:(int)ni; // 버그픽스
-(NSString *)getChapterTitle:(int)ci;
-(NSString *)getCoverURL;
-(BOOL)parseDisplayOptions;
-(void)domTest;
-(void)destroy;

@property (nonatomic,copy) NSString *fileName,*fontName;
@property (nonatomic,copy) NSString *ePubPath;
@property (nonatomic,copy) NSString *opfPath,*opfDir,*ncxPath,*ncxName,*ncxId,*imagePath;
@property int parserType;
@property (nonatomic,retain) NSMutableArray *Manifest;
@property (nonatomic,retain) NSMutableArray *Spine;
@property (nonatomic,retain) NSMutableArray *SpineForLinearNo;
@property (nonatomic,retain) NSMutableArray *Guide;
@property (nonatomic,retain) NSMutableArray *NavMap;
@property (nonatomic,retain) NSMutableArray *ContentModifiers;
@property (nonatomic,copy) NSString *currentImagePath;
@property (nonatomic,copy) NSString *title,*creator,*publisher,*subject,*source,*identifier,*language,*date,*type,*bookCover,*description;
@property (nonatomic,retain) Rights* rights;
@property (nonatomic,copy) NSString* right;
@property BOOL isCartoon,isRent,isSerial;
@property int bookCode,fontSize,chapterIndex,pTagCount,imgTagCount,readCount;
@property double pagePercent;
@property (nonatomic,retain) NSDate *dueDate;
@property (nonatomic,retain) NSString*lastReadDate;
@property (nonatomic,retain) NSString*downloadDate;
@property (nonatomic,copy) NSString* stackNo;
@property BOOL isFixedLayout,isRTL,isVerticalWriting;
@property int fixedWidth;
@property int fixedHeight;
@property float fixedAspectRatio;
@property int lineSpacing;
@property (nonatomic,retain) DisplayOptions* displayOptions;
@property (nonatomic,retain) NSString *displayOptionsXMLPath;
@property (nonatomic,retain) NSString *baseDirectory;
@property (nonatomic,retain) Item *coverItem;
@property (nonatomic,retain) Encryption *encryption;
@property int spread;
@property BOOL isPubCoder;
@property BOOL isSigil;
@property BOOL isEncrypted;
@property BOOL hasRights;


@end

