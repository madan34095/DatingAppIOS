//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "JSQMessage.h"
#import "ProgressHUD.h"

#import "utilities.h"

#import "AudioMediaItem.h"
#import "EmojiMediaItem.h"
#import "PhotoMediaItem.h"
#import "VideoMediaItem.h"
#import "JSQLocationMediaItem.h"

#import "Incoming.h"

@interface Incoming()
{
	BOOL maskOutgoing;
	NSString *groupId;
	JSQMessagesCollectionView *collectionView;

    BOOL loading_flag;
    NSString *deleteURL;
    NSTimer *time;
    NSInteger cycle_num;
}
@end

@implementation Incoming

- (id)initWith:(NSString *)groupId_ CollectionView:(JSQMessagesCollectionView *)collectionView_
{
	self = [super init];
	groupId = groupId_;
	collectionView = collectionView_;
	return self;
}

- (JSQMessage *)create:(NSDictionary *)item flag:(BOOL)flag
{
    cycle_num = 0;
    loading_flag = flag;
	JSQMessage *message;

    maskOutgoing = [me.user_id isEqualToString:item[@"userId"]];
    if ([item[@"type"] isEqualToString:@"text"])		message = [self createTextMessage:item];
    if ([item[@"type"] isEqualToString:@"picture"])		message = [self createPictureMessage:item];
	return message;
}

- (JSQMessage *)createTextMessage:(NSDictionary *)item
{
    NSString *name = item[@"name"];
    NSString *userId = item[@"userId"];
    NSDate *date = String2Date(item[@"date"]);
    NSString *msg = DecryptText(groupId, item[@"text"]);

    if ([item[@"type"] isEqualToString:@"screen_shot"]) {
        return [[JSQMessage alloc] initWithSenderId:userId senderDisplayName:@"screen_shot" date:date text:msg];
    }
    return [[JSQMessage alloc] initWithSenderId:userId senderDisplayName:name date:date text:msg];
}

- (JSQMessage *)createPictureMessage:(NSDictionary *)item
{
    NSString *name = item[@"name"];
    NSString *userId = item[@"userId"];
    NSDate *date = String2Date(item[@"date"]);
    PhotoMediaItem *mediaItem = [[PhotoMediaItem alloc] initWithImage:nil Width:item[@"picture_width"] Height:item[@"picture_height"] Readable:item[@"status"]];
    mediaItem.appliesMediaViewMaskAsOutgoing = maskOutgoing;
    [self loadPictureMedia:item MediaItem:mediaItem];
    return [[JSQMessage alloc] initWithSenderId:userId senderDisplayName:name date:date media:mediaItem];
}

- (void)loadPictureMedia:(NSDictionary *)item MediaItem:(PhotoMediaItem *)mediaItem
{
    if([item[@"userId"] isEqualToString:me.user_id] || loading_flag)
    {
        mediaItem.status = STATUS_LOADING;
        
        NSString *url = item[@"picture"];
        
        NSString *newUrl = [url stringByReplacingOccurrencesOfString:LINK_PARSE withString:@""];
        
        FileList *__file = [CoreDataController getFileByUserName:newUrl];
        if (__file) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDir = paths[0];
            
            mediaItem.status = STATUS_SUCCEED;
            DecryptFile(groupId, [documentsDir stringByAppendingString:newUrl]);
            mediaItem.image = [[UIImage alloc] initWithContentsOfFile:[documentsDir stringByAppendingString:newUrl]];
            
            return;
        }
        else mediaItem.status = STATUS_FAILED;
    }
    
    [AFDownload start:item[@"picture"] md5:item[@"picture_md5hash"] complete:^(NSString *path, NSError *error, BOOL network)
     {
         if (error == nil)
         {
             mediaItem.status = STATUS_SUCCEED;
             if (network) DecryptFile(groupId, path);
             mediaItem.image = [[UIImage alloc] initWithContentsOfFile:path];
//             UIImageWriteToSavedPhotosAlbum(mediaItem.image, nil, nil, nil);
             
             NSString *newUrl = [item[@"picture"] stringByReplacingOccurrencesOfString:LINK_PARSE withString:@""];
             NSDictionary *insert_file = [[NSDictionary alloc] initWithObjectsAndKeys:
                                          newUrl, @"name", nil];
             
             [CoreDataController insertFile:insert_file];
             
             NSString *temp = item[@"groupId"];
             if ([temp length] >= 11) {
                 deleteURL = newUrl;
                 time = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(deleteFile) userInfo:nil repeats:YES];
             }
         }
         else mediaItem.status = STATUS_FAILED;
         if (network) [collectionView reloadData];
     }];
}

@end
