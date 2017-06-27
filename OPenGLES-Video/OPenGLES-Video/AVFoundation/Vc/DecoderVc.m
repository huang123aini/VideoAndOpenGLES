//
//  DecoderVc.m
//  OPenGLES-Video
//
//  Created by huangshiping on 2017/6/21.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "DecoderVc.h"

#import <MovieCodec_AVFoundation/HVideoDecoder/HImageView.h>

@interface DecoderVc()

@property(nonatomic,strong)HImageView* videoImageView;


@end

@implementation DecoderVc

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"before" ofType:@"mp4"];
    UIImage* image = [UIImage imageNamed:@"timg.jpg"];
    self.videoImageView = [[HImageView alloc] initWithFrame:self.view.frame videoPath:videoPath previewImage:image];
    
    [self.view addSubview:self.videoImageView];
    
    UIButton* recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [recordButton setFrame:CGRectMake(100, 100, 100, 100)];
    [recordButton setBackgroundColor:[UIColor redColor]];
    [recordButton setTitle:@"开始播放" forState:UIControlStateNormal];
    
    [recordButton addTarget:self action:@selector(startPlay) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordButton];
    
    
    
    UIButton* stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [stopButton setFrame:CGRectMake(100, 250, 100, 100)];
    [stopButton setBackgroundColor:[UIColor redColor]];
    [stopButton setTitle:@"停止播放" forState:UIControlStateNormal];
    [stopButton addTarget:self action:@selector(stopPlay) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopButton];
    
}

-(void)startPlay
{
    [self.videoImageView play];
}
-(void)stopPlay
{
    [self.videoImageView stop];
}



@end
