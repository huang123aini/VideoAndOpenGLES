//
//  ReverseClipVc.m
//  OPenGLES-Video
//
//  Created by huangshiping on 2017/6/20.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "ReverseClipVc.h"

#import <MovieCodec_AVFoundation/HToolBox.h>

@interface ReverseClipVc ()

@end

@implementation ReverseClipVc

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieIsExported)
                                                 name:@"ExportedMovieNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageSequenceIsExported)
                                                 name:@"ExportedImageSequenceNotification"
                                               object:nil];
    
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:[UIColor redColor]];
    [button setFrame:CGRectMake(100, 100, 100, 100)];
    [button addTarget:self action:@selector(createReverseClip) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"开始" forState:UIControlStateNormal];
    [self.view addSubview:button];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void) createReverseClip
{
    HFileHandler *filehandler = [[HToolBox sharedToolbox] fileHandler];
    AVURLAsset *urlAsset = [filehandler getAssetURLFromBundleWithFileName:@"a.mp4"];
    [self exportReversedClip:urlAsset];
}

-(void) exportReversedClip:(AVURLAsset *)urlAsset
{
    Float64 assetDuration = CMTimeGetSeconds(urlAsset.duration) * 0.5;
    HComposer *compositionTool = [[HToolBox sharedToolbox] composer];
    
    [compositionTool addToCompositionWithAsset:(AVURLAsset*)urlAsset inSeconds:0.0 outSeconds:assetDuration shouldBeReversed:YES];
}

#pragma mark - Notifications
-(void)movieIsExported
{
    HFileHandler *fileHandler = [[HToolBox sharedToolbox] fileHandler];
    AVURLAsset *urlAsset = [fileHandler getAssetURLFromFileName:k_exportedClipName];
    NSLog(@"The movie has been exported. \n URLAsset:%@",urlAsset);
}

-(void)imageSequenceIsExported
{
    HFileHandler *fileHandler = [[HToolBox sharedToolbox] fileHandler];
    AVURLAsset *urlAsset = [fileHandler getAssetURLFromFileName:k_exportedSequenceName];
    NSLog(@"The image sequence has been exported. \n URLAsset:%@",urlAsset);
}


@end
