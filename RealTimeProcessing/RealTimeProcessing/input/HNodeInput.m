//
//  HNodeInput.m
//  HTools
//
//  Created by huangshiping on 2017/6/13.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HNodeInput.h"

@implementation HNodeInput

-(void)drive
{
    
    [self activeGLContext:^{
        
        [self prepareForRender];
        
    } autoRestore:NO];
    
    [self performTraversalsIfCanWhenDependencyDone:self];

}

-(BOOL)canPerformTraversals
{
    
    return self.textureAvailable;//纹理准备好之后才可以遍历
}

-(void)prepareForRender
{
    
}

-(void)setupTextureForProgram:(GLuint)program
{
    
    NSAssert(NO, @"subclass of sourceNode should override 'setupTextureForProgram'");
    
}

-(void)setTextureCoord
{
    
    GLint location_texturecoord=glGetAttribLocation(_drawModel.program, [ATTRIBUTE_TEXTURE_COORDINATE UTF8String]);
    
    glEnableVertexAttribArray(location_texturecoord);
    
    glVertexAttribPointer(location_texturecoord, 2, GL_FLOAT, GL_FALSE,sizeof(GLfloat)*2,0);//纹理坐标
    
}

-(void)addDependency:(id<HESNode>)operation
{
    
    NSAssert(NO, @"YDGLOperationSourceNode must be as root Node");
    
}

-(void)invalidateNodeContent
{
    self.textureAvailable=NO;
    _outputData=nil;
}

-(void)bindTexture:(GLuint)textureId
{
    
    glBindTexture(GL_TEXTURE_2D, textureId);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
    
}

@end
