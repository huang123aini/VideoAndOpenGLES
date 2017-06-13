//
//  HImageInput.m
//  HTools
//
//  Created by huangshiping on 2017/6/13.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HImageInput.h"

#define  DEFAULT_IMAGE_PIXEL_FORMAT_TYPE kCVPixelFormatType_32BGRA

@interface HImageInput()

@property(nonatomic,assign) GLuint renderTexture_input;

@property(nonatomic,assign) OSType pixelFormatType;

@property(nonatomic,retain)NSMutableArray<UIImage*>*images;// frame animation support

@property(nonatomic,assign)BOOL animationable;

@property(nonatomic,nullable,retain) UIImage *image;

@end

@implementation HImageInput

#pragma -mark public

-(void)uploadImage:(UIImage *)image
{
    
    self.animationable=NO;
    [self innerUploadImage:image];
    
}

-(void)uploadAnimationableImages:(NSArray<UIImage *> *)images
{
    
    [self.images removeAllObjects];
    [self.images addObjectsFromArray:images];
    self.animationable=YES;
    [self innerUploadFrame];
    
}

-(void)drive
{
    
    [super drive];
    
    if (self.animationable)
    {
        [self innerUploadFrame];
    }
}

#pragma  -mark private

-(void)innerUploadFrame
{
    
    UIImage *firstFrame=[self.images firstObject];
    [self.images removeObjectAtIndex:0];
    [self.images addObject:firstFrame];
    [self innerUploadImage:firstFrame];
    
}

-(void)innerUploadImage:(UIImage*)image
{
    if (self.image==image)
    {
        return;
    }
    
    self.image=image;
    self.textureAvailable=NO;
    
}


-(void)commonInitialization
{
    [super commonInitialization];
    self.images=[NSMutableArray array];
    
}

-(void)innerUploadImageToTexture
{
    
    CGImageRef newImageSource=_image.CGImage;
    
    // TODO: Dispatch this whole thing asynchronously to move image loading off main thread
    CGFloat widthOfImage = CGImageGetWidth(newImageSource);
    CGFloat heightOfImage = CGImageGetHeight(newImageSource);
    
    // If passed an empty image reference, CGContextDrawImage will fail in future versions of the SDK.
    NSAssert( widthOfImage > 0 && heightOfImage > 0, @"Passed image must not be empty - it should be at least 1px tall and wide");
    
    CGSize pixelSizeOfImage = CGSizeMake(widthOfImage, heightOfImage);
    CGSize pixelSizeToUseForTexture = pixelSizeOfImage;
    
    BOOL shouldRedrawUsingCoreGraphics = NO;
    
    GLubyte *imageData = NULL;
    CFDataRef dataFromImageDataProvider = NULL;
    GLenum format = GL_BGRA;
    
    if (!shouldRedrawUsingCoreGraphics)
    {
        /* Check that the memory layout is compatible with GL, as we cannot use glPixelStore to
         * tell GL about the memory layout with GLES.
         */
        if (CGImageGetBytesPerRow(newImageSource) != CGImageGetWidth(newImageSource) * 4 ||
            CGImageGetBitsPerPixel(newImageSource) != 32 ||
            CGImageGetBitsPerComponent(newImageSource) != 8)
        {
            shouldRedrawUsingCoreGraphics = YES;
        } else
        {
            /* Check that the bitmap pixel format is compatible with GL */
            CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(newImageSource);
            if ((bitmapInfo & kCGBitmapFloatComponents) != 0) {
                /* We don't support float components for use directly in GL */
                shouldRedrawUsingCoreGraphics = YES;
            } else
            {
                CGBitmapInfo byteOrderInfo = bitmapInfo & kCGBitmapByteOrderMask;
                if (byteOrderInfo == kCGBitmapByteOrder32Little)
                {
                    /* Little endian, for alpha-first we can use this bitmap directly in GL */
                    CGImageAlphaInfo alphaInfo = bitmapInfo & kCGBitmapAlphaInfoMask;
                    if (alphaInfo != kCGImageAlphaPremultipliedFirst && alphaInfo != kCGImageAlphaFirst &&
                        alphaInfo != kCGImageAlphaNoneSkipFirst)
                    {
                        shouldRedrawUsingCoreGraphics = YES;
                    }
                } else if (byteOrderInfo == kCGBitmapByteOrderDefault || byteOrderInfo == kCGBitmapByteOrder32Big)
                {
                    /* Big endian, for alpha-last we can use this bitmap directly in GL */
                    CGImageAlphaInfo alphaInfo = bitmapInfo & kCGBitmapAlphaInfoMask;
                    if (alphaInfo != kCGImageAlphaPremultipliedLast && alphaInfo != kCGImageAlphaLast &&
                        alphaInfo != kCGImageAlphaNoneSkipLast)
                    {
                        shouldRedrawUsingCoreGraphics = YES;
                    } else
                    {
                        /* Can access directly using GL_RGBA pixel format */
                        format = GL_RGBA;
                    }
                }
            }
        }
    }
    
    if (shouldRedrawUsingCoreGraphics)
    {
        // For resized or incompatible image: redraw
        imageData = (GLubyte *) calloc(1, (int)pixelSizeToUseForTexture.width * (int)pixelSizeToUseForTexture.height * 4);
        
        CGColorSpaceRef genericRGBColorspace = CGColorSpaceCreateDeviceRGB();
        
        CGContextRef imageContext = CGBitmapContextCreate(imageData, (size_t)pixelSizeToUseForTexture.width, (size_t)pixelSizeToUseForTexture.height, 8, (size_t)pixelSizeToUseForTexture.width * 4, genericRGBColorspace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        //        CGContextSetBlendMode(imageContext, kCGBlendModeCopy); // From Technical Q&A QA1708: http://developer.apple.com/library/ios/#qa/qa1708/_index.html
        CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, pixelSizeToUseForTexture.width, pixelSizeToUseForTexture.height), newImageSource);
        CGContextRelease(imageContext);
        CGColorSpaceRelease(genericRGBColorspace);
    }
    else
    {
        // Access the raw image bytes directly
        dataFromImageDataProvider = CGDataProviderCopyData(CGImageGetDataProvider(newImageSource));
        
        imageData = (GLubyte *)CFDataGetBytePtr(dataFromImageDataProvider);
    }
    
    [self bindTexture:_renderTexture_input];
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)pixelSizeToUseForTexture.width, (int)pixelSizeToUseForTexture.height, 0, format, GL_UNSIGNED_BYTE, imageData);
    
    self.size=pixelSizeToUseForTexture;
    
    if (_pixelFormatType!=DEFAULT_IMAGE_PIXEL_FORMAT_TYPE)
    {
        _pixelFormatType=DEFAULT_IMAGE_PIXEL_FORMAT_TYPE;
        
    }
    
    
    if (shouldRedrawUsingCoreGraphics)
    {
        free(imageData);
    }
    else
    {
        if (dataFromImageDataProvider)
        {
            CFRelease(dataFromImageDataProvider);
        }
    }
    
    self.textureAvailable=YES;
    
}

#pragma -mark override

-(void)prepareForRender
{
    if (_renderTexture_input==0)
    {
        
        glGenTextures(1, &_renderTexture_input);
    }
    
    if (self.textureAvailable==NO)
    {
        [self innerUploadImageToTexture];
    }
    
}

-(void)setupTextureForProgram:(GLuint)program
{
    
    GLint location_s_texture=[_drawModel locationOfUniform:UNIFORM_INPUTTEXTURE];
    
    glActiveTexture(GL_TEXTURE0);
    
    [HESNode bindTexture:_renderTexture_input];
    
    glUniform1i ( location_s_texture,0);
    
}

-(void)destoryEAGLResource
{
    
    [super destoryEAGLResource];
    glDeleteTextures(1, &_renderTexture_input);
    _renderTexture_input=0;
}
@end
