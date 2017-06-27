//
//  HFBO.h
//  PureOpenGLES
//
//  Created by huangshiping on 2017/6/13.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

/**
 *  FBO  USE:
//1. bindFBO
//2. draw Scene Node
//3. unbindFBO
//4. bind FBO Texture
//5. draw FBO Texture To Screen
*/
#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

typedef enum FBOType
{
    FBO_NONE = 0,
    FBO_MSAA
} FBOType;

@interface HFBO : NSObject
{
@protected
    GLuint _fboTexture;
}

- (id)initWithWidth:(GLsizei)width height:(GLsizei)height;

- (void)prepareToDraw;

-(void)bindFBO;

-(void)unbindFBO;

-(void)drawFBO;


@property (assign, nonatomic) GLsizei width;
@property (assign, nonatomic) GLsizei height;

@property (assign, nonatomic, readonly) GLuint fboTexture; //FBO Texture
@property (assign, nonatomic) BOOL changed;

+ (HFBO *)generateFBO:(FBOType)type width:(GLsizei)width height:(GLsizei)height;

@end
