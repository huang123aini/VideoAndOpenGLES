//
//  HESProgram.m
//  HTools
//
//  Created by huangshiping on 2017/6/12.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HESProgram.h"

#import "HGLUtils.h"

@implementation HESProgram

- (void)loadShaders:(NSString *)vertShader FragShader:(NSString *)fragShader
{
    self.program = [HGLUtils compileShaders:vertShader shaderFragment:fragShader];
}


-(void)setupAttributesAndUniforms
{
  //  glGetAttribLocation  and  glGetUniformLocation
}

- (void)useProgram
{
    glUseProgram(self.program);
}

-(void)dealloc
{
    if (self.program)
    {
        glDeleteProgram(self.program);
        self.program = 0;
    }
}

@end

