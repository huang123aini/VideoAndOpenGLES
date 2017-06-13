//
//  HCGContextInput.m
//  HTools
//
//  Created by huangshiping on 2017/6/13.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HCGContextInput.h"

@interface HCGContextInput()

@property(nonatomic,assign)CGContextRef context;

@property(nonatomic,assign) GLuint renderTexture_input;

@property(nonatomic,assign)GLubyte *baseAddress;


@end

@implementation HCGContextInput

- (instancetype)init
{
    
    return [self initWithSize:CGSizeMake(100, 100)];//default size is (100,100)
    
}

-(instancetype)initWithSize:(CGSize)size
{
    
    if (self=[super init])
    {
        
        self.size=size;
        
        [self commonInitialization_cgcontext];
        
        return self;
    }
    
    return nil;
}

-(void)commonInitialization_cgcontext
{
    
    CGColorSpaceRef genericRGBColorspace = CGColorSpaceCreateDeviceRGB();
    
    _baseAddress=(GLubyte*)calloc(1,sizeof(GLubyte)*self.size.width*self.size.height*4);
    
    _context = CGBitmapContextCreate(_baseAddress, (int)self.size.width,(int)self.size.height, 8,(int)self.size.width * 4, genericRGBColorspace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    //init CGContext config
    
    CGContextSetStrokeColorWithColor(_context, [UIColor greenColor].CGColor);
    
    CGContextSetFillColorWithColor(_context, [UIColor greenColor].CGColor);
    
    
    CGContextSetLineWidth(_context, 1.0);
    
    
}


-(void)commitCGContextTransaction:(void (^)(CGContextRef))drawBlock
{
    
    [self invalidateNodeContent];
    
    [self clearContext];
    
    if (drawBlock)
    {
        CGContextSaveGState(_context);
        drawBlock(_context);
        CGContextRestoreGState(_context);
    }
}

-(void)clearContext
{
    
    CGContextClearRect(_context, CGRectMake(0, 0, self.size.width, self.size.height));
    
}

-(void)innerUploadCGContextToTexture
{
    
    
    [self bindTexture:_renderTexture_input];
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)self.size.width, (int)self.size.height, 0, GL_BGRA, GL_UNSIGNED_BYTE, _baseAddress);
    
    self.textureAvailable=YES;
    
}

-(void)setupTextureForProgram:(GLuint)program
{
    
    GLint location_s_texture=[_drawModel locationOfUniform:UNIFORM_INPUTTEXTURE];
    
    glActiveTexture(GL_TEXTURE0);
    
    [HESNode bindTexture:_renderTexture_input];
    
    glUniform1i ( location_s_texture,0);
    
}

-(void)prepareForRender
{
    
    if (_renderTexture_input==0)
    {
        
        glGenTextures(1, &_renderTexture_input);
    }
    
    if (self.textureAvailable==NO)
    {
        
        [self innerUploadCGContextToTexture];
        
    }
    
}

-(void)dealloc
{
    
    CGContextRelease(_context);
    
    _context=NULL;
    
    free(_baseAddress);
    
    _baseAddress=0;
}

-(void)destoryEAGLResource
{
    
    [super destoryEAGLResource];
    glDeleteTextures(1, &_renderTexture_input);
    _renderTexture_input=0;
}


@end
