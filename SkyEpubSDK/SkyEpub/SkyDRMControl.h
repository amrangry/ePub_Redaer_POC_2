//
//  SkyDRMControl.h
//  skyepub
//
//  Created by 하늘나무 on 2016. 5. 18..
//  Copyright © 2016년 SkyTree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentProvider.h"

@class Book;

@interface SkyDRMControl : NSObject {
    /** the code of book */
    int bookCode;
    id contentProviderClass;
    id contentProvider;
    Book *book;
}

-(void)setContentProvider:(id<ContentProvider>)customProvider;
-(BOOL)openFile:(NSString*)bookName baseDirectory:(NSString*)baseDirectory;
-(void)closeFile;
-(BOOL)hasSingleFile;
-(int)getNumberOfFiles;
-(NSString*)getURL:(int)index;
-(NSString*)getURL;
-(NSString*)getBaseURL;

@property (nonatomic,retain) id contentProviderClass;
@property (nonatomic,retain) id contentProvider;
@property (nonatomic,retain) Book* book;


@end
