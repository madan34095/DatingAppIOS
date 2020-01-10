//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQMessagesToolbarButtonFactory.h"

#import "UIColor+JSQMessages.h"
#import "UIImage+JSQMessages.h"
#import "NSBundle+JSQMessages.h"


@implementation JSQMessagesToolbarButtonFactory

+ (UIButton *)defaultAccessoryButtonItem
{
    UIImage *accessoryImage = [UIImage jsq_defaultAccessoryImage];
    UIImage *normalImage = [accessoryImage jsq_imageMaskedWithColor:[UIColor lightGrayColor]];
    UIImage *highlightedImage = [accessoryImage jsq_imageMaskedWithColor:[UIColor darkGrayColor]];

    UIButton *accessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, accessoryImage.size.width, 32.0f)];
    [accessoryButton setImage:accessoryImage forState:UIControlStateNormal];
    [accessoryButton setImage:accessoryImage forState:UIControlStateHighlighted];

    accessoryButton.contentMode = UIViewContentModeScaleAspectFit;
    accessoryButton.backgroundColor = [UIColor clearColor];
    accessoryButton.tintColor = [UIColor lightGrayColor];

    return accessoryButton;
}

+ (UIButton *)defaultSendButtonItem
{
    UIImage *sendImage = [UIImage jsq_defaultVoiceImage];
    //UIImage *normalImage = [sendImage jsq_imageMaskedWithColor:[UIColor lightGrayColor]];
    //UIImage *highlightedImage = [sendImage jsq_imageMaskedWithColor:[UIColor darkGrayColor]];

    UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, sendImage.size.width, 32.0f)];
    [sendButton setImage:sendImage forState:UIControlStateNormal];
    [sendButton setImage:sendImage forState:UIControlStateHighlighted];
    
    sendButton.contentMode = UIViewContentModeScaleAspectFit;
    sendButton.backgroundColor = [UIColor clearColor];
    sendButton.tintColor = [UIColor lightGrayColor];

    return sendButton;
}

@end
