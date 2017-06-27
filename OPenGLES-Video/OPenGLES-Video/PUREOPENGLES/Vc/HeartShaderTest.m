//
//  ImageVBO.m
//  OPenGLES-Video
//
//  Created by huangshiping on 2017/6/19.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HeartShaderTest.h"

#import <GLKit/GLKit.h>


@interface HeartShaderTest()
{
    GLuint          _program;
    GLuint          _vbo;
    GLuint          _texture;
    int             _vertCount;
    
    UIImage*        _image;
}

@end

@implementation HeartShaderTest

-(instancetype)initWithImage:(UIImage*)image
{
    if (self = [super init])
    {
        _image = image;
        [self setupGL];
    }
    return self;
}

-(void)setupGL
{
    
    //1.
    _texture = [HGLUtils createTextureWithImage:_image];
    //2.
    _program = [HGLUtils compileShaders:H_SPLITE_VERTEX shaderFragment:H_SPLITE_FRAGMENT];
    
    
    //3.
    GLfloat vertices[] =
    {
        -1.f, -1.f, 0.0f,  0.0f, 1.0f,  // 左下
        1.f, -1.f, 0.0f,   1.0f, 1.0f,  // 右下
        -1.f,  1.f, 0.0f,  0.0f, 0.0f,  // 左上
        1.f,  1.f, 0.0f,   1.0f, 0.0f,  // 右上
        
    };
    
    
    glUseProgram(_program);
    
    glGenBuffers(1, &_vbo);
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    
    glEnableVertexAttribArray(glGetAttribLocation(_program, "aPosition"));
    glVertexAttribPointer(glGetAttribLocation(_program, "aPosition"), 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL);
    
    glEnableVertexAttribArray(glGetAttribLocation(_program, "aTexCoord"));
    glVertexAttribPointer(glGetAttribLocation(_program, "aTexCoord"), 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL+sizeof(GL_FLOAT)*3);
    
}

-(void)draw
{
    static float globalTime = 0.0f;
    
    glUseProgram(_program);
    
    glEnableVertexAttribArray(glGetAttribLocation(_program, "aPosition"));
    glVertexAttribPointer(glGetAttribLocation(_program, "aPosition"), 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL);
    
    glEnableVertexAttribArray(glGetAttribLocation(_program, "aTexCoord"));
    glVertexAttribPointer(glGetAttribLocation(_program, "aTexCoord"), 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL+sizeof(GL_FLOAT)*3);
    
    
    
    globalTime += 1/60.0f;
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glUniform1i(glGetUniformLocation(_program, "uSampler"), 0);
    
    glUniform1f(glGetUniformLocation(_program,"uTime"), globalTime);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

-(void)dealloc
{
    
    glDeleteBuffers(1, &_vbo);
    glDeleteTextures(1, &_texture);
    glDeleteProgram(_program);
    
}
@end
