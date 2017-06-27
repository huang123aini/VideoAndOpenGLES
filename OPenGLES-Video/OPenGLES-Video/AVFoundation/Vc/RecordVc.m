//
//  RecordVc.m
//  OPenGLES-Video
//
//  Created by huangshiping on 2017/6/21.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "RecordVc.h"

#import <MovieCodec_AVFoundation/HVideoRecorder.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>



@interface RecordVc ()<HRecorderDelegate> //添加录制代理

@property(nonatomic,strong)HVideoRecorder* recorder;

@end

@implementation RecordVc

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    UIButton* recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [recordButton setFrame:CGRectMake(100, 100, 100, 100)];
    [recordButton setBackgroundColor:[UIColor redColor]];
    [recordButton setTitle:@"开始录制" forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(startRecord) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordButton];
    
    
    
    UIButton* stopButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [stopButton setFrame:CGRectMake(100, 100, 100, 100)];
    [stopButton setBackgroundColor:[UIColor redColor]];
    [stopButton setTitle:@"停止录制" forState:UIControlStateNormal];
    [stopButton addTarget:self action:@selector(stopRecord) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopButton];
    
    
    
    
    
    
    //1.
    
    NSString *path = [NSTemporaryDirectory() stringByAppendingString:@"test.mp4"];
    
    self.recorder = [[HVideoRecorder alloc] initWithOutputFilePath:path outputSize:self.view.frame.size];
    
    self.recorder.delegate = self;
    
    //录制时需要获取预览显示的layer，根据情况设置layer属性，显示在自定义的界面上
    AVCaptureVideoPreviewLayer *previewLayer = [self.recorder previewLayer];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.frame = self.view.frame;
    [self.view.layer insertSublayer:previewLayer atIndex:0];
    
    //开始预览摄像头工作
    [self.recorder startRunning];
    
    
}

-(void)startRecord
{
    [self.recorder startRecording];
}
-(void)stopRecord
{
    [self.recorder stopRecording];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
