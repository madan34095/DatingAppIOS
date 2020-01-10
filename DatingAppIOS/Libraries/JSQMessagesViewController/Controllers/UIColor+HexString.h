//
//  UIColor+HexString.h
//  SNS BaseApp
//
//  Created by TopFlyingDragon on 12/20/15.
//  Copyright © 2015 TAG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIConstant.h"
@interface UIColor (HexString)

+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length;

+ (UIColor *) colorWithHexString: (NSString *) hexString;

@end
