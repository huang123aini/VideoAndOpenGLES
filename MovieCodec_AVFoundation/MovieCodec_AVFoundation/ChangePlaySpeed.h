//
//  ChangePlaySpeed.h
//  MovieCodec_AVFoundation
//
//  Created by huangshiping on 2017/6/19.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *快播.慢播
 */

@interface ChangePlaySpeed : NSObject

+(void)changeWithURL:(NSURL*)url speed:(float)speed;

@end
