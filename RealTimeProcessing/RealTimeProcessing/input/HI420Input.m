//
//  HI420Input.m
//  HTools
//
//  Created by huangshiping on 2017/6/13.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HI420Input.h"
#import "HMacros.h"

@interface HI420Input()

@property(nonatomic,assign)GLuint textureY;
@property(nonatomic,assign)GLuint textureU;
@property(nonatomic,assign)GLuint textureV;

@property(nonatomic,assign)uint8_t*baseAddress;
@property(nonatomic,assign)CGSize imageSize;
@property(nonatomic,assign)size_t dataSize;

@end

@implementation HI420Input

- (instancetype)init
{
    if (self = [super initWithFragmentShader:H_I420_FRAGMENT_SHADER])
    {
        
    }
    return self;
}

-(void)uploadI420Data:(uint8_t *)baseAddress andDataSize:(size_t)dataSize andImageSize:(CGSize)imageSize
{
    
    self.baseAddress=baseAddress;
    self.dataSize=dataSize;
    self.imageSize=imageSize;
    
}

-(void)innerUpload
{
    
    if (_textureY==0)
    {
        
        GLuint *tmp=malloc(sizeof(GLuint)*3);
        
        glGenTextures(3, tmp);
        
        _textureY=tmp[0];
        
        _textureU=tmp[1];
        
        _textureV=tmp[2];
        
        free(tmp);
        
    }
    
    glActiveTexture(GL_TEXTURE0);
    [self bindTexture:_textureY];
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, _imageSize.width, _imageSize.height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE,_baseAddress);
    
    
    glActiveTexture(GL_TEXTURE1);
    [self bindTexture:_textureU];
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, _imageSize.width/2, _imageSize.height/2, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE,_baseAddress+(int)(_imageSize.width*_imageSize.height));
    
    glActiveTexture(GL_TEXTURE2);
    [self bindTexture:_textureV];
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, _imageSize.width/2, _imageSize.height/2, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE,_baseAddress+(int)(_imageSize.width*_imageSize.height+_imageSize.width*_imageSize.height/4));
    
    self.size=self.imageSize;
    self.textureAvailable=YES;
    
    
}

-(void)setupTextureForProgram:(GLuint)program
{
    
    GLint location_texture_Y=[_drawModel locationOfUniform:@"SamplerY"];
    glActiveTexture(GL_TEXTURE0);
    [HESNode bindTexture:_textureY];
    glUniform1i(location_texture_Y, 0);
    
    
    
    GLint location_texture_U=[_drawModel locationOfUniform:@"SamplerU"];
    glActiveTexture(GL_TEXTURE1);
    [HESNode bindTexture:_textureU];
    glUniform1i(location_texture_U, 1);
    
    
    GLint location_texture_V=[_drawModel locationOfUniform:@"SamplerV"];
    glActiveTexture(GL_TEXTURE2);
    [HESNode bindTexture:_textureV];
    glUniform1i(location_texture_V, 2);
    
}

-(void)prepareForRender
{
    [self innerUpload];
}

-(void)destoryEAGLResource
{
    
    glDeleteTextures(1, &_textureY);
    _textureY=0;
    
    glDeleteTextures(1, &_textureU);
    _textureU=0;
    
    glDeleteTextures(1, &_textureV);
    _textureV=0;
    
}

@end
