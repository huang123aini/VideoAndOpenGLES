//
//  SlowDownVc.m
//  OPenGLES-Video
//
//  Created by huangshiping on 2017/6/19.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "SlowDownVc.h"

#import <MovieCodec_AVFoundation/ChangePlaySpeed.h>

@interface SlowDownVc ()

@end

@implementation SlowDownVc

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"before" withExtension:@"mp4"];;
    [ChangePlaySpeed changeWithURL:url speed:0.5];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
}

@end
