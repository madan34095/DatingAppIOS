//
//  MediaItemCollectionViewCell.m
//  DatingAppIOS
//
//  Created by ADV on 2019/12/12.
//  Copyright © 2019 ADV. All rights reserved.
//

#import "MediaItemCollectionViewCell.h"

@implementation MediaItemCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.photoView.layer.cornerRadius = 5;
    self.photoView.clipsToBounds = YES;
}

@end
