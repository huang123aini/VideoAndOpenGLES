//
//  HGLUtils.m
//  HTools
//
//  Created by huangshiping on 2017/6/1.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HGLUtils.h"

@implementation HGLUtils

+ (GLuint)compileShaders:(NSString *)shaderVertex shaderFragment:(NSString *)shaderFragment
{
    GLuint vertShader, fragShader;
    
    // Create and compile vertex shader.
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:shaderVertex])
    {
        HLog(@"Failed to compile vertex shader :Shader Name is:%@",shaderVertex);
        return NO;
    }
    
    // Create and compile fragment shader.
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:shaderFragment])
    {
        HLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // 连接vertex和fragment shader成一个完整的program
    
    GLuint _glProgram = glCreateProgram();
    glAttachShader(_glProgram, vertShader);
    glAttachShader(_glProgram, fragShader);
    
    // Link program.
    if (![self linkProgram:_glProgram])
    {
        HLog(@"Failed to link program: %d", _glProgram);
        
        if (vertShader)
        {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader)
        {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_glProgram)
        {
            glDeleteProgram(_glProgram);
            _glProgram = 0;
        }
        
        return NO;
    }
    
    // Release vertex and fragment shaders.
    if (vertShader)
    {
        glDetachShader(_glProgram, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader)
    {
        glDetachShader(_glProgram, fragShader);
        glDeleteShader(fragShader);
    }
    
    return _glProgram;
}

+ (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source)
    {
        HLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        HLog(@"Shader compile log:\n%s", log);
        free(log);
    }
    
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        
        GLint logLength;
        glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength <= 0)
        {
            GLchar *log = (GLchar *)malloc(logLength);
            glGetShaderInfoLog(*shader, logLength, &logLength, log);
            HLog(@"Shader compile log:\n%s", log);
            free(log);
        }
        
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

+ (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        HLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
    {
        return NO;
    }
    
    return YES;
}



+(GLuint)createVBO:(GLenum)target usage:(int)usage dataSize:(int)dataSize data:(void*)data;

{
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(target, vbo);
    glBufferData(target, dataSize, data, usage);
    return vbo;
}

-(GLuint)createTextureWithImage:(UIImage*)image
{
    CGImageRef spriteImage = image.CGImage;
    GLuint width = (GLuint)CGImageGetWidth(spriteImage);
    GLuint height = (GLuint)CGImageGetHeight(spriteImage);
    GLubyte *spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    CGContextRelease(spriteContext);
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    free(spriteData);
    return texName;
}


#pragma mark ----根据AspectRatio填充----------

CGSize _ASSizeFillWithAspectRatio(CGFloat sizeToScaleAspectRatio, CGSize destinationSize)
{
    CGFloat destinationAspectRatio = destinationSize.width / destinationSize.height;
    if (sizeToScaleAspectRatio > destinationAspectRatio)
    {
        return CGSizeMake(destinationSize.height * sizeToScaleAspectRatio, destinationSize.height);
    } else
    {
        return CGSizeMake(destinationSize.width, round(destinationSize.width / sizeToScaleAspectRatio));
    }
}

CGSize _ASSizeFitWithAspectRatio(CGFloat aspectRatio, CGSize constraints)
{
    CGFloat constraintAspectRatio = constraints.width / constraints.height;
    if (aspectRatio > constraintAspectRatio)
    {
        return CGSizeMake(constraints.width, constraints.width / aspectRatio);
    } else
    {
        return CGSizeMake(constraints.height * aspectRatio, constraints.height);
    }
}



@end
