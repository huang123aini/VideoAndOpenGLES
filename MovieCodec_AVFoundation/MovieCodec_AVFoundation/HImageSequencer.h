//
//  HImageSequencer.h
//  MovieCodec_AVFoundation
//
//  Created by huangshiping on 2017/6/20.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>



#define k_exportedClipName @"Exported.mov"
#define k_exportedSequenceName @"imageSequence_reverse.mov"




@protocol ImageSequencerDelegate <NSObject>

-(void)exportedImageSequenceToFileName:(NSString*)fileName;
-(void)imageSequencerProgress:(Float64)percentage;

@end

@interface HImageSequencer : NSObject
@property(unsafe_unretained)id<ImageSequencerDelegate> delegate;

- (void)createImageSequenceWithAsset:(AVURLAsset*)urlAsset;

@end
