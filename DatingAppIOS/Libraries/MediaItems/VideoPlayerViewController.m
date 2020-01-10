//
//  VideoPlayerViewController.m
//  TalkForest
//
//  Created by juc com on 5/8/16.
//  Copyright © 2016 Mangasaur Games. All rights reserved.
//

#import "VideoPlayerViewController.h"

@interface VideoPlayerViewController ()
{
    int leftTime;
}
@end

@implementation VideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    leftTime = 15;
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(downCounter) userInfo:nil repeats:YES];
}

-(void)downCounter
{
    leftTime--;
    if (leftTime == 0) {
        [self dismissMoviePlayerViewControllerAnimated];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
