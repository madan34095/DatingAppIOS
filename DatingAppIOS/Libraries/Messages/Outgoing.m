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

#import <Firebase/Firebase.h>
#import "MBProgressHUD.h"

#import "utilities.h"
#import "ProgressHUD.h"

#import "Outgoing.h"

@interface Outgoing()
{
	NSString *groupId;
	UIView *view;

    User *me;
    NSString *sendOriginalMessage;
}
@end

@implementation Outgoing

- (id)initWith:(NSString *)groupId_ View:(UIView *)view_
{
	self = [super init];
	groupId = groupId_;
	view = view_;
	return self;
}

- (void)send:(NSString *)text Picture:(UIImage *)picture
{
    UserSession* userSession = [UserAccessSession getUserSession];
    
    me = [CoreDataController getUserByUserId:userSession.userId];

    NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
    item[@"groupId"] = groupId;
    item[@"userId"] = me.user_id;
	item[@"name"] = me.username;
	item[@"date"] = Date2String([NSDate date]);
    item[@"audio_md5hash"] = @"";
    item[@"picture_md5hash"] = @"";
    item[@"video_md5hash"] = @"";
//    item[@"status"] = TEXT_DELIVERED;
    item[@"status"] = @"";
	item[@"video"] = item[@"thumbnail"] = item[@"picture"] = item[@"audio"] = item[@"latitude"] = item[@"longitude"] = @"";
	item[@"video_duration"] = item[@"audio_duration"] = @0;
	item[@"picture_width"] = item[@"picture_height"] = @0;
	if (text != nil) [self sendTextMessage:item Text:text];
	else if (picture != nil) [self sendPictureMessage:item Picture:picture];
}

- (void)sendTextMessage:(NSMutableDictionary *)item Text:(NSString *)text
{
    sendOriginalMessage = text;
    
    AppDelegate *dlg = [AppDelegate instance];
    if (NGWordFind(dlg.NGWordList, text)) {
        return;
    }
    if ([text containsString:@"スクリ-ンショットを撮りました。"])
    {
        item[@"type"] = @"screen_shot";
    }else
    {
        item[@"type"] = IsEmoji(text) ? @"emoji" : @"text";
    }
	item[@"text"] = text;
	[self sendMessage:item];
    
    [self sendNotification:item msg:text];
}

- (void)sendVideoMessage:(NSMutableDictionary *)item Video:(NSURL *)video
{
    [ProgressHUD show:@"アップロード" Interaction:NO];
	UIImage *picture = VideoThumbnail(video);
	UIImage *squared = SquareImage(picture, 320);
	NSNumber *duration = VideoDuration(video);
	NSData *dataThumbnail = UIImageJPEGRepresentation(squared, 0.3);
	NSData *dataVideo = [NSData dataWithContentsOfFile:video.path];
	NSData *cryptedThumbnail = EncryptData(groupId, dataThumbnail);
	NSData *cryptedVideo = EncryptData(groupId, dataVideo);
	NSString *md5Video = [AiChecksum md5HashOfData:cryptedVideo];
    NSString *filePath = [MGUtilities writeFile:cryptedThumbnail type:@"png"];

    NSURL *url = [NSURL URLWithString:SYNC_ITEM_PHOTO_JSON_URL];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    UserSession* session = [UserAccessSession getUserSession];
    NSDictionary *params = nil;
    
    params = [NSDictionary dictionaryWithObjectsAndKeys:
              session.loginHash, @"login_hash",
              nil];
    
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"" parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        
        NSString* fullNamePicture = [filePath lastPathComponent];
        
        if(cryptedThumbnail != nil) {
            [formData appendPartWithFileData:cryptedThumbnail
                                        name:@"picture_file"
                                    fileName:fullNamePicture
                                    mimeType:@"image/jpeg"];
        }
        
    }];
    
    [request setTimeoutInterval:10];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:kNilOptions
                                                               error:&error];
        
        NSDictionary* dictStatus = [json objectForKey:@"status"];
        NSDictionary* dictPhoto = [json objectForKey:@"photo_info"];
        
        if([[dictStatus valueForKey:@"status_code"] isEqualToString:STATUS_SUCCESS]) {
            
            [MGFileManager deleteImageAtFilePath:filePath];
            
            NSString *fileUrl = [dictPhoto valueForKey:@"picture_url"];
            
            [self saveLocal:fileUrl Data:dataThumbnail];
            
            item[@"thumbnail"] = fileUrl;

            NSString *filePath = [MGUtilities writeFile:cryptedVideo type:@"mp4"];
            
            NSURL *url = [NSURL URLWithString:SYNC_ITEM_PHOTO_JSON_URL];
            AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
            
            UserSession* session = [UserAccessSession getUserSession];
            NSDictionary *params = nil;
            
            params = [NSDictionary dictionaryWithObjectsAndKeys:
                      session.loginHash, @"login_hash",
                      nil];
            
            NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"" parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                
                NSString* fullNamePicture = [filePath lastPathComponent];
                
                if(cryptedVideo != nil) {
                    [formData appendPartWithFileData:cryptedVideo
                                                name:@"picture_file"
                                            fileName:fullNamePicture
                                            mimeType:@"image/jpeg"];
                }
                
            }];
            
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSError* error;
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                     options:kNilOptions
                                                                       error:&error];
                
                NSDictionary* dictStatus = [json objectForKey:@"status"];
                NSDictionary* dictPhoto = [json objectForKey:@"photo_info"];
                
                if([[dictStatus valueForKey:@"status_code"] isEqualToString:STATUS_SUCCESS]) {
                    
                    [MGFileManager deleteImageAtFilePath:filePath];
                    
                    NSString *fileUrl = [dictPhoto valueForKey:@"picture_url"];
                    
                    [self saveLocal:fileUrl Data:dataVideo];
                    
                    item[@"video"] = fileUrl;
                    item[@"video_duration"] = duration;
                    item[@"video_md5hash"] = md5Video;
                    item[@"text"] = @"[動画メッセージ]";
                    item[@"type"] = @"video";
                    [self sendMessage:item];
                    
                    [self sendNotification:item msg:@"video"];
                    
                    [ProgressHUD dismiss];
                }
                else {
                    [ProgressHUD showError:@"アップロードが失敗しました。"];
                }
                
                AppDelegate* delegate = [AppDelegate instance];
                delegate.networkState = @"YES";
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                AppDelegate* delegate = [AppDelegate instance];
                delegate.networkState = @"NO";
            }];
            
            [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                                long long totalBytesWritten,
                                                long long totalBytesExpectedToWrite) {
                NSInteger process = (totalBytesWritten * 100) / totalBytesExpectedToWrite;
                NSString *markVal = [NSString stringWithFormat:@"%li", (long)process];
                markVal = [markVal stringByAppendingString:@" %"];
                [ProgressHUD show:markVal];
            }];
            
            [operation start];
        }
        else {
            [ProgressHUD showError:@"アップロードが失敗しました。"];
        }
        
        AppDelegate* delegate = [AppDelegate instance];
        delegate.networkState = @"YES";
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        AppDelegate* delegate = [AppDelegate instance];
        delegate.networkState = @"NO";
        
        [ProgressHUD showError:@"ネットワーク接続がありません。"];
    }];
    [operation start];
    
}

- (void)sendPictureMessage:(NSMutableDictionary *)item Picture:(UIImage *)picture
{
    [ProgressHUD show:@"アップロード" Interaction:NO];
	int width = (int) picture.size.width;
	int height = (int) picture.size.height;
	NSData *dataPicture = UIImageJPEGRepresentation(picture, 0.3);
	NSData *cryptedPicture = EncryptData(groupId, dataPicture);
	NSString *md5Picture = [AiChecksum md5HashOfData:cryptedPicture];
    NSString *filePath = [MGUtilities writeFile:cryptedPicture type:@"png"];
    
    NSURL *url = [NSURL URLWithString:SYNC_ITEM_PHOTO_JSON_URL];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    UserSession* session = [UserAccessSession getUserSession];
    NSDictionary *params = nil;
    
    params = [NSDictionary dictionaryWithObjectsAndKeys:
              session.loginHash, @"login_hash",
              nil];
    
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"" parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        
        NSString* fullNamePicture = [filePath lastPathComponent];
        
        if(cryptedPicture != nil) {
            [formData appendPartWithFileData:cryptedPicture
                                        name:@"picture_file"
                                    fileName:fullNamePicture
                                    mimeType:@"image/jpeg"];
        }
        
    }];
    
    [request setTimeoutInterval:15];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:kNilOptions
                                                               error:&error];
        
        NSDictionary* dictStatus = [json objectForKey:@"status"];
        NSDictionary* dictPhoto = [json objectForKey:@"photo_info"];
        
        if([[dictStatus valueForKey:@"status_code"] isEqualToString:STATUS_SUCCESS]) {
            
            [MGFileManager deleteImageAtFilePath:filePath];
            
            NSString *fileUrl = [dictPhoto valueForKey:@"picture_url"];
            
            [self saveLocal:fileUrl Data:dataPicture];

            item[@"picture"] = fileUrl;
            item[@"picture_width"] = [NSNumber numberWithInt:width];
            item[@"picture_height"] = [NSNumber numberWithInt:height];
            item[@"picture_md5hash"] = md5Picture;
            item[@"text"] = @"[画像メッセージ]";
            item[@"type"] = @"picture";
            [self sendMessage:item];
            
            [self sendNotification:item msg:@"image"];

            
            [ProgressHUD dismiss];
        }
        else {
            [ProgressHUD showError:@"アップロードが失敗しました。"];
        }
        
        AppDelegate* delegate = [AppDelegate instance];
        delegate.networkState = @"YES";
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        AppDelegate* delegate = [AppDelegate instance];
        delegate.networkState = @"NO";
        
        [ProgressHUD showError:@"ネットワーク接続がありません。"];
    }];
    
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        NSInteger process = (totalBytesWritten * 100) / totalBytesExpectedToWrite;
        NSString *markVal = [NSString stringWithFormat:@"%li", (long)process];
        markVal = [markVal stringByAppendingString:@" %"];
        [ProgressHUD show:markVal];
    }];
    
    [operation start];
}

- (void)sendAudioMessage:(NSMutableDictionary *)item Audio:(NSString *)audio
{
    [ProgressHUD show:@"アップロード" Interaction:NO];
	NSNumber *duration = AudioDuration(audio);
	NSData *dataAudio = [NSData dataWithContentsOfFile:audio];
	NSData *cryptedAudio = EncryptData(groupId, dataAudio);
	NSString *md5Audio = [AiChecksum md5HashOfData:cryptedAudio];
    NSString *filePath = [MGUtilities writeFile:cryptedAudio type:@"m4a"];
    
    NSURL *url = [NSURL URLWithString:SYNC_ITEM_PHOTO_JSON_URL];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    UserSession* session = [UserAccessSession getUserSession];
    NSDictionary *params = nil;
    
    params = [NSDictionary dictionaryWithObjectsAndKeys:
              session.loginHash, @"login_hash",
              nil];
    
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"" parameters:params constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        
        NSString* fullNamePicture = [filePath lastPathComponent];
        
        if(cryptedAudio != nil) {
            [formData appendPartWithFileData:cryptedAudio
                                        name:@"picture_file"
                                    fileName:fullNamePicture
                                    mimeType:@"image/jpeg"];
        }
        
    }];
    
    [request setTimeoutInterval:10];
    

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:kNilOptions
                                                               error:&error];
        
        NSDictionary* dictStatus = [json objectForKey:@"status"];
        NSDictionary* dictPhoto = [json objectForKey:@"photo_info"];
        
        if([[dictStatus valueForKey:@"status_code"] isEqualToString:STATUS_SUCCESS]) {
            
            [MGFileManager deleteImageAtFilePath:filePath];
            
            NSString *fileUrl = [dictPhoto valueForKey:@"picture_url"];
            
            [self saveLocal:fileUrl Data:dataAudio];
            
            item[@"audio"] = fileUrl;
            item[@"audio_duration"] = duration;
            item[@"audio_md5hash"] = md5Audio;
            item[@"text"] = @"[音声メッセージ]";
            item[@"type"] = @"audio";
            [self sendMessage:item];
            
            [self sendNotification:item msg:@"audio"];

            [ProgressHUD dismiss];
        }
        else {
            [ProgressHUD showError:@"アップロードが失敗しました。"];
        }
        
        AppDelegate* delegate = [AppDelegate instance];
        delegate.networkState = @"YES";
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        AppDelegate* delegate = [AppDelegate instance];
        delegate.networkState = @"NO";
        
        [ProgressHUD showError:@"ネットワーク接続がありません。"];
    }];
    
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        NSInteger process = (totalBytesWritten * 100) / totalBytesExpectedToWrite;
        NSString *markVal = [NSString stringWithFormat:@"%li", (long)process];
        markVal = [markVal stringByAppendingString:@" %"];
        [ProgressHUD show:markVal];
    }];
    
    [operation start];
}

- (void)sendLoactionMessage:(NSMutableDictionary *)item
{
	AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
	item[@"latitude"] = [NSNumber numberWithDouble:app.coordinate.latitude];
	item[@"longitude"] = [NSNumber numberWithDouble:app.coordinate.longitude];
	item[@"text"] = @"[Location message]";
	item[@"type"] = @"location";
	[self sendMessage:item];
    
    [self sendNotification:item msg:@"location"];

}

- (void)sendMessage:(NSMutableDictionary *)item
{
    NSString *original_msg = item[@"text"];
	item[@"text"] = EncryptText(groupId, original_msg);
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Message/%@", FIREBASE, groupId]];
	Firebase *reference = [firebase childByAutoId];
	item[@"messageId"] = reference.key;
	[reference setValue:item withCompletionBlock:^(NSError *error, Firebase *ref)
	{
		if (error != nil) NSLog(@"Outgoing sendMessage network error.");
	}];
    UpdateRecents(groupId, item[@"text"]);
}

#pragma mark - Helper methods

- (void)saveLocal:(NSString *)link Data:(NSData *)data
{
	NSString *file = [link stringByReplacingOccurrencesOfString:LINK_PARSE withString:@""];
	[data writeToFile:Documents(file) atomically:NO];

    NSDictionary *insert_file = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    file, @"name", nil];

    [CoreDataController insertFile:insert_file];
}

-(void)sendNotification:(NSMutableDictionary *)item msg:(NSString *)message
{
    NSString *receive_id = [groupId stringByReplacingOccurrencesOfString:item[@"userId"] withString:@""];
    NSInteger user_num = [receive_id length];
    
    if (groupId.length <= 11) {
        Group *group = [CoreDataController getGroupByUserId:groupId];
        receive_id = [group.members stringByReplacingOccurrencesOfString:item[@"userId"] withString:@""];
        user_num = [receive_id length];
    }

    for (NSInteger i=0; i<user_num; i += 11) {
        NSString *c_message = message;
        c_message = [c_message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSURL *url = [NSURL URLWithString:SEND_MESSAGE_URL];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
        
        NSString *ids = [receive_id substringWithRange:NSMakeRange(i, 11)];

        NSMutableArray *recents = [[NSMutableArray alloc] init];
        Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent", FIREBASE]];
        FQuery *query = [[firebase queryOrderedByChild:@"userId"] queryEqualToValue:ids];
        [query observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
         {
             NSString *total_badge = @"0";
             int total = 0;
             if (snapshot.value != [NSNull null])
             {
                 [recents removeAllObjects];
                 NSArray *sorted = [[snapshot.value allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
                                    {
                                        NSDictionary *recent1 = (NSDictionary *)obj1;
                                        NSDictionary *recent2 = (NSDictionary *)obj2;
                                        NSDate *date1 = String2Date(recent1[@"date"]);
                                        NSDate *date2 = String2Date(recent2[@"date"]);
                                        return [date2 compare:date1];
                                    }];
                 for (NSDictionary *data in sorted)
                 {
                     [recents addObject:data];
                 }
                 for (NSDictionary *recent in recents)
                 {
                     total += [recent[@"counter"] intValue];
                 }
                 total_badge = [NSString stringWithFormat:@"%d", total];
             }
             NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                     me.user_id, @"sender_id",
                                     ids, @"seller_id",
                                     c_message, @"message",
                                     total_badge, @"badge_num",
                                     API_KEY, @"api_key",
                                     nil];
             [httpClient postPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 
                 AppDelegate* delegate = [AppDelegate instance];
                 delegate.networkState = @"YES";
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 
                 AppDelegate* delegate = [AppDelegate instance];
                 delegate.networkState = @"NO";
//                 [ProgressHUD showError:@"ネットワーク接続がありません。"];
             }];
         }];
    }
}
@end
