
#import <UIKit/UIKit.h>

#import "JSQMessages.h"
#import "PhotoMediaItem.h"

@interface Incoming : NSObject

- (id)initWith:(NSString *)groupId_ CollectionView:(JSQMessagesCollectionView *)collectionView_;

- (JSQMessage *)create:(NSDictionary *)item flag:(BOOL)flag;

- (void)loadPictureMedia:(NSDictionary *)item MediaItem:(PhotoMediaItem *)mediaItem;

@end
