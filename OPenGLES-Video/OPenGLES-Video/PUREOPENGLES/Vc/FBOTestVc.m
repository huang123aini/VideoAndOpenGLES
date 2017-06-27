//
//  FBOTestVc.m
//  OPenGLES-Video
//
//  Created by huangshiping on 2017/6/19.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "FBOTestVc.h"
#import <PureOpenGLES/HFBO.h>

#import <PureOpenGLES/HFBO.h>

#import <RealTimeProcessing/HGLUtils.h>

#import "ImageVBO.h"

#import "CircleShaderTest.h"

#import "HeartShaderTest.h"

#import "video1ShaderTest.h"




#define H_FBO_VERTEX [[NSBundle mainBundle] pathForResource:@"fboShader" ofType:@"vsh"]
#define H_FBO_FRAGMENT [[NSBundle mainBundle] pathForResource:@"fboShader" ofType:@"fsh"]




@interface FBOTestVc ()

@property (nonatomic, strong) EAGLContext *context;

@property(nonatomic,strong)HFBO*     fbo;
@property(nonatomic,assign)GLuint    fboProgram;
@property(nonatomic,assign)GLuint    fboVbo;

@property(nonatomic,strong)ImageVBO* imageVBO;



@property(nonatomic,strong)HeartShaderTest*   heartShaderTest;
@property(nonatomic,strong)CircleShaderTest*  circleShaderTest;

@property(nonatomic,strong)video1ShaderTest*  video1Test;



@end

@implementation FBOTestVc

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context)
    {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    self.preferredFramesPerSecond = 60;
    
    [self setupGL];
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    //生成FBO
    
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    self.fbo = [HFBO generateFBO:FBO_NONE width:self.view.frame.size.width * screenScale  height:self.view.frame.size.height * screenScale];
    
    self.fboProgram = [HGLUtils compileShaders:H_FBO_VERTEX shaderFragment:H_FBO_FRAGMENT];
    
    GLfloat vertices[] =
    {
        -0.5f, -0.5f, 0.0f,  0.0f, 0.0f,  // 左下
        0.5f, -0.5f, 0.0f,  1.0f, 0.0f,  // 右下
        -0.5f,  0.5f, 0.0f,  0.0f, 1.0f,  // 左上
        0.5f,  0.5f, 0.0f,  1.0f, 1.0f,  // 右上
        
    };
    
    glGenBuffers(1, &_fboVbo);
    glBindBuffer(GL_ARRAY_BUFFER, _fboVbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    
    glEnableVertexAttribArray(glGetAttribLocation(self.fboProgram, "aPosition"));
    glVertexAttribPointer(glGetAttribLocation(self.fboProgram, "aPosition"), 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL);
    
    glEnableVertexAttribArray(glGetAttribLocation(self.fboProgram, "aTexCoord"));
    glVertexAttribPointer(glGetAttribLocation(self.fboProgram, "aTexCoord"), 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL+sizeof(GL_FLOAT)*3);
    

   // self.imageVBO = [[ImageVBO alloc] initWithImage:[UIImage imageNamed:@"timg.jpg"]];
    
    
    //self.circleShaderTest = [[CircleShaderTest alloc] initWithImage:[UIImage imageNamed:@"timg.jpg"]];
    
   // self.heartShaderTest = [[HeartShaderTest alloc] initWithImage:[UIImage imageNamed:@"timg.jpg"]];
    
    self.video1Test = [[video1ShaderTest alloc] initWithImage:[UIImage imageNamed:@"timg.jpg"]];
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    
    
//    //1.
//    [self.fbo prepareToDraw];
//    
//    //绑定FBO
//    [self.fbo bindFBO];
//    
    //绘制场景到FBO
    {
      GLfloat scale = [UIScreen mainScreen].scale;
      glViewport(0, 0, self.view.frame.size.width * scale, self.view.frame.size.height * scale);
      glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
     // [self.imageVBO draw];
     //[self.circleShaderTest draw];
       // [self.heartShaderTest draw];
        
        [self.video1Test draw];
        
    }
//    //解绑FBO
//    [self.fbo unbindFBO];
//    
//    [((GLKView *) self.view) bindDrawable];
//    
//    
//    //5
//    glUseProgram(_fboProgram);
//    glEnableVertexAttribArray(glGetAttribLocation(self.fboProgram, "aPosition"));
//    glVertexAttribPointer(glGetAttribLocation(self.fboProgram, "aPosition"), 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL);
//    
//    glEnableVertexAttribArray(glGetAttribLocation(self.fboProgram, "aTexCoord"));
//    glVertexAttribPointer(glGetAttribLocation(self.fboProgram, "aTexCoord"), 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL+sizeof(GL_FLOAT)*3);
//    
//    // 激活纹理
//    glActiveTexture(GL_TEXTURE0);
//    glBindTexture(GL_TEXTURE_2D, self.fbo.fboTexture);
//    glUniform1i(glGetUniformLocation(self.fboProgram, "uSampler"), 0);
//    glUniformMatrix4fv(glGetUniformLocation(self.fboProgram, "uMvpMatrix"), 1, 0, GLKMatrix4Identity.m);
//
//    [self.fbo drawFBO];
//    
//    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}
@end
