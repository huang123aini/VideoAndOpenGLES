//
//  HNodeImageView.m
//  HTools
//
//  Created by huangshiping on 2017/6/13.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HNodeImageView.h"
#import "HESContext.h"
#import "HGLUtils.h"

@import OpenGLES.ES2;
@import QuartzCore;
@import GLKit;

#define dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

@interface HNodeImageView()<HESNode>

@end

@implementation HNodeImageView
{
    
    CAEAGLLayer *_egallayer;
    
    EAGLContext *_context;
    
    GLuint _renderBuffer,_frameBuffer;//最终的缓冲区对象
    
    GLuint _textureId;
    
    CGSize _sizeInPixel;
    
    float _angle;
    
    HESModel *_drawModel;
    
    CGSize _inputImageSize;//要显示的纹理的大小
    
    NodeImageRotationMode _inputRotationMode;
    
    HESNode *_contentNode;
    
    BOOL _framebufferAvailable;// framebuffer available
    
}

+(Class)layerClass
{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    //fixed view's frame changed,should recreate renderbuffer and framebuffer
    _framebufferAvailable=NO;
    
}


#pragma -mark 初始化
-(void)commonInit
{
    
    _drawModel=[HESModel new];
    
    _sizeInPixel=self.bounds.size;
    
    _inputRotationMode=kNodeImageNoRotation;
    
    _fillMode=kNodeImageFillModePreserveAspectRatioAndFill;
    
    [self setupLayer];
    
    [self setupProgram];
    
}

-(void)setupLayer
{
    
    self.opaque = YES;
    self.hidden = NO;
    
    _egallayer=(CAEAGLLayer *)[self layer];
    _egallayer.opaque=YES;
    _egallayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking:@NO, kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
    
}

- (void)setupBufferIfNeed
{
    
    if (_framebufferAvailable) return;
    GLuint renderBuffers[1]={_renderBuffer};
    glDeleteRenderbuffers(1, renderBuffers);
    GLuint frameBuffers[1]={_frameBuffer};
    glDeleteFramebuffers(1,frameBuffers);
    
    glGenRenderbuffers(1, &_renderBuffer);
    // 设置为当前 renderbuffer
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    
    //为 color renderbuffer 分配存储空间
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_egallayer];
    
    GLint backingWidth, backingHeight;
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    _sizeInPixel=CGSizeMake((CGFloat)backingWidth,(CGFloat)backingHeight);
    
    glGenFramebuffers(1, &_frameBuffer);
    // 设置为当前 framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _renderBuffer);
    
    GLenum status= glCheckFramebufferStatus(GL_FRAMEBUFFER);
    
    assert(status==GL_FRAMEBUFFER_COMPLETE);
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    _framebufferAvailable=YES;
}

/**
 *  创建用于多重采样的缓冲区,用于offscreen 渲染
 */
//- (void)setupMSAABuffer {
//
//    glGenFramebuffers(1, &_resolveFrameBuffer);
//
//    glBindFramebuffer(GL_FRAMEBUFFER, _resolveFrameBuffer);
//
//    glGenRenderbuffers(1, &_resolveRenderBuffer);
//
//    glBindRenderbuffer(GL_RENDERBUFFER, _resolveRenderBuffer);
//
//    GLint max_samples;
//
//    glGetIntegerv(GL_MAX_SAMPLES_APPLE, &max_samples);
//
//    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER,max_samples,GL_RGBA8_OES, _sizeInPixel.width, _sizeInPixel.height);
//
//    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _resolveRenderBuffer);
//
//
//    glGenRenderbuffers(1, &_resolveDepthBuffer);
//
//    glBindRenderbuffer(GL_RENDERBUFFER, _resolveDepthBuffer);
//    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_DEPTH_COMPONENT16, _sizeInPixel.width , _sizeInPixel.height);
//    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _resolveDepthBuffer);
//
//    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE){
//
//        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
//
//    }
//
//    glBindRenderbuffer(GL_RENDERBUFFER, 0);
//
//    glBindFramebuffer(GL_FRAMEBUFFER, 0);
//
//}

-(void)setupProgram
{
    
    [_drawModel setVShader:H_VERTEX_SHADER fShader:H_FRAGMENT_SHADER ];
    
}

#pragma -mark 内部接口

-(void)activeGLContext:(void (^)(void))block
{
    
    EAGLContext *preContext=[EAGLContext currentContext];
    if (preContext==_context)
    {
        block();
        
    }else
    {
        
        [EAGLContext setCurrentContext:_context];
        
        block();
        
        [EAGLContext setCurrentContext:preContext];
    }
}

-(void)loadCubeVex
{
    
    [_drawModel loadCubeVex];
    
}

-(void)loadSquareByFillModeType
{
    
    float heightScaling, widthScaling;
    
    CGSize currentViewSize;
    CGSize fitSize;
    
    currentViewSize = self.bounds.size;
    
    fitSize=[self calculateSize:_inputImageSize aspectFill:self.bounds];
    
    switch(_fillMode)
    {
        case kNodeImageFillModeFillModeStretch:
        {
            widthScaling = 1.0;
            heightScaling = 1.0;
        }; break;
        case kNodeImageFillModePreserveAspectRatio:
        {
            widthScaling  = fitSize.width / currentViewSize.width;
            heightScaling = fitSize.height / currentViewSize.height;
        }; break;
        case kNodeImageFillModePreserveAspectRatioAndFill:
        {
            widthScaling = currentViewSize.height / fitSize.height;
            heightScaling = currentViewSize.width / fitSize.width;
        }; break;
    }
    
    GLfloat *imageVertices=malloc(12*sizeof(GLfloat));
    
    imageVertices[0] = -widthScaling;
    imageVertices[1] = -heightScaling;
    imageVertices[2]=0.0;
    
    
    imageVertices[3] = widthScaling;
    imageVertices[4] = -heightScaling;
    imageVertices[5]=0.0;
    
    imageVertices[6] = widthScaling;
    imageVertices[7] = heightScaling;
    imageVertices[8]=0.0;
    
    imageVertices[9] = -widthScaling;
    imageVertices[10] = heightScaling;
    imageVertices[11]=0.0;
    
    [_drawModel loadSquareVex:imageVertices andTextureCoord:[HNodeImageView textureCoordinatesForRotation:_inputRotationMode]];
    
    //TODO: free in this time ,will make position unexpected
    //free(imageVertices);
    
}

-(CGSize)calculateSize:(CGSize)imageSize aspectFill:(CGRect)rect
{
    CGSize fitSize=_ASSizeFitWithAspectRatio(imageSize.width/imageSize.height,rect.size);
    return fitSize;
    
}


-(GLKMatrix4)mvpMatrix4Cube
{
    
    CGSize virtualSize=CGSizeMake(2.0, 2.0);//近平面的窗口和opengl的坐标系窗口重叠,因为顶点坐标的赋值方式导致需要设置这么一个virtualSize
    
    
    float aspect=virtualSize.width/virtualSize.height;
    float nearZ=virtualSize.height/2;
    
    float farZ=nearZ+100;
    
    GLKMatrix4 projection=GLKMatrix4MakePerspective(M_PI_2, aspect, nearZ, farZ);
    
    GLKMatrix4 modelView=GLKMatrix4Identity;
    
    _angle += ( 1 * 1.f );
    
    if ( _angle >= 360.0f )
    {
        _angle -= 360.0f;
    }
    
    modelView=GLKMatrix4Translate(modelView, 0.0, 0.0, -nearZ-1.5);//移动到视锥体内,原点是(0,0,-nearZ-2)
    
    //移动到屏幕中心
    modelView=GLKMatrix4Translate(modelView, -0.5, -0.5, 0.0);
    //自转
    modelView=GLKMatrix4Translate(modelView, 0.5, 0.5, 0.5);
    modelView=GLKMatrix4Rotate(modelView, GLKMathDegreesToRadians(_angle), 1.0, 1.0, 1.0);
    modelView=GLKMatrix4Translate(modelView, -0.5, -0.5, -0.5);
    
    return GLKMatrix4Multiply(projection,modelView);//modelView*projection
    
}

-(GLKMatrix4)mvpMatrix4Square
{
    CGSize virtualSize=CGSizeMake(2.0, 2.0);//近平面的窗口和opengl的坐标系窗口重叠,因为顶点坐标的赋值方式导致需要设置这么一个virtualSize
    
    float aspect=virtualSize.width/virtualSize.height;
    float nearZ=virtualSize.height/2;
    
    float farZ=nearZ+10;
    
    GLKMatrix4 projection=GLKMatrix4MakePerspective(M_PI_2, aspect, nearZ, farZ);
    
    GLKMatrix4 modelView=GLKMatrix4Identity;
    
    modelView=GLKMatrix4Translate(modelView, 0.0, 0.0, -nearZ);//移动到视锥体内,原点是(0,0,-nearZ-2)
    
    return GLKMatrix4Multiply(projection,modelView);//modelView*projection
    
}


-(void)render
{
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    GLenum status= glCheckFramebufferStatus(GL_FRAMEBUFFER);
    
    assert(status==GL_FRAMEBUFFER_COMPLETE);
    
    glViewport(0, 0,(GLint)_sizeInPixel.width,(GLint)_sizeInPixel.height);
    glClearColor(0.0, 0.0, 0.0, 1.0);
    
    glClear(GL_COLOR_BUFFER_BIT| GL_DEPTH_BUFFER_BIT);
    
    glUseProgram(_drawModel.program);
    
    GLint location=[_drawModel locationOfUniform:UNIFORM_MATRIX];
    
    GLKMatrix4 _mvpMatrix=[self mvpMatrix4Square];;
    
    float*mm=(float*)_mvpMatrix.m;
    
    GLfloat* finalMatrix=malloc(sizeof(GLfloat)*16);
    
    for (int index=0; index<16; index++)
    {
        finalMatrix[index]=(GLfloat)mm[index];
        
    }
    
    glUniformMatrix4fv(location, 1, GL_FALSE, (const GLfloat*)finalMatrix);
    
    free(finalMatrix);
    
    GLint location_s_texture=[_drawModel locationOfUniform:UNIFORM_INPUTTEXTURE];
    
    glActiveTexture(GL_TEXTURE0);
    
    [HESNode bindTexture:_textureId];
    
    glUniform1i ( location_s_texture, 0);
    
    GLint location_position=glGetAttribLocation(_drawModel.program, [ATTRIBUTE_POSITION UTF8String]);
    glBindBuffer(GL_ARRAY_BUFFER, _drawModel.verticesBuffer);
    
    glEnableVertexAttribArray(location_position);//顶点坐标
    
    glVertexAttribPointer(location_position, 3, GL_FLOAT, GL_FALSE,sizeof(GLfloat)*3,0);
    
    glBindBuffer(GL_ARRAY_BUFFER, _drawModel.textureBuffer);
    
    GLint location_texturecoord=glGetAttribLocation(_drawModel.program, [ATTRIBUTE_TEXTURE_COORDINATE UTF8String]);
    
    
    glEnableVertexAttribArray(location_texturecoord);
    
    glVertexAttribPointer(location_texturecoord, 2, GL_FLOAT, GL_FALSE,sizeof(GLfloat)*2,0);//纹理坐标
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _drawModel.indicesBuffer);
    

    GLsizei count=_drawModel.indicesCount;
    
    count=count/4;
    
    for (int index=0; index<count; index++)
    {
        
        glDrawElements(_drawModel.drawStyle, 4, GL_UNSIGNED_BYTE,(const GLvoid*)(0+index*4*sizeof(GLubyte)));
        
    }
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
}

-(void)innerRender
{
    [_drawModel loadIfNeed];
    [self setupBufferIfNeed];
    assert(_frameBuffer!=0);
    [self render];
    
}

/**
 *目前只实现了 kYDGLOperationImageNoRotation
 */
+ (const GLfloat *)textureCoordinatesForRotation:(NodeImageRotationMode)rotationMode;
{
    
    static const GLfloat noRotationTextureCoordinates[] =
    {
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
    };
    
    static const GLfloat rotateRightTextureCoordinates[] =
    {
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
    };
    
    static const GLfloat rotateLeftTextureCoordinates[] =
    {
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
    };
    
    static const GLfloat verticalFlipTextureCoordinates[] =
    {
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
    };
    
    static const GLfloat horizontalFlipTextureCoordinates[] =
    {
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
    };
    
    static const GLfloat rotateRightVerticalFlipTextureCoordinates[] =
    {
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
    };
    
    static const GLfloat rotateRightHorizontalFlipTextureCoordinates[] =
    {
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
    };
    
    static const GLfloat rotate180TextureCoordinates[] =
    {
        0.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
    };
    
    switch(rotationMode)
    {
        case kNodeImageNoRotation: return noRotationTextureCoordinates;
        case kNodeImageRotateLeft: return rotateLeftTextureCoordinates;
        case kNodeImageRotateRight: return rotateRightTextureCoordinates;
        case kNodeImageFlipVertical: return verticalFlipTextureCoordinates;
        case kNodeImageFlipHorizonal: return horizontalFlipTextureCoordinates;
        case kNodeImageRotateRightFlipVertical: return rotateRightVerticalFlipTextureCoordinates;
        case kNodeImageRotateRightFlipHorizontal: return rotateRightHorizontalFlipTextureCoordinates;
        case kNodeImageRotate180: return rotate180TextureCoordinates;
    }
}



#pragma -mark 资源清理

-(void)dealloc
{
    
    [self activeGLContext:^{
        
        [self cleanup];
        
    }];
    
    _context=nil;
    
    NSLog(@"销毁:%@_nodeView",self);
    
}
-(void)cleanup
{
    
    GLuint renderBuffers[1]={_renderBuffer};
    
    glDeleteRenderbuffers(1, renderBuffers);
    
    GLuint frameBuffers[1]={_frameBuffer};
    
    glDeleteFramebuffers(1,frameBuffers);
    
    glDeleteTextures(1, &_textureId);
    
    _frameBuffer=0;
    _renderBuffer=0;
}

#pragma -mark  GLOperationNode 协议实现


-(void)performTraversalsIfCanWhenDependencyDone:(id<HESNode>)doneOperation
{
    
    HNodeOutput* outData=[doneOperation getOutput];
    
    if (CGSizeEqualToSize(outData.size, CGSizeZero)) return ;
    
    _textureId=outData.texture;
    
    if (CGSizeEqualToSize(_inputImageSize, outData.size)==NO||_framebufferAvailable==NO)
    {
        
        _inputImageSize=outData.size;
        
        [self loadSquareByFillModeType];
        
    }
    
    if (_context==nil)
    {
        _context=[HESContext currentGLContext];
        NSAssert(_context!=nil, @"maybe you have forgot call [HESContext pushContext] ?");
    }
    
    
    [self activeGLContext:^{
        
        [self innerRender];
        
    }];
    
}



-(void)addDependency:(id<HESNode>)operation
{
    
    
}

-(void)addNextOperation:(id<HESNode>)nextOperation
{
    
    
    NSAssert(NO, @"display node can not as dependency node");
    
}

-(HNodeOutput *)getOutput
{
    return nil;
    
}

-(void)destory
{
    [_contentNode removeNextOperation:self];
    _contentNode=nil;
    
}

#pragma -mark public api

-(void)setContentProviderNode:(HESNode* _Nullable)contentNode
{
    
    [_contentNode removeNextOperation:self];
    _contentNode=contentNode;
    [_contentNode addNextOperation:self];
    
}

/**
 *  从帧缓冲区对象读取像素数据 测试
 */
-(void)readBuffer
{
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    GLubyte *t=malloc(_sizeInPixel.width*_sizeInPixel.height*4*sizeof(GLubyte));
    
    glReadPixels(0, 0, _sizeInPixel.width, _sizeInPixel.height, GL_RGBA, GL_UNSIGNED_BYTE, t);
    
    struct RGBA
    {
        uint8_t R;
        uint8_t G;
        uint8_t B;
        uint8_t A;
        
    };
    
    struct RGBA *tt=(struct RGBA*)t;
    
    for (int index=0; index<300; index++)
    {
        
        struct   RGBA pixel=tt[index];
        
        NSLog(@"r:%i g:%i b:%i a:%i",pixel.R,pixel.G,pixel.B,pixel.A);
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    free(t);
    
}

@end
