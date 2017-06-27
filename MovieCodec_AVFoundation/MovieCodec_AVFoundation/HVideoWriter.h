//
//  HVideoWriter.h
//  MovieCodec_AVFoundation
//
//  Created by huangshiping on 2017/6/19.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@interface HVideoWriter : NSObject

@property (nonatomic,strong,readonly) NSURL* urlAsset;

- (instancetype)initWithURL:(NSURL*)url withAudio:(BOOL)audio videoSize:(CGSize)size;

- (void)enqueueSampleBuffer:(CMSampleBufferRef)sampleBuffer;

- (void)stopRecording:(void(^)())completion;
@end
