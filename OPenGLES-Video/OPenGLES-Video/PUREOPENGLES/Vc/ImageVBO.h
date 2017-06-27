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

#define H_IMAGE_VERTEX [[NSBundle mainBundle] pathForResource:@"2dShader" ofType:@"vsh"]
#define H_IMAGE_FRAGMENT [[NSBundle mainBundle] pathForResource:@"2dShader" ofType:@"fsh"]





#define H_HEART_VERTEX [[NSBundle mainBundle] pathForResource:@"heartShader" ofType:@"vsh"]
#define H_HEART_FRAGMENT [[NSBundle mainBundle] pathForResource:@"heartShader" ofType:@"fsh"]




@interface ImageVBO : NSObject

-(instancetype)initWithImage:(UIImage*)image;

-(void)draw;

@end
