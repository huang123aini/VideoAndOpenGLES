//
//  HExporter.h
//  MovieCodec_AVFoundation
//
//  Created by huangshiping on 2017/6/20.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "HImageSequencer.h"

@interface HExporter : NSObject
{
  NSString *currentFileExportName;
}

-(void)exportCompositionWithAsset:(AVURLAsset*)urlAsset
                       exportName:(NSString*)exportFileName
                 shouldBeReversed:(BOOL)shouldBeReversed;
@end
