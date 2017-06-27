//
//  HVideoReader.m
//  MovieCodec_AVFoundation
//
//  Created by huangshiping on 2017/6/19.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HVideoReader.h"
#import <AVFoundation/AVFoundation.h>

@interface HVideoReader()
@property(nonatomic,strong)NSURL* url;
@property(nonatomic,strong)AVURLAsset* asset;
@property(nonatomic,strong)AVAssetReader* assetReader;
@property(nonatomic,strong)AVAssetReaderTrackOutput* videoTrackOutput;
@property(nonatomic,strong)AVAssetReaderTrackOutput* audioTrackOutput;

@end

@implementation HVideoReader
- (instancetype)initWithAsset:(NSURL *)url
{
    self = [super init];
    if( self )
    {
        _url = url;
    }
    return self;
}
-(void)startReading:(dispatch_block_t)completion
{
    NSDictionary* inputDic = @{AVURLAssetPreferPreciseDurationAndTimingKey:@(YES)};
    if( !_url )
    {
        NSLog(@"startreading asset at null url");
        return;
    }
     _asset = [[AVURLAsset alloc] initWithURL:_url options:inputDic];
    if (_asset)
    {
        [_asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                NSError* err = nil;
                AVKeyValueStatus stat = [_asset statusOfValueForKey:@"tracks" error:&err];
                if( stat == !AVKeyValueStatusLoaded )
                {
                    return;
                }
                 //1.
                 self.assetReader = [AVAssetReader assetReaderWithAsset:self.asset error:&err];
                
                //2.
                self.videoTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:[[self.asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] outputSettings:@{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)} ];
                self.videoTrackOutput.alwaysCopiesSampleData = NO;
                
                if ([self.assetReader canAddOutput:self.videoTrackOutput])
                {
                    [self.assetReader addOutput:self.videoTrackOutput];
                }
                
                //3.
                self.audioTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:[[self.asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] outputSettings:@{AVFormatIDKey:@(kAudioFormatLinearPCM),AVLinearPCMIsBigEndianKey:@NO,AVLinearPCMIsFloatKey    :@NO,AVLinearPCMBitDepthKey:@(16)}];
                
                if ([self.assetReader canAddOutput:self.audioTrackOutput])
                {
                    [self.assetReader addOutput:self.audioTrackOutput];
                }
                
                
                self.audioTrackOutput.alwaysCopiesSampleData = NO;
                [self.assetReader startReading];
                if(completion)
                {
                    completion();
                }

                
            });
        }];
    }
}

-(void)stopReading
{
    [self.assetReader cancelReading];
    self.assetReader = nil;
}

- (CMSampleBufferRef)getNextVideoSampleBuffer
{
    if( self.assetReader.status == AVAssetReaderStatusReading)
    {
        CMSampleBufferRef buffer = [self.videoTrackOutput copyNextSampleBuffer];
        if( buffer )
        {
            return buffer;
        }
    }
    return nil;
}

- (CMSampleBufferRef)getNextAudioSampleBuffer
{
    if( self.assetReader.status == AVAssetReaderStatusReading)
    {
        CMSampleBufferRef buffer = [self.audioTrackOutput copyNextSampleBuffer];
        return buffer;
    }
    return nil;
}

- (float)curFps
{
    return _videoTrackOutput.track.nominalFrameRate;
}

@end



































