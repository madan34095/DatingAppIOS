//
//  MyImageView.m
//  TalkForest
//
//  Created by TopFlyingDragon on 5/4/16.
//  Copyright © 2016 Mangasaur Games. All rights reserved.
//

#import "MyImageView.h"

@implementation MyImageView

//---------------------------------------------------------------------------------------------------------
//                                              Touches Began
//---------------------------------------------------------------------------------------------------------
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"Image touches Began");
}
//---------------------------------------------------------------------------------------------------------
//                                              Touches Moved
//---------------------------------------------------------------------------------------------------------
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Image touches Moved");
}
//---------------------------------------------------------------------------------------------------------
//                                              Touches Ended
//---------------------------------------------------------------------------------------------------------
- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"Image touches Ended");
}

@end
