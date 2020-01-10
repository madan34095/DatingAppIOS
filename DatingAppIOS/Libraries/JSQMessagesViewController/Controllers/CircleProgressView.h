//
//  CircleProgressView.h
//  TalkForest
//
//  Created by TopFlyingDragon on 4/26/16.
//  Copyright © 2016 Mangasaur Games. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CircleProgressView;
@protocol CircleProgressViewDelegate
- (void)progressTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)progressTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)progressTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)progressTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
@end


@interface CircleProgressView : UIView

@property (nonatomic, assign) id  delegate;
@property (nonatomic) CGFloat percent;

@end
