//
//  HVideoReader.h
//  MovieCodec_AVFoundation
//
//  Created by huangshiping on 2017/6/19.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreMedia/CoreMedia.h>


@interface HVideoReader : NSObject
//返回的值在当前视频为基于帧的视频的时候才为帧率，如果当前视频为field-based或者interleaved视频时，并不代表实际帧率，而现实中绝大部分视频都是基于帧的
@property(nonatomic,assign)float curFps;

- (instancetype)initWithAsset:(NSURL*)url;

- (void)startReading:(dispatch_block_t)completion;

- (void)stopReading;

- (CMSampleBufferRef)getNextVideoSampleBuffer;

- (CMSampleBufferRef)getNextAudioSampleBuffer;


@end
