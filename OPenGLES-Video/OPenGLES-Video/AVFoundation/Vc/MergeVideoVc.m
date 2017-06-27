//
//  MergeVideoVc.m
//  OPenGLES-Video
//
//  Created by huangshiping on 2017/6/20.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "MergeVideoVc.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>


@interface MergeVideoVc ()

@end

@implementation MergeVideoVc

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"before" ofType:@"mp4"];
    AVAsset *asset1 = [AVAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
//    NSString *filePath2 = [[NSBundle mainBundle] pathForResource:@"before" ofType:@"mp4"];
//    AVAsset *asset2 = [AVAsset assetWithURL:[NSURL fileURLWithPath:filePath2]];
//    NSString *filePath3 = [[NSBundle mainBundle] pathForResource:@"before" ofType:@"mp4"];
//    AVAsset *asset3 = [AVAsset assetWithURL:[NSURL fileURLWithPath:filePath3]];
    
    NSArray *assets = @[asset1/*, asset2, asset3*/];
    
    AVMutableComposition* composition = [AVMutableComposition composition];
    AVMutableCompositionTrack* videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack* audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    NSMutableArray* instructions = [NSMutableArray new];
    CGSize size = CGSizeZero;
    CMTime time = kCMTimeZero;
    

    for (AVAsset* asset in assets)
    {
        
        
        AVAssetTrack * videoAssetTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        AVAssetTrack* audioAssetTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
        
        NSError* error;
        [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration) ofTrack:videoAssetTrack atTime:time error:&error];
        
        if (error)
        {
            NSLog(@"Error - %@", error.debugDescription);
        }
        
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAssetTrack.timeRange.duration)
                                       ofTrack:audioAssetTrack
                                        atTime:time
                                         error:&error];
        if (error)
        {
            NSLog(@"Error - %@", error.debugDescription);
        }
        
        CMTimeShow(videoAssetTrack.timeRange.duration);
        CMTimeShow(audioAssetTrack.timeRange.duration);
        
        
        
        AVMutableVideoCompositionInstruction *videoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        
        videoCompositionInstruction.timeRange = CMTimeRangeMake(time, videoAssetTrack.timeRange.duration);
        
        videoCompositionInstruction.layerInstructions = @[[AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack]];
        
        [instructions addObject:videoCompositionInstruction];
        
        time = CMTimeAdd(time, videoAssetTrack.timeRange.duration);
        
        if (CGSizeEqualToSize(size, CGSizeZero))
        {
            size = videoAssetTrack.naturalSize;;
        }
        
        
        AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];
        mutableVideoComposition.instructions = instructions;
        
        // Set the frame duration to an appropriate value (i.e. 30 frames per second for video).
        mutableVideoComposition.frameDuration = CMTimeMake(1, 30);
        mutableVideoComposition.renderSize = size;
        
        
        
        AVPlayerItem *pi = [AVPlayerItem playerItemWithAsset:composition];
        pi.videoComposition = mutableVideoComposition;
        
        AVPlayer *player = [AVPlayer playerWithPlayerItem:pi];
        
        AVPlayerLayer* layer = [[AVPlayerLayer alloc] init];
        layer.frame = self.view.frame;
        [self.view.layer addSublayer:layer];
        
        layer.player = player;
        [layer.player play];
    }
    
    
 

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
































