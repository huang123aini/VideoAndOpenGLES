//
//  HCVPixelBufferInput.m
//  HTools
//
//  Created by huangshiping on 2017/6/13.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HCVPixelBufferInput.h"
#import "HMacros.h"

@interface HCVPixelBufferInput ()

@property(nonatomic,assign) GLuint renderTexture_input;

@property(nonatomic,nullable,assign) CVOpenGLESTextureRef lumaTexture;

@property(nonatomic,nullable,assign) CVOpenGLESTextureRef chromaTexture;

@property(nonatomic,nullable,assign) CVOpenGLESTextureCacheRef textureCache;

@property(nonatomic,assign) CVPixelBufferRef pixelBufferRef;

@property(nonatomic,assign) OSType pixelFormatType;


@end

@implementation HCVPixelBufferInput

- (instancetype)init
{
    if (self = [super initWithFragmentShader:H_CVPIXELBUFFER_FRAGMENT_SHADER])
    {
        
    }
    return self;
}


-(void)initTexureCacheIfNeed
{
    
    if(_textureCache==NULL)
    {
        
        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL,_glContext, NULL, &_textureCache);
        NSAssert(err==kCVReturnSuccess, @"创建纹理缓冲区失败%i",err);
    }
    
}


-(void)innerUploadPixelBufferToTexture
{
    
    CVPixelBufferLockBaseAddress(_pixelBufferRef, 0);
    
    size_t width= CVPixelBufferGetWidth(_pixelBufferRef);
    
    size_t height=CVPixelBufferGetHeight(_pixelBufferRef);
    
    self.size=CGSizeMake(width, height);
    
    _pixelFormatType= CVPixelBufferGetPixelFormatType(_pixelBufferRef);
    
    CVOpenGLESTextureCacheRef textureCacheRef=_textureCache;
    
    [self cleanUpTextures];
    
    // Y-plane
    glActiveTexture(GL_TEXTURE0);
    CVReturn err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                                textureCacheRef,
                                                                _pixelBufferRef,
                                                                NULL,
                                                                GL_TEXTURE_2D,
                                                                GL_LUMINANCE,
                                                                (int)width,
                                                                (int)height,
                                                                GL_LUMINANCE,
                                                                GL_UNSIGNED_BYTE,
                                                                0,
                                                                &_lumaTexture);
    if (err)
    {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
    
    [self bindTexture:CVOpenGLESTextureGetName(_lumaTexture)];
    
    // UV-plane
    glActiveTexture(GL_TEXTURE1);
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       textureCacheRef,
                                                       _pixelBufferRef,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_LUMINANCE_ALPHA,
                                                       (int)width/2,
                                                       (int)height/2,
                                                       GL_LUMINANCE_ALPHA,
                                                       GL_UNSIGNED_BYTE,
                                                       1,
                                                       &_chromaTexture);
    if (err)
    {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
    
    [self bindTexture:CVOpenGLESTextureGetName(_chromaTexture)];
    
    CVPixelBufferUnlockBaseAddress(_pixelBufferRef, 0);
    
    self.textureAvailable=YES;
    
}

-(void)uploadCVPixelBuffer:(CVPixelBufferRef)pixelBufferRef
{
    
    //TODO:where to release pixelBufferRef
    
    OSType pixelFormate= CVPixelBufferGetPixelFormatType(pixelBufferRef);
    
    NSAssert(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange==pixelFormate||kCVPixelFormatType_420YpCbCr8BiPlanarFullRange==pixelFormate, @"YDGLOperationCVPixelBufferSourceNode now only support NV12");
    
    CVPixelBufferRetain(pixelBufferRef);
    
    CVPixelBufferRelease(_pixelBufferRef);
    
    _pixelBufferRef=pixelBufferRef;
    
    self.textureAvailable=NO;
    
}


-(void)prepareForRender
{
    
    [self initTexureCacheIfNeed];
    
    if (_renderTexture_input==0)
    {
        
        glGenTextures(1, &_renderTexture_input);
    }
    
    if (self.textureAvailable==NO)
    {
        
        [self innerUploadPixelBufferToTexture];
        
        
        switch (_pixelFormatType)
        {
            case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
            {
                
                [self setBool:NO forUniformName:@"isFullRange"];
                
            }
                break;
            case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange:
            {
                
                [self setBool:YES forUniformName:@"isFullRange"];
            }
                
                break;
                
            default:
                break;
        }
        
        
        CFTypeRef colorAttachments = CVBufferGetAttachment(_pixelBufferRef, kCVImageBufferYCbCrMatrixKey, NULL);
        if (colorAttachments != NULL)
        {
            if(CFStringCompare(colorAttachments, kCVImageBufferYCbCrMatrix_ITU_R_601_4, 0) == kCFCompareEqualTo)
            {
                
                [self setBool:NO forUniformName:@"isBT709"];
            }
            else
            {
                [self setBool:YES forUniformName:@"isBT709"];
            }
        }
        
    }
}

-(void)setupTextureForProgram:(GLuint)program
{
    
    GLint location_texture_Y=[_drawModel locationOfUniform:@"SamplerY"];
    
    glActiveTexture(GL_TEXTURE0);
    
    [HESNode bindTexture:CVOpenGLESTextureGetName(_lumaTexture)];
    
    glUniform1i(location_texture_Y, 0);
    
    GLint location_texture_UV=[_drawModel locationOfUniform:@"SamplerUV"];
    
    glActiveTexture(GL_TEXTURE1);
    
    [HESNode bindTexture:CVOpenGLESTextureGetName(_chromaTexture)];
    
    glUniform1i(location_texture_UV, 1);
}

- (void)cleanUpTextures
{
    if (_lumaTexture)
    {
        CFRelease(_lumaTexture);
        _lumaTexture = NULL;
    }
    
    if (_chromaTexture)
    {
        CFRelease(_chromaTexture);
        _chromaTexture = NULL;
    }
    
}

-(void)dealloc
{
    
    if (_textureCache)
    {
        
        CVOpenGLESTextureCacheFlush(_textureCache, 0);
        CFRelease(_textureCache);
        _textureCache=NULL;
    }
    
}

-(void)destoryEAGLResource
{
    
    [super destoryEAGLResource];
    glDeleteTextures(1, &_renderTexture_input);
    [self cleanUpTextures];
    
}


@end
