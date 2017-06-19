//
//  CameraTestVc.m
//  HTools
//
//  Created by huangshiping on 2017/6/13.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "CameraTestVc.h"
#import <MobileCoreServices/MobileCoreServices.h>

#import <HRealTimeProcessing.h>

#import "HESVideoCamera.h"
#import "HESNode.h"
#import "HNodeImageView.h"
#import "HCVPixelBufferInput.h"
#import "HESContext.h"
#import "HNv12InputNode.h"


@import ImageIO;

@interface CameraTestVc ()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    UIImage *            _image;
    HNodeImageView *     _customView;
    HESVideoCamera *     _captureSessionHelper;
    HCVPixelBufferInput* _operationSource;
    
    dispatch_queue_t     _captureQueue;
}
@end

@implementation CameraTestVc

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    _captureSessionHelper=[[HESVideoCamera alloc]init];
    
    CGSize screenSize=[UIScreen mainScreen].bounds.size;
    
    [HESContext pushContext];
    
    _customView=[[HNodeImageView alloc]initWithFrame:CGRectMake(0, 0,screenSize.width, screenSize.height)];
    
    _customView.center=[_customView convertPoint:self.view.center fromView:self.view];
    
    [self.view addSubview:_customView];
    
    [self buildBeautyGroupLayer];
    
    [_customView setContentProviderNode:_operationSource];
    
    __weak typeof(self) weakSelf=self;
    
    _captureQueue=dispatch_queue_create([@"拍摄线程" UTF8String], DISPATCH_QUEUE_SERIAL);
    
    [_captureSessionHelper setSampleBufferDelegate:weakSelf queue:_captureQueue];
    
  
    HNv12InputNode *nvNode=[HNv12InputNode new];
    
    NSLog(@"%@",nvNode);
    
}

-(void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    
    [_captureSessionHelper startRunning];
    
}

-(void)buildBeautyGroupLayer
{
    
    _operationSource=[HCVPixelBufferInput new];
    
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
    CVImageBufferRef imageBufferRef=CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress(imageBufferRef, 0);
    
    [_operationSource uploadCVPixelBuffer:imageBufferRef];
 
    [_operationSource drive];
    
    CVPixelBufferUnlockBaseAddress(imageBufferRef, 0);
    
}

-(void)dealloc
{
    
    [_captureSessionHelper stopRunning];
    
    NSLog(@"视频测试页面已经销毁了");
    
    [_operationSource removeFromAllDependency];
    
    [_customView removeFromSuperview];
    
    [HESContext popContext];
    
}


@end
