//
//  HESVideoCamera.h
//  HTools
//
//  Created by huangshiping on 2017/6/13.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import <Foundation/Foundation.h>

@import AVFoundation;
@protocol AVCaptureVideoDataOutputSampleBufferDelegate;

/**
 *捕获视频
 */
@interface HESVideoCamera : NSObject

-(void)startRunning;

-(void)setSampleBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)bufferDelegate queue:(dispatch_queue_t) queue;

-(void)stopRunning;

-(void)swatchCamera;
@end
