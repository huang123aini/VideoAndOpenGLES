//
//  HExporter.m
//  MovieCodec_AVFoundation
//
//  Created by huangshiping on 2017/6/20.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HExporter.h"
#import "HToolBox.h"


@implementation HExporter

-(void)exportCompositionWithAsset:(AVURLAsset*)urlAsset exportName:(NSString*)exportFileName shouldBeReversed:(BOOL)shouldBeReversed
{
    currentFileExportName = exportFileName;
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:urlAsset presetName:AVAssetExportPresetMediumQuality];
    
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [dirs objectAtIndex:0];
    NSString *exportPath = [documentsDirectoryPath stringByAppendingPathComponent:exportFileName];
    
    [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    NSURL *exportURL = [NSURL fileURLWithPath:exportPath];
    
    exportSession.outputURL = exportURL;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        NSLog (@"i is in your block, exportin. status is %ld",(long)exportSession.status);
        
        switch ((int)exportSession.status)
        {
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Export failed");
            case AVAssetExportSessionStatusCompleted:
            {
                [self performSelectorOnMainThread:@selector(exportDone:)
                                       withObject:nil
                                    waitUntilDone:NO];
                
                if (shouldBeReversed)
                {
                    HImageSequencer *imageSequencerTool = [[HToolBox sharedToolbox] imageSequencer];
                    
                    [imageSequencerTool setDelegate:(id)self];
                    [imageSequencerTool createImageSequenceWithAsset:(AVURLAsset*)urlAsset];
                }
                break;
            }
        };
    }];
}

-(void) exportDone:(NSObject*)userInfo
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ExportedMovieNotification" object:self];
}

-(void)imageSequencerProgress:(Float64)percentage
{
    NSLog(@"percentage %f",percentage);
}

-(void)exportedImageSequenceToFileName:(NSString*)fileName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ExportedImageSequenceNotification" object:self];
    NSLog(@"Exported image sequence to %@",fileName);
}

@end

