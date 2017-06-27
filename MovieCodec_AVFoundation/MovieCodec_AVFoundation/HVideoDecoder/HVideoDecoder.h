//
//  HVideoDecoder.h
//  MovieCodec_AVFoundation
//
//  Created by huangshiping on 2017/6/21.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AVFoundation/AVFoundation.h>


@class GPUImageFramebuffer;

@protocol HVideoDecoderDelegate <NSObject>

-(void)didCompletePlayingMovie;
-(void)didDecodeInputFramebuffer:(GPUImageFramebuffer*)newInputFramebuffer inputSize:(CGSize)newSize frameTime:(CMTime)frameTime;

@end

@interface HVideoDecoder : NSObject

@property (nonatomic, strong) AVAsset*                asset;
@property (nonatomic, strong) NSString*               videoPath;
@property (nonatomic, assign, readonly) CGFloat       progress;

@property (nonatomic, assign) BOOL keepLooping;

@property (nonatomic, weak) id <HVideoDecoderDelegate> delegate;

- (instancetype)initWithVideoPath:(NSString *)videoPath size:(CGSize)size;

- (void)startProcessing;/**<开始处理*/
- (void)endProcessing;/**<处理结束*/
- (void)cancelProcessing;/**<取消处理*/

@end
