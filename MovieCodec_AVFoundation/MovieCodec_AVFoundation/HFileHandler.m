//
//  HFileHandler.m
//  MovieCodec_AVFoundation
//
//  Created by huangshiping on 2017/6/20.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HFileHandler.h"

@implementation HFileHandler

-(NSString*)pathToDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

- (AVURLAsset*)getAssetURLFromFileName:(NSString*)fileName
{
    NSString *filePath = [[self pathToDocumentsDirectory] stringByAppendingPathComponent:fileName];
    NSURL* sourceMovieURL = [NSURL fileURLWithPath:filePath];
    AVURLAsset* asset = [AVURLAsset URLAssetWithURL:sourceMovieURL options:nil];
    return asset;
}

- (AVURLAsset*)getAssetURLFromBundleWithFileName:(NSString*)fileName
{
    NSString *sourceMoviePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSURL *sourceMovieURL = [NSURL fileURLWithPath:sourceMoviePath];
    AVURLAsset *sourceAsset	= [AVURLAsset URLAssetWithURL:sourceMovieURL options:nil];
    return sourceAsset;
}


@end
