//
//  HESProgram.h
//  HTools
//
//  Created by huangshiping on 2017/6/12.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface HESProgram : NSObject

@property(nonatomic,assign)GLuint program;

@property(nonatomic,assign)GLuint aPosition;
@property(nonatomic,assign)GLuint aColor;
@property(nonatomic,assign)GLuint aTexCoord;
@property(nonatomic,assign)GLuint aNormal;

@property(nonatomic,assign)GLuint uModelViewProjectionMatrix;
@property(nonatomic,assign)GLuint uSampler;


- (void)loadShaders:(NSString *)vertShader FragShader:(NSString *)fragShader;
- (void)useProgram;

//绑定Attributes And Uniforms 
-(void)setupAttributesAndUniforms;

@end
