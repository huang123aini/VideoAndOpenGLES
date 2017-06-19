//
//  ChangePlaySpeed.m
//  MovieCodec_AVFoundation
//
//  Created by huangshiping on 2017/6/19.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "ChangePlaySpeed.h"
#import <AVFoundation/AVFoundation.h>


@implementation ChangePlaySpeed

+(void)changeWithURL:(NSURL*)url speed:(float)speed;
{
    
        //1.
        AVURLAsset* videoAsset =[AVURLAsset assetWithURL:url];
        
       //2.
        AVMutableComposition *mixComposition = [AVMutableComposition composition];
        
        AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                       preferredTrackID:kCMPersistentTrackID_Invalid];
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                            preferredTrackID:kCMPersistentTrackID_Invalid];
        
        
    
        //3. video and audio insert
        NSError *insertError = nil;
        BOOL videoInsertResult = [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                                                ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                                                                 atTime:kCMTimeZero
                                                                  error:&insertError];
        if (!videoInsertResult || nil != insertError)
        {
            //handle error
            return;
        }
    
    
        BOOL audioInsertResult = [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                                 ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]
                                                  atTime:kCMTimeZero
                                                   error:&insertError];
        if (!audioInsertResult || nil != insertError)
        {
           //handle error
           return;
        }

    
        //slow down whole video by 2.0
        double videoScaleFactor = speed;
    
        CMTime videoDuration = videoAsset.duration;
        
        [videoTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, videoDuration)
                                   toDuration:CMTimeMake(videoDuration.value*videoScaleFactor, videoDuration.timescale)];
    
        [audioTrack scaleTimeRange:CMTimeRangeMake(kCMTimeZero, videoDuration) toDuration:CMTimeMake(videoDuration.value * videoScaleFactor, videoDuration.timescale)];
    
    
    
    
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPreset640x480];
    
    
    NSString *outpath = [NSTemporaryDirectory() stringByAppendingString:@"test11.mp4"];
    [[NSFileManager defaultManager] removeItemAtPath:outpath error:nil];
    
    /** 导出的文件存在即删除**/
    if ([[NSFileManager defaultManager] fileExistsAtPath:outpath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:outpath error:nil];
    }
    exportSession.outputURL = [NSURL fileURLWithPath:outpath];
    exportSession.shouldOptimizeForNetworkUse = true;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        if ([exportSession status] == AVAssetExportSessionStatusCompleted)
        {
            NSLog(@"导出视频完成");
        }else
        {
            NSLog(@"当前压缩进度:%f",exportSession.progress);
        }
        NSLog(@"%@",exportSession.error);
        
    }];
}


@end
