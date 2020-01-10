//
//  CircleProgressView.m
//  TalkForest
//
//  Created by TopFlyingDragon on 4/26/16.
//  Copyright © 2016 Mangasaur Games. All rights reserved.
//

#import "CircleProgressView.h"
#import "UIColor+HexString.h"

#define PI          3.1415926535f
#define LINE_WIDTH  5.0f

@implementation CircleProgressView

@synthesize percent;
@synthesize delegate;
//------------------------------------------------------------------------------------------------------------------------
//                                      Set Percent value
//------------------------------------------------------------------------------------------------------------------------
- (void)setPercent:(CGFloat)new_percent
{
    percent = new_percent;
    [self setNeedsDisplay];
}
//------------------------------------------------------------------------------------------------------------------------
//                                      Draw Rect
//------------------------------------------------------------------------------------------------------------------------
- (void)drawRect:(CGRect)rect
{
    UIBezierPath* circle = [UIBezierPath bezierPath];
    
    CGFloat startAngle = PI * 1.5f;
    CGFloat radius = self.frame.size.width / 2 - LINE_WIDTH;
    
    // Create our arc, with the correct angles
    [circle addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                          radius:radius
                      startAngle:startAngle
                        endAngle:startAngle + (2 * PI)
                       clockwise:YES];
    
    // Set the display for the path, and stroke it
    circle.lineWidth = LINE_WIDTH;
    [[UIColor colorWithHexString:@"#CFCFCF"] setStroke];
    [circle stroke];
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    startAngle = PI * 1.5f;
    // Create our arc, with the correct angles
    [bezierPath addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                          radius:radius
                      startAngle:startAngle
                        endAngle:startAngle + (2 * PI) * (percent)
                       clockwise:YES];
    
    // Set the display for the path, and stroke it
    bezierPath.lineWidth = LINE_WIDTH;
    [[UIColor colorWithHexString:@"#5785E4"] setStroke];
    [bezierPath stroke];
}
//------------------------------------------------------------------------------------------------------------------------
//                                      Touches Begin
//------------------------------------------------------------------------------------------------------------------------
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if(delegate!=nil){
        [delegate progressTouchesBegan:touches withEvent:event];
    }
}
//------------------------------------------------------------------------------------------------------------------------
//                                      Touches Moved
//------------------------------------------------------------------------------------------------------------------------
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if(delegate!=nil){
        [delegate progressTouchesMoved:touches withEvent:event];
    }
}
//------------------------------------------------------------------------------------------------------------------------
//                                      Touches Ended
//------------------------------------------------------------------------------------------------------------------------
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if(delegate!=nil){
        [delegate progressTouchesEnded:touches withEvent:event];
    }
}
//------------------------------------------------------------------------------------------------------------------------
//                                      Touches Cancelled
//------------------------------------------------------------------------------------------------------------------------
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    if(delegate!=nil){
        [delegate progressTouchesCancelled:touches withEvent:event];
    }
}

@end
