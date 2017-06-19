//
//  MovieDecoder.h
//  MovieCodec_AVFoundation
//
//  Created by huangshiping on 2017/6/16.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>


@interface MovieDecoder : NSObject

- (NSArray *)convertToSampBufferRef:(NSURL *)videoUrl;
+ (CGImageRef)imageFromSampleBufferRef:(CMSampleBufferRef)sampleBufferRef;
@end
