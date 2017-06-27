//
//  HToolBox.m
//  MovieCodec_AVFoundation
//
//  Created by huangshiping on 2017/6/20.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HToolBox.h"

@implementation HToolBox

+ (HToolBox *) sharedToolbox
{
    static HToolBox *sharedToolbox = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedToolbox = [[HToolBox alloc] init];
    });
    return sharedToolbox;
}

-(id) init
{
    if(self = [super init])
    {
        _exporter = [[HExporter alloc]init];
        _imageSequencer = [[HImageSequencer alloc]init];
        _composer = [[HComposer alloc]init];
        _fileHandler = [[HFileHandler alloc]init];
    }
    return self;
}

@end
