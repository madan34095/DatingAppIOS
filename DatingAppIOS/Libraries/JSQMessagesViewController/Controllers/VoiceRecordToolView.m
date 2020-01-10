//
//  VoiceRecordToolView.m
//  TalkForest
//
//  Created by TopFlyingDragon on 4/26/16.
//  Copyright © 2016 Mangasaur Games. All rights reserved.
//

#import "VoiceRecordToolView.h"
#import "UIConstant.h"
#include <sys/time.h>
#include "UIColor+HexString.h"

#define CHECK_INTERVAL  0.01f
#define RECORD_LIMIT    10.0f

@implementation VoiceRecordToolView
{
    AVAudioRecorder *_audioRecorder;
    NSString *_recordingFilePath;
    AVAudioPlayer *_audioPlayer;
    
    double recordStartTime;
    double recordTime;
    double playStartTime;
    
    
    BOOL isRecording;
    BOOL hasRecorded;
    BOOL isPlaying;
    
    //Private variables
    NSString *_oldSessionCategory;
}

@synthesize delegate;

//------------------------------------------------------------------------------------------------------------------------
//                                      Init With Coder
//------------------------------------------------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if( self ) {
        [[NSBundle mainBundle] loadNibNamed:@"VoiceRecordToolView" owner:self options:nil];
        [self addSubview:self.mView];
        [self initialize];
    }
    return self;
}
//------------------------------------------------------------------------------------------------------------------------
//                                      Init With Frame
//------------------------------------------------------------------------------------------------------------------------
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if( self ) {
        [[NSBundle mainBundle] loadNibNamed:@"VoiceRecordToolView" owner:self options:nil];
        CGRect rect = frame;
        rect.origin.x = 0;
        rect.origin.y = 0;
        self.mView.frame = rect;
        [self addSubview:self.mView];
        [self initialize];
    }
    return self;
}
//------------------------------------------------------------------------------------------------------------------------
//                                      Initialize
//------------------------------------------------------------------------------------------------------------------------
- (void)initialize
{
    self.cancelButton.hidden = YES;
    self.sendButton.hidden = YES;
    self.progressView.delegate = self;
    handle_tap(self.cancelButton, @selector(cancelButtonClicked));
    handle_tap(self.sendButton, @selector(sendButtonClicked));
    
    NSString *fileName = [[NSProcessInfo processInfo] globallyUniqueString];
    _recordingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a",fileName]];
    // Define the recorder setting
    {
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
        
        // Initiate and prepare the recorder
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:_recordingFilePath] settings:recordSetting error:nil];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;
    }
}
//------------------------------------------------------------------------------------------------------------------------
//                                      Record/Play Button Clicked
//------------------------------------------------------------------------------------------------------------------------
- (void)cancelButtonClicked
{
    hasRecorded = NO;
    isRecording = NO;
    isPlaying = NO;
    
    [self stopPlay];
    
    [self.centerImage setImage:[UIImage imageNamed:@"icon_voice"]];
    self.progressView.percent = 0;
    [self.timeText setText:[self getTimeString:@"残り " seconds:(RECORD_LIMIT)]];
    [self.timeText setTextColor:[UIColor colorWithHexString:@"#000000"]];
    
    self.cancelButton.hidden = YES;
    self.sendButton.hidden = YES;
}
//------------------------------------------------------------------------------------------------------------------------
//                                      Record/Play Button Clicked
//------------------------------------------------------------------------------------------------------------------------
- (void)sendButtonClicked
{
    if (hasRecorded==NO) return;
    
    if(delegate != nil){
        [delegate audioRecordFinished:_recordingFilePath];
    }
    [self cancelButtonClicked];
}
//------------------------------------------------------------------------------------------------------------------------
//                                      ProgressTouches Begin
//------------------------------------------------------------------------------------------------------------------------
- (void)progressTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if(hasRecorded==NO){
        [self startRecording];
    }else{
        [self startPlay];
    }
}
//------------------------------------------------------------------------------------------------------------------------
//                                      ProgressTouches Ended
//------------------------------------------------------------------------------------------------------------------------
- (void)progressTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if(isRecording==YES){
        [self stopRecording];
    }else if(isPlaying==YES){
        //[self stopPlay];
    }
}
//------------------------------------------------------------------------------------------------------------------------
//                                      Check Recording Time
//------------------------------------------------------------------------------------------------------------------------
- (void)startRecording
{
    isRecording = YES;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:_recordingFilePath]){
        [[NSFileManager defaultManager] removeItemAtPath:_recordingFilePath error:nil];
    }
    _oldSessionCategory = [[AVAudioSession sharedInstance] category];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
    [_audioRecorder prepareToRecord];
    [_audioRecorder record];
    
    recordTime = 0;
    recordStartTime = [self currentTimeSeconds];
    [self checkRecordingTime];
}

- (void)stopRecording
{
    isRecording = NO;
    hasRecorded = YES;
    [self.centerImage setImage:[UIImage imageNamed:@"btn_voice_play"]];
    [self.timeText setText:[self getTimeString:@"" seconds:(recordTime)]];
    [self.timeText setTextColor:[UIColor colorWithHexString:@"#5785E4"]];
    self.cancelButton.hidden = NO;
    self.sendButton.hidden = NO;
    
    [[AVAudioSession sharedInstance] setCategory:_oldSessionCategory error:nil];
    [_audioRecorder stop];
}

- (void)checkRecordingTime
{
    if(isRecording){
        recordTime = [self currentTimeSeconds] - recordStartTime;
        if(recordTime < RECORD_LIMIT){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [NSThread sleepForTimeInterval:CHECK_INTERVAL];
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [self checkRecordingTime];
                });
            });
        }else{
            recordTime = RECORD_LIMIT;
            [self stopRecording];
        }
        self.progressView.percent = recordTime / RECORD_LIMIT;
        [self.timeText setText:[self getTimeString:@"残り " seconds:(RECORD_LIMIT-recordTime)]];
    }
}//------------------------------------------------------------------------------------------------------------------------
//                                      Check Play Time
//------------------------------------------------------------------------------------------------------------------------
- (void)startPlay
{
    isPlaying = YES;
    
    _oldSessionCategory = [[AVAudioSession sharedInstance] category];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:_recordingFilePath] error:nil];
    _audioPlayer.delegate = self;
    _audioPlayer.meteringEnabled = YES;
    [_audioPlayer prepareToPlay];
    [_audioPlayer play];
    
    playStartTime = [self currentTimeSeconds];
    [self checkPlayTime];
}

- (void)stopPlay
{
    isPlaying = NO;
    if(_audioPlayer!=nil){
        _audioPlayer.delegate = nil;
        [_audioPlayer stop];
        _audioPlayer = nil;
    }
    
    [[AVAudioSession sharedInstance] setCategory:_oldSessionCategory error:nil];
}

- (void)checkPlayTime
{
    if(isPlaying){
        double playTime = [self currentTimeSeconds] - playStartTime;
        if(playTime < recordTime){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [NSThread sleepForTimeInterval:CHECK_INTERVAL];
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [self checkPlayTime];
                });
            });
        }else{
            playTime = recordTime;
            [self stopPlay];
        }
        self.progressView.percent = playTime / RECORD_LIMIT;
        [self.timeText setText:[self getTimeString:@"" seconds:playTime]];
    }
}
//------------------------------------------------------------------------------------------------------------------------
//                                      ProgressTouches Cancelled
//------------------------------------------------------------------------------------------------------------------------
- (void)progressTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.centerImage setImage:[UIImage imageNamed:@"icon_voice"]];
}
//------------------------------------------------------------------------------------------------------------------------
//                                      ProgressTouches Moved
//------------------------------------------------------------------------------------------------------------------------
- (void)progressTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
}

#pragma mark - AVAudioPlayerDelegate
/*
 Occurs when the audio player instance completes playback
 */
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
}
#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
}
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
}

- (double)currentTimeSeconds{
    struct timeval tv;
    gettimeofday(&tv,NULL);
    double perciseTimeStamp = tv.tv_sec + tv.tv_usec * 0.000001;
    
    return perciseTimeStamp;
}
- (NSString *)getTimeString:(NSString *)prefix seconds:(double) seconds{
    int s = (int)seconds;
    int ms = (int)(seconds*100)-s*100;
    return [NSString stringWithFormat:@"%@%02li:%02li",prefix, (long)s,(long)ms];
}
@end
