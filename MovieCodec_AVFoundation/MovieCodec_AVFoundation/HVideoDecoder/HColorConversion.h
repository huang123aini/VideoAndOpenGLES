//
//  HColorConversion.h
//  MovieCodec_AVFoundation
//
//  Created by huangshiping on 2017/6/21.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GPUImageContext.h"

extern GLfloat *kColorConversion601;
extern GLfloat *kColorConversion601FullRange;
extern GLfloat *kColorConversion709;
extern NSString *const kGPUImageVertexShaderString;
extern NSString *const kGPUImageYUVFullRangeConversionForLAFragmentShaderString;
extern NSString *const kGPUImagePassthroughFragmentShaderString;
