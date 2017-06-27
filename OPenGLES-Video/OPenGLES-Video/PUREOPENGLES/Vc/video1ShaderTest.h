//
//  ImageVBO.h
//  OPenGLES-Video
//
//  Created by huangshiping on 2017/6/19.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <RealTimeProcessing/HGLUtils.h>


#define H_VIDEO_VERTEX [[NSBundle mainBundle] pathForResource:@"video1Shader" ofType:@"vsh"]
#define H_VIDEO_FRAGMENT [[NSBundle mainBundle] pathForResource:@"video1Shader" ofType:@"fsh"]




@interface video1ShaderTest : NSObject

-(instancetype)initWithImage:(UIImage*)image;

-(void)draw;

@end
