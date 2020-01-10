//
//  TestView.m
//  TalkForest
//
//  Created by TopFlyingDragon on 4/26/16.
//  Copyright © 2016 Mangasaur Games. All rights reserved.
//

#import "MediaButtonMenuView.h"

@implementation MediaButtonMenuView
@synthesize delegate;
@synthesize collectionView;

PHFetchResult *allPhotosResult;
PHFetchOptions *allPhotosOptions;
PHImageRequestOptions *requestOptions;

-(void)initWithDelegate:(id)del{
    delegate = del;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if( self ) {
        [[NSBundle mainBundle] loadNibNamed:@"MediaButtonMenu" owner:self options:nil];
        [self addSubview:self.mView];
    }

    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [collectionView registerNib:[UINib nibWithNibName:@"MediaItemCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cellImage"];
    allPhotosOptions = [PHFetchOptions new];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    allPhotosResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];
    self.imageManager = [[PHCachingImageManager alloc] init];
    requestOptions = [[PHImageRequestOptions alloc] init];
//    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeFast;
//    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    requestOptions.synchronous = YES;

    [collectionView reloadData];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if( self ) {
        [[NSBundle mainBundle] loadNibNamed:@"MediaButtonMenu" owner:self options:nil];
        CGRect rect = frame;
        rect.origin.x = 0;
        rect.origin.y = 0;
        self.mView.frame = rect;
        [self addSubview:self.mView];
    }
    return self;
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect rect = self.frame;
    return CGSizeMake((rect.size.width)/3-30, (rect.size.width)/3-30);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return allPhotosResult.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

return 1;
}

#pragma mark collection view cell paddings
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 20, 10, 20); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {

    return 20.0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    NSString *identifier = @"cellImage";

    MediaItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    PHAsset *asset = allPhotosResult[indexPath.item];
    [self.imageManager requestImageForAsset:asset targetSize:CGSizeMake(200, 200) contentMode:PHImageContentModeAspectFit options:requestOptions resultHandler:^(UIImage *result, NSDictionary* info) {
        
        if (result != NULL) {
            cell.photoView.image = result;
        }
    }];
    return cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset *asset = allPhotosResult[indexPath.item];
    [self.imageManager requestImageForAsset:asset targetSize:CGSizeMake(500, 500) contentMode:PHImageContentModeAspectFit options:requestOptions resultHandler:^(UIImage *result, NSDictionary* info) {
        
        if (result != NULL) {
            [self->delegate bottomMenuItemClicked:self imgData:result];
        }
    }];
}

- (IBAction)onPhotoRollClicked:(id)sender {    
}
- (IBAction)onCameraClicked:(id)sender {
}
- (IBAction)onCameraRollClicked:(id)sender {
}

@end
