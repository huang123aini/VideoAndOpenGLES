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


#define H_CIRCLE_VERTEX [[NSBundle mainBundle] pathForResource:@"circleShader" ofType:@"vsh"]
#define H_CIRCLE_FRAGMENT [[NSBundle mainBundle] pathForResource:@"circleShader" ofType:@"fsh"]




@interface CircleShaderTest : NSObject

-(instancetype)initWithImage:(UIImage*)image;

-(void)draw;

@end
