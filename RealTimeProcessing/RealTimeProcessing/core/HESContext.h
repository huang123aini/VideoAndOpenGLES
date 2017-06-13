//
//  HESContext.h
//  HTools
//
//  Created by huangshiping on 2017/6/12.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/EAGL.h>
#import <CoreVideo/CoreVideo.h>

@interface HESContext : NSObject

+(void)pushContext;

+(EAGLContext*_Nullable)currentGLContext;

+(void)popContext;

@end
