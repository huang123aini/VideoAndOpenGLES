//
//  HNodeOutput.h
//  HTools
//
//  Created by huangshiping on 2017/6/12.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface HNodeOutput : NSObject

@property(nonatomic,assign)GLuint texture;//

@property(nonatomic,assign)GLuint frameBuffer;

@property(nonatomic,assign)CGSize size;//

@property(nonatomic,nullable,assign)CVPixelBufferRef pixelBuffer;

@end
