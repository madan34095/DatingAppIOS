//
//  MediaButtonMenuView.h
//  TalkForest
//
//  Created by TopFlyingDragon on 4/26/16.
//  Copyright © 2016 Mangasaur Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "MediaItemCollectionViewCell.h"

// declare our class
@class MediaButtonMenuView;

@protocol MediaButtonMenuViewDelegate
-(void)bottomMenuItemClicked:(MediaButtonMenuView *)buttonMenu imgData:(UIImage *)imgData;
@end

@interface MediaButtonMenuView : UIView

@property (nonatomic, assign) id  delegate;
@property (strong) PHCachingImageManager* imageManager;
@property (strong, nonatomic) IBOutlet UIView *mView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

-(void)initWithDelegate:(id)del;

@end
