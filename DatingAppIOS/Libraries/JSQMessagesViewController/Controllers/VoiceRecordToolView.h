//
//  VoiceRecordToolView.h
//  TalkForest
//
//  Created by TopFlyingDragon on 4/26/16.
//  Copyright © 2016 Mangasaur Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CircleProgressView.h"

@class VoiceRecordToolView;
@protocol VoiceRecordToolViewDelegate
-(void)audioRecordFinished:(NSString *)path;
@end

@interface VoiceRecordToolView : UIView<CircleProgressViewDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (nonatomic, assign) id  delegate;

@property (strong, nonatomic) IBOutlet UIView *mView;
@property (weak, nonatomic) IBOutlet UIImageView *centerImage;
@property (weak, nonatomic) IBOutlet CircleProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UILabel *timeText;

@end
