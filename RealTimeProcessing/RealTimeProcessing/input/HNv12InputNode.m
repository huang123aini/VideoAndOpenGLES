//
//  HNv12InputNode.m
//  HTools
//
//  Created by huangshiping on 2017/6/13.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HNv12InputNode.h"
#import "HMacros.h"


@interface HNv12InputNode()

@property(nonatomic,assign)GLuint   textureY;
@property(nonatomic,assign)GLuint   textureUV;

@property(nonatomic,assign)uint8_t* baseAddress;

@property(nonatomic,assign)CGSize   imageSize;

@property(nonatomic,assign)size_t   dataSize;

@end

@implementation HNv12InputNode

- (instancetype)init
{
    if (self = [super initWithFragmentShader:H_NV12_FRAGMENT_SHADER])
    {
        
    }
    return self;
}


-(void)uploadNV12Data:(uint8_t *)baseAddress andDataSize:(size_t)dataSize andImageSize:(CGSize)imageSize
{
    self.baseAddress=baseAddress;
    self.dataSize=dataSize;
    self.imageSize=imageSize;
}

-(void)innerUpload
{
    
    if (_textureY==0)
    {
        
        GLuint *tmp=malloc(sizeof(GLuint)*2);
        
        glGenTextures(2, tmp);
        
        _textureY=tmp[0];
        
        _textureUV=tmp[1];
        
        free(tmp);
        
    }
    
    glActiveTexture(GL_TEXTURE0);
    
    [self bindTexture:_textureY];
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, _imageSize.width, _imageSize.height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE,_baseAddress);
    glActiveTexture(GL_TEXTURE1);
    [self bindTexture:_textureUV];
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE_ALPHA, _imageSize.width/2, _imageSize.height/2, 0, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE,_baseAddress+(int)(_imageSize.width*_imageSize.height));
    
    self.size=self.imageSize;
    
    self.textureAvailable=YES;
    
    
}

-(void)setupTextureForProgram:(GLuint)program
{
    
    GLint location_texture_Y=[_drawModel locationOfUniform:@"SamplerY"];
    
    glActiveTexture(GL_TEXTURE0);
    
    [HESNode bindTexture:_textureY];
    
    glUniform1i(location_texture_Y, 0);
    
    GLint location_texture_UV=[_drawModel locationOfUniform:@"SamplerUV"];
    
    glActiveTexture(GL_TEXTURE1);
    
    [HESNode bindTexture:_textureUV];
    
    glUniform1i(location_texture_UV, 1);
    
}

-(void)prepareForRender
{
    
    [self innerUpload];
}

-(void)destoryEAGLResource
{
    glDeleteTextures(1, &_textureY);
    _textureY=0;
    glDeleteTextures(1, &_textureUV);
    _textureUV=0;
    
}


-(void)setBT709:(BOOL)yes
{
    [self setInt:yes==YES?1:0 forUniformName:@"isBT709"];
}

-(void)setFullRange:(BOOL)fullRange
{
    
    [self setInt:fullRange==YES?1:0 forUniformName:@"isFullRange"];
    
}

@end
