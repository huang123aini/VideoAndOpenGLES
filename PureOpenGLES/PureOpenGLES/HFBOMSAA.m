//
//  HFBOMSAA.m
//  PureOpenGLES
//
//  Created by huangshiping on 2017/6/14.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HFBOMSAA.h"

#import <OpenGLES/ES2/glext.h>

#define N_FBOS 2
#define N_RBOS 2
enum
{
    FBO_MULTISAMPLE = 0,
    FBO_RESOLVED
};
enum
{
    RBO_COLOR = 0,
    RBO_DEPTH
};

#pragma mark

@interface HFBOMSAA ()
{
    GLuint _fbos[N_FBOS];
    GLuint _rbos[N_RBOS];
}

@property (assign, nonatomic) GLsizei samples;

@end

#pragma mark

@implementation HFBOMSAA

- (id)initWithWidth:(GLsizei)width height:(GLsizei)height
{
    return [self initWithWidth:width height:height samples:4];
}

- (id)initWithWidth:(GLsizei)width height:(GLsizei)height samples:(GLsizei)samples
{
    if (self = [super initWithWidth:width height:height])
    {
        _samples = samples;
        
        glGenTextures(1, &_fboTexture);
        glGenFramebuffers(N_FBOS, _fbos);
        glGenRenderbuffers(N_RBOS, _rbos);
        
        glBindRenderbuffer(GL_RENDERBUFFER, _rbos[RBO_DEPTH]);
        glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, samples, GL_DEPTH_COMPONENT24_OES, width, height);
        
        glBindRenderbuffer(GL_RENDERBUFFER, _rbos[RBO_COLOR]);
        glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, samples, GL_RGBA8_OES, width, height);
        
        glBindFramebuffer(GL_FRAMEBUFFER, _fbos[FBO_MULTISAMPLE]);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _rbos[RBO_DEPTH]);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _rbos[RBO_COLOR]);
        GLenum fboStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (fboStatus != GL_FRAMEBUFFER_COMPLETE)
        {
            NSLog(@"Capture multisample framebuffer is not complete: %x", fboStatus);
            return nil;
        }
        
        glBindTexture(GL_TEXTURE_2D, _fboTexture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
        
        glBindFramebuffer(GL_FRAMEBUFFER, _fbos[FBO_RESOLVED]);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _fboTexture, 0);
        fboStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (fboStatus != GL_FRAMEBUFFER_COMPLETE)
        {
            NSLog(@"Capture resolved framebuffer is not complete: %x", fboStatus);
            return nil;
        }
        
        glBindTexture(GL_TEXTURE_2D, 0);
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }
    return self;
}

- (void)dealloc
{
    glDeleteFramebuffers(N_FBOS, _fbos);
    glDeleteTextures(1, &_fboTexture);
    glDeleteRenderbuffers(N_RBOS, _rbos);
}

- (GLuint)texture
{
    glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, _fbos[FBO_MULTISAMPLE]);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, _fbos[FBO_RESOLVED]);
    
    // Apple (and the khronos group) encourages you to discard depth
    // render buffer contents whenever is possible
    GLenum attachments[] = {GL_DEPTH_ATTACHMENT, GL_COLOR_ATTACHMENT0};
    glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 2, attachments);
    
    glResolveMultisampleFramebufferAPPLE();
    
    return _fboTexture;
}

- (void)prepareToDraw
{
    if (self.changed)
    {
        glBindRenderbuffer(GL_RENDERBUFFER, _rbos[RBO_DEPTH]);
        glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, _samples, GL_DEPTH_COMPONENT24_OES, self.width, self.height);
        glBindRenderbuffer(GL_RENDERBUFFER, _rbos[RBO_COLOR]);
        glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, _samples, GL_RGBA8_OES, self.width, self.height);
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
        glBindTexture(GL_TEXTURE_2D, _fboTexture);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, self.width, self.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
        glBindTexture(GL_TEXTURE_2D, 0);
        self.changed = NO;
    }
    
   
}

-(void)bindFBO
{
    glBindFramebuffer(GL_FRAMEBUFFER, _fbos[FBO_MULTISAMPLE]);
}

-(void)unbindFBO
{
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}


-(void)drawFBO
{
    glViewport(0, 0, self.width, self.height);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}


@end

