//
//  HComposer.h
//  MovieCodec_AVFoundation
//
//  Created by huangshiping on 2017/6/20.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface HComposer : NSObject

@property(nonatomic,strong)AVMutableComposition *composition;

-(void) addToCompositionWithAsset:(AVURLAsset*)urlAsset
                        inSeconds:(Float64)inSec
                       outSeconds:(Float64)outSec
                 shouldBeReversed:(BOOL)shouldBeReversed;

@end
