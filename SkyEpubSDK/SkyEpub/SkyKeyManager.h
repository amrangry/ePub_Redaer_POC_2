//
//  SkyDRM.h
//  SkyDemo
//
//  Created by 하늘나무 on 2015. 11. 6..
//  Copyright © 2015년 Skytree Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SkyKey : NSObject {
    NSString* encryptedId;
    NSString* contentId;
    NSString* key;
}

@property (nonatomic,retain) NSString *encryptedId;
@property (nonatomic,retain) NSString *contentId;
@property (nonatomic,retain) NSString *key;

@end

@interface SkyKeyManager : NSObject {
    NSString* clientId;
    NSString* clientSecret;
    NSString* server;
    
    NSString* accessToken;
    NSMutableDictionary* keys;
}

-(id)initWithClientId:(NSString*)clientId clientSecret:(NSString*)clientSecret;
-(NSString*)getKey:(NSString*)uuidForEpub uuidForContent:(NSString*)uuidForContent;
-(NSMutableArray*)getKeys:(NSString*)uuidForEpub;

@property (nonatomic, retain) NSString* server;
@property (nonatomic, retain) NSString* clientId;
@property (nonatomic, retain) NSString* clientSecret;
@property (nonatomic, retain) NSString* accessToken;
@property (nonatomic, retain) NSMutableDictionary* keys;

@end
