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


#define H_HEART_VERTEX [[NSBundle mainBundle] pathForResource:@"heartShader" ofType:@"vsh"]
#define H_HEART_FRAGMENT [[NSBundle mainBundle] pathForResource:@"heartShader" ofType:@"fsh"]



#define H_SPLITE_VERTEX [[NSBundle mainBundle] pathForResource:@"spliteShader" ofType:@"vsh"]
#define H_SPLITE_FRAGMENT [[NSBundle mainBundle] pathForResource:@"spliteShader" ofType:@"fsh"]





@interface HeartShaderTest : NSObject

-(instancetype)initWithImage:(UIImage*)image;

-(void)draw;

@end
