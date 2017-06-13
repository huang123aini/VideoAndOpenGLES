//
//  HESModel.h
//  HTools
//
//  Created by huangshiping on 2017/6/12.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

struct ArrayWrapper
{
    
    const void * _Nullable pointer;
    const GLsizeiptr       size;
    const int              count;
};


@interface HESModel : NSObject

@property(nonatomic,assign)GLuint program;

@property(nonatomic,assign,readonly) GLuint verticesBuffer;

@property(nonatomic,assign,readonly) GLuint textureBuffer;

@property(nonatomic,assign,readonly) GLuint indicesBuffer;

@property(nonatomic,assign,readonly) int    verticesCount;

@property(nonatomic,assign,readonly) int    textureVerticesCount;
@property(nonatomic,assign,readonly) int    indicesCount;

@property(nonatomic,assign,readonly) GLenum drawStyle;

@property(nonatomic,copy)NSString* _Nullable vShaderFile;
@property(nonatomic,copy)NSString* _Nullable fShaderFile;

-(void)loadIfNeed;

-(void)setVShader:(NSString*_Nullable)vShaderFile fShader:(NSString*_Nullable)fShaderFile;


-(void)loadSquareVex:(const GLfloat [_Nullable 12])vertices_position andTextureCoord:(const GLfloat[_Nullable 8])textureCoord;
-(void)loadSquareVex:(const GLfloat[_Nullable 12])vertices_position;
-(void)loadSquareVex;
-(void)loadCubeVex;

-(GLint)locationOfUniform:(NSString*_Nonnull)uniformName;



@end
