//
//  SpeechSynthesizer_h
//  skyepub
//
//  Created by 하늘나무 on 2018. 6. 20..
//  Copyright © 2018년 SkyTree. All rights reserved.
//

#ifndef SpeechSynthesizer_h
#define SpeechSynthesizer_h

#import <AVFoundation/AVFoundation.h>

@interface SkyUtterance: AVSpeechUtterance {
    NSString* identifier;
    Parallel* parallel;
}
@property (nonatomic,retain) NSString *identifier;
@property (nonatomic,retain) Parallel *parallel;
@end;

@protocol SpeechSynthesizer
@required
-(void)speak:(SkyUtterance*)utterance;
-(void)resume;
-(void)pause;
-(void)stop;
-(BOOL)isSpeaking;
-(BOOL)isPaused;
@end

@protocol SpeechSynthesizerDelegate <NSObject>
@optional
-(void)speechSynthesizer:(id)ss didFinishSpeechUtterance:(SkyUtterance*)utterance;
@end


#endif /* SpeechSynthesizer_h */
