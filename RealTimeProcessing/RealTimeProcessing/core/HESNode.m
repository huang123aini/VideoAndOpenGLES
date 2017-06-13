//
//  HESNode.m
//  HTools
//
//  Created by huangshiping on 2017/6/12.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HESNode.h"
#import "HMacros.h"
#import "HESContext.h"

typedef struct _NodeStatusFlag
{
    
    BOOL needLayout;//是否需要重新计算framebuffer的大小
    
    BOOL destoried;//是否销毁
    
    BOOL needCalculateFrameBufferSize;//if size or rotated changed,framebuffer should recalculate,but maybe not needLayout
    
}NodeStatusFlag;

@interface HESNode()

@property(nonatomic,assign) GLuint frameBuffer;//
@property(nonatomic,assign) GLuint renderTexture_out;//
@property(nonatomic,assign) CVPixelBufferRef pixelBuffer_out;//
@property(nonatomic,assign) GLKMatrix4 projectionMatrix;
@property(nonatomic,assign) GLKMatrix4  modelViewMatrix;

@property(nonatomic,nullable,retain) HESModel *drawModel;//

@property(nonatomic,nonnull,retain) NSMutableArray<id<HESNode>> *nextOperations;//

@property(nonatomic,nonnull,assign) CFMutableArrayRef dependency;//

@property(nonatomic,assign) NodeStatusFlag nodeStatusFlag;
@property(nonatomic,nullable,retain) NSMutableArray<dispatch_block_t> *programOperations;//program 的操作

@property(nonatomic,nullable,retain) NSMutableArray<dispatch_block_t> *beforePerformTraversalsOperations;//traversals 的操作

@property(nonatomic,nullable,retain) NSMutableArray<dispatch_block_t> *beforePerformDrawOperations;//draw 的操作

@property(nonatomic,assign) int angle;//旋转的角度

@property(nonatomic,assign)CGSize frameBufferSize;//frameBufferSize=size*angle;

@property(nonatomic,assign) CVOpenGLESTextureCacheRef coreVideoTextureCache;

@property(nonatomic,retain)HNodeOutput *outputData;//this Node output;

@property(nonatomic,assign)CGSize framebufferSize;//size of framebuffer

@end



@implementation HESNode
{
    CVOpenGLESTextureRef _cvTextureRef;//从纹理缓存池获取的纹理对象
}

@synthesize renderTexture_out=_renderTexture_out;

@synthesize frameBuffer=_frameBuffer;

@synthesize modelViewMatrix=_modelViewMatrix;

@synthesize drawModel=_drawModel;

@synthesize nextOperations=_nextOperations;

@synthesize dependency=_dependency;

@synthesize outputData=_outputData;

- (instancetype)init
{
    
    return [self initWithVertexShader:H_VERTEX_SHADER andFragmentShader:H_FRAGMENT_SHADER];
}

-(instancetype)initWithFragmentShader:(NSString *_Nonnull)fragmentShaderString
{
    
    return [self initWithVertexShader:H_VERTEX_SHADER andFragmentShader:fragmentShaderString];
}

-(instancetype)initWithVertexShader:(NSString *_Nonnull)vertexShaderString andFragmentShader:(NSString *_Nonnull)fragmentShaderString
{
    
    self = [super init];
    if (self)
    {
        
        [self commonInitializationWithVertexShader:vertexShaderString andFragmentShader:fragmentShaderString];
    }
    return self;
}


-(void)commonInitializationWithVertexShader:(NSString*_Nonnull)vertexShaderString andFragmentShader:(NSString*_Nonnull)fragmentShaderString
{
    
    self.drawModel=[HESModel new];
    
    self.nextOperations=[NSMutableArray array];
    
    self.dependency=CFArrayCreateMutable(kCFAllocatorDefault, 1, NULL);
    
    self.programOperations=[NSMutableArray array];
    
    self.beforePerformDrawOperations=[NSMutableArray array];
    
    self.beforePerformTraversalsOperations=[NSMutableArray array];
    
    NodeStatusFlag defaultStatus=
    {
        .needLayout=YES,
        .destoried=NO,
        .needCalculateFrameBufferSize=YES
    };
    
    self.nodeStatusFlag=defaultStatus;
    
    _lockForNodeStatus=dispatch_semaphore_create(1);
    
    _lockForTraversals=dispatch_semaphore_create(1);
    
    [_drawModel setVShader:vertexShaderString fShader:fragmentShaderString];
    
    [_drawModel loadSquareVex];
    
    _textureLoaderDelegate=self;
    
    [self loadProjectionMatrix];
    
    [self commonInitialization];
}


+(dispatch_queue_t)getProcessingQueue
{
    
    static dispatch_queue_t processingQueue;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        processingQueue=dispatch_queue_create([@"ProcessingQueue" UTF8String],DISPATCH_QUEUE_CONCURRENT);
        NSString * contextProxy=@"ProcessingQueueContext";
        
        dispatch_queue_set_specific(processingQueue, @"HTools",(__bridge void *)(contextProxy), NULL);
        
    });
    
    return processingQueue;
    
}

-(void)buildTextureCacheIfNeed
{
    if (_coreVideoTextureCache==NULL)
    {
        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL,_glContext, NULL, &_coreVideoTextureCache);
        NSAssert(err==kCVReturnSuccess, @"创建纹理缓冲区失败%i",err);
    }
}



#pragma mark  -----内部接口-------

-(void)setupFrameBuffer
{
    
    [self cleanUpTexture];
    
    if (_frameBuffer==0)
    {
        
        glGenFramebuffers(1, &_frameBuffer);
    }

    [self createCVPixelBufferRef:&_pixelBuffer_out andTextureRef:&_cvTextureRef withSize:_frameBufferSize];
    
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glActiveTexture(GL_TEXTURE0);
    
    //从纹理缓冲池中获取纹理
    _renderTexture_out = CVOpenGLESTextureGetName(_cvTextureRef);
    
    //绑定纹理
    [HESNode bindTexture:_renderTexture_out];
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D, _renderTexture_out, 0);
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
}

-(void)activeProgram:(void(^_Nullable)(GLuint))block
{
    
    [self activeGLContext:^{
        
        glUseProgram(_drawModel.program);
        
        if(block)
        {
            
            block(_drawModel.program);
            
        }
        
    } autoRestore:NO];
    
}

-(void)loadProjectionMatrix
{
    
    CGSize virtualSize=CGSizeMake(2.0, 2.0);//近平面的窗口和opengl的坐标系窗口重叠,因为顶点坐标的赋值方式导致需要设置这么一个virtualSize
    
    float aspect=virtualSize.width/virtualSize.height;
    float nearZ=virtualSize.height/2;
    
    float farZ=nearZ+10;
    
    GLKMatrix4 projection=GLKMatrix4MakePerspective(M_PI_2, aspect, nearZ, farZ);
    
    _projectionMatrix=projection;
    
    GLKMatrix4 modelView=GLKMatrix4Identity;
    
    modelView=GLKMatrix4Translate(modelView, 0.0, 0.0, -nearZ);//移动到视锥体内,原点是(0,0,-nearZ-2)
    
    _modelViewMatrix=modelView;
    
}

-(void)createCVPixelBufferRef:(CVPixelBufferRef*)pixelBuffer andTextureRef:(CVOpenGLESTextureRef*)textureRef withSize:(CGSize)size
{
    
    CFDictionaryRef empty; // empty value for attr value.
    CFMutableDictionaryRef attrs;
    empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks); // our empty IOSurface properties dictionary
    attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
    
    CVReturn err = CVPixelBufferCreate(kCFAllocatorDefault, (int)size.width, (int)size.height, kCVPixelFormatType_32BGRA, attrs,pixelBuffer);
    if (err)
    {
        NSLog(@"FBO size: %f, %f", size.width, size.height);
        NSAssert(NO, @"Error at CVPixelBufferCreate %d", err);
    }
    
    err = CVOpenGLESTextureCacheCreateTextureFromImage (kCFAllocatorDefault, _coreVideoTextureCache, _pixelBuffer_out,
                                                        NULL, // texture attributes
                                                        GL_TEXTURE_2D,
                                                        GL_RGBA, // opengl format
                                                        (int)size.width,
                                                        (int)size.height,
                                                        GL_BGRA, // native iOS format
                                                        GL_UNSIGNED_BYTE,
                                                        0,
                                                        textureRef);
    if (err)
    {
        NSAssert(NO, @"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
    
    CFRelease(attrs);
    CFRelease(empty);
    
}

/**
 *  根据angle 属性重新计算一次size
 */
-(CGSize)fixedRenderSizeByRotatedAngle:(CGSize)size
{
    
    CGSize result;
    
    switch (self.angle)
    {
        case 90:
        case 270:
        {
            result=CGSizeMake(size.height, size.width);
            
        }
            
            break;
            
        default:
            result=size;
            break;
    }
    
    return result;
    
}

/**
 *  查询改node的所有依赖是否已经完成了
 */
-(BOOL)allDependencyDone
{
    
    NSMutableArray<id<HESNode>> *dependency=(__bridge NSMutableArray<id<HESNode>> *)(_dependency);
    
    if (dependency.count==0)return NO;
    
    __block BOOL done=YES;
    
    [dependency enumerateObjectsUsingBlock:^(id<HESNode>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
    {
        
        HNodeOutput *output=[obj getOutput];
        
        if (output==nil)
        {
            
            done=NO;
            *stop=YES;
            
        }
    }];
    return done;
}

/**
 *  根据依赖的node计算该节点的尺寸,目前的策略是 size of first dependency node
 */
-(CGSize)calculateRenderSize
{
    
    NSMutableArray<id<HESNode>> *dependency=(__bridge NSMutableArray<id<HESNode>> *)(_dependency);
    
    HNodeOutput *firstNodeOutput= [[dependency firstObject] getOutput];
    
    return firstNodeOutput.size;
    
}

-(void)innerSetFrameBufferSize:(CGSize)newSize
{
    
}

/**
 *  通知所有下一个node
 */
-(void)notifyNextOperation
{
    
    dispatch_semaphore_wait(_lockForNodeStatus, DISPATCH_TIME_FOREVER);
    
    OperationCompletionBlock block=self.completionBlock;
    
    NSArray<id<HESNode>> *nextoperations= [self.nextOperations copy];
    
    dispatch_semaphore_signal(_lockForNodeStatus);
    
    if (block)
    {
        
        block([self getOutput]);
        
    }
    
    for (id<HESNode>  nextOperation in nextoperations)
    {
        
        [nextOperation performTraversalsIfCanWhenDependencyDone:self];
        
    }
    
}

-(void)beforePerformTraversals
{
    
    for (dispatch_block_t layoutOperation in self.beforePerformTraversalsOperations)
    {
        layoutOperation();
    }
    [self.beforePerformTraversalsOperations removeAllObjects];//线程同步问题
    
}

-(void)performTraversals
{
    
    
    [self measureNodeSize];
    
    [self activeGLContext:^{
        
        if(_nodeStatusFlag.needLayout)
        {
            
            [self performLayout];
            
            _nodeStatusFlag.needLayout=NO;
        }
        
        [self beforePerformDraw];
        
        [self performDraw];
        
    } autoRestore:NO];
    
    
    [self buildOutputData];
    
    [self notifyNextOperation];
    
}

-(void)performLayout
{
    
    [self buildTextureCacheIfNeed];
    
    [self setupFrameBuffer];
    
    [self didLayout];
    
}

-(void)beforePerformDraw
{
    
    for (dispatch_block_t drawOperation in self.beforePerformDrawOperations)
    {
        drawOperation();
        
    }
    [self.beforePerformDrawOperations removeAllObjects];//线程同步问题
    
}

-(void)performDraw
{
    
    assert(_frameBuffer!=0);
    
    [_drawModel loadIfNeed];
    
    [self drawFrameBuffer:_frameBuffer inRect:CGRectMake(0, 0, self.frameBufferSize.width, self.frameBufferSize.height)];
    
}

-(void)buildOutputData
{
    
    HNodeOutput* output=[HNodeOutput new];
    
    output.texture=_renderTexture_out;
    
    output.size=self.frameBufferSize;
    
    output.frameBuffer=_frameBuffer;
    
    output.pixelBuffer=_pixelBuffer_out;
    
    self.outputData=output;
    
}

/**
 *如果想使用代码块改变当前的Node的状态，使用这个API去运行这个代码块
 */
-(void)lockNodeFor:(dispatch_block_t)block
{
    
    dispatch_semaphore_wait(_lockForNodeStatus, DISPATCH_TIME_FOREVER);
    
    block();
    
    dispatch_semaphore_signal(_lockForNodeStatus);
    
}

/**
 *  计算Node的FrameBuffer Size
 */
-(void)measureNodeSize
{
    
    if (CGSizeEqualToSize(CGSizeZero, _size))
    {
        
        _size=[self calculateRenderSize];
        
        _nodeStatusFlag.needCalculateFrameBufferSize=YES;
    }
    
    if (_nodeStatusFlag.needCalculateFrameBufferSize)
    {
        
        CGSize newFrameBufferSize=[self fixedRenderSizeByRotatedAngle:_size];
        
        if (CGSizeEqualToSize(_frameBufferSize, newFrameBufferSize)==NO)
        {
            
            _frameBufferSize=newFrameBufferSize;
            
            _nodeStatusFlag.needLayout=YES;
            
            [self innerSetFrameBufferSize:_frameBufferSize];
            
            [self willSetNodeFrameBufferSize:_frameBufferSize];
            
        }
        
        _nodeStatusFlag.needCalculateFrameBufferSize=NO;
    }
    
}

#pragma -mark Node 协议的实现

-(void)addNextOperation:(id<HESNode>)nextOperation
{
    
    [self.nextOperations addObject:nextOperation];
    
}

-(void)addDependency:(id<HESNode>)operation
{
    CFArrayAppendValue(_dependency, (__bridge const void *)(operation));//will not retain operation;
    [operation addNextOperation:self];
    
}

-(void)removeDependency:(id<HESNode>)operation
{
    
    NSMutableArray<id<HESNode>> *dependency=(__bridge NSMutableArray<id<HESNode>> *)(_dependency);
    [dependency removeObject:operation];
}

-(void)removeNextOperation:(id<HESNode>)nextOperation
{
    
    [_nextOperations removeObject:nextOperation];
    
}

-(HNodeOutput*)getOutput
{
    return self.outputData;
    
}

-(void)performTraversalsIfCanWhenDependencyDone:(id<HESNode>)doneOperation
{
    
    dispatch_semaphore_wait(_lockForNodeStatus,DISPATCH_TIME_FOREVER);
    BOOL ready =(_nodeStatusFlag.destoried==NO)&&[self canPerformTraversals];
    
    dispatch_semaphore_signal(_lockForNodeStatus);
    
    if (ready)
    {
        
        if(dispatch_semaphore_wait(_lockForTraversals, DISPATCH_TIME_NOW)==0)
        {
            
            [self beforePerformTraversals];
            
            [self performTraversals];
            
            dispatch_semaphore_signal(_lockForTraversals);
        }
        
    }
    
}

#pragma -mark  纹理加载的代理

-(NSString *)textureUniformNameAtIndex:(NSInteger)index
{
    
    return UNIFORM_INPUTTEXTURE;
    
}

-(NSString *)textureCoordAttributeNameAtIndex:(NSInteger)index
{
    
    return ATTRIBUTE_TEXTURE_COORDINATE;
    
}

#pragma  -mark 清理资源

-(void)destory{
    
    dispatch_semaphore_wait(_lockForNodeStatus, DISPATCH_TIME_FOREVER);
    
    [self clearCollections];
    
    self.completionBlock=nil;
    
    _nodeStatusFlag.destoried=YES;
    
    dispatch_semaphore_signal(_lockForNodeStatus);
    
}

-(void)clearCollections
{
    
    CFArrayRemoveAllValues(_dependency);
    
    [self.nextOperations removeAllObjects];
    
    [self.programOperations removeAllObjects];
    
    [_beforePerformDrawOperations removeAllObjects];
    
    [_beforePerformTraversalsOperations removeAllObjects];
    
    [_programOperations removeAllObjects];
    
}

-(void)removeFromAllDependency
{
    
    NSArray<id<HESNode>> *dependencies=(__bridge NSArray<id<HESNode>> *)(CFArrayCreateCopy(kCFAllocatorDefault, _dependency));
    
    CFArrayRemoveAllValues(_dependency);
    
    for (HESNode *dependency in dependencies)
    {
        [dependency removeNextOperation:self];
    }
    
}

-(void)dealloc
{
    
    NSLog(@"销毁:%@节点",self);
    
    [self destory];
    
    [self cleanUpTexture];
    
    if (_glContext)
    {
        
        [self activeGLContext:^{
            
            [self destoryEAGLResource];
            
        } autoRestore:YES];
    }
    
    if (_coreVideoTextureCache!=NULL)
    {
        
        CVOpenGLESTextureCacheFlush(_coreVideoTextureCache, 0);
        
        CFRelease(_coreVideoTextureCache);
        
        _coreVideoTextureCache=NULL;
    }
    
    CFRelease(_dependency);
    
    _dependency=NULL;
    
}

-(void)cleanUpTexture
{
    
    if (_cvTextureRef)
    {
        CVPixelBufferRelease(_cvTextureRef);
        _cvTextureRef=NULL;
    }
    
    if (_pixelBuffer_out!=NULL)
    {
        CVPixelBufferRelease(_pixelBuffer_out);
        _pixelBuffer_out=NULL;
    }
    _renderTexture_out=0;
    
}

#pragma -mark 对外接口

-(void)setSize:(CGSize)size
{
    
    if (CGSizeEqualToSize(_size, size)==NO)
    {
        
        _size=size;
        _nodeStatusFlag.needCalculateFrameBufferSize=YES;
    }
    
}

-(void)setFloat:(GLfloat)newFloat forUniformName:(NSString *)uniformName
{
    __unsafe_unretained HESNode* unsafe_self=self;
    dispatch_block_t operation=^{
        GLint location=[unsafe_self.drawModel locationOfUniform:uniformName];
        glUniform1f(location, newFloat);
        
    };
    
    [self lockNodeFor:^{
    [self.programOperations addObject:operation];
    }];
    
}

- (void)setInt:(GLint)newInt forUniformName:(NSString *_Nonnull)uniformName
{
    
    __unsafe_unretained HESNode* unsafe_self=self;
    
    dispatch_block_t operation=^{
    GLint location=[unsafe_self.drawModel locationOfUniform:uniformName];
    glUniform1i(location, newInt);
        
    };
    
    [self lockNodeFor:^{
        
        [self.programOperations addObject:operation];
        
    }];
    
    
}

- (void)setBool:(GLboolean)newBool forUniformName:(NSString *_Nonnull)uniformName
{
    __unsafe_unretained HESNode* unsafe_self=self;
    dispatch_block_t operation=^{
        
        GLint location=[unsafe_self.drawModel locationOfUniform:uniformName];
        glUniform1i(location, newBool==true);
        
    };
    
    [self lockNodeFor:^{
        
        [self.programOperations addObject:operation];
        
    }];
    
}



-(void)rotateAtZ:(RotateOption)option
{
    
    int localAngle=[self calculateAngleFromRotateOption:option];
    
    __unsafe_unretained HESNode* unsafe_self=self;
    
    dispatch_block_t rotateLayoutOperation=^{
        
        unsafe_self.angle=localAngle;
        
        NodeStatusFlag statusFlag=unsafe_self.nodeStatusFlag;
        
        statusFlag.needCalculateFrameBufferSize=YES;
        
    };
    
    [self.beforePerformTraversalsOperations addObject:rotateLayoutOperation];
    
    dispatch_block_t rotateDrawOperation=^{
        
        unsafe_self.modelViewMatrix=GLKMatrix4Rotate(unsafe_self.modelViewMatrix, GLKMathDegreesToRadians(unsafe_self.angle), 0.0, 0.0, 1.0);
        
    };
    
    [self lockNodeFor:^{
        
        [self.beforePerformDrawOperations addObject:rotateDrawOperation];
        
    }];
    
}

-(void)rotateAtY:(RotateOption)option
{
    if(option==RotateOption_DEFAULT||option==RotateOption_TWO_M_PI) return ;
    
    int localAngle=[self calculateAngleFromRotateOption:option];
    
    __unsafe_unretained HESNode* unsafe_self=self;
    
    dispatch_block_t rotateDrawOperation=^{
        
        if (localAngle==180)
        {
            unsafe_self.modelViewMatrix=GLKMatrix4Scale(unsafe_self.modelViewMatrix, -1, 1, 1);
            
        }else
        {
            unsafe_self.modelViewMatrix=GLKMatrix4Rotate(unsafe_self.modelViewMatrix, GLKMathDegreesToRadians(localAngle), 0.0, 1.0, 0.0);
        }
    };
    
    [self lockNodeFor:^{
        
        [self.beforePerformDrawOperations addObject:rotateDrawOperation];
        
    }];
    
}

-(int)calculateAngleFromRotateOption:(RotateOption)option
{
    
    int localOption=option%4;
    
    switch (localOption)
    {
        case RotateOption_DEFAULT:
        case RotateOption_TWO_M_PI:
            return 0;
            break;
        case RotateOption_HALF_M_PI:
            return 90;
            break;
        case RotateOption_ONE_M_PI:
            return 180;
            break;
        case RotateOption_ONE_HALF_M_PI:
            return 270;
            break;
            
        default:
            return 0;
            break;
    }
    
}

@end

@implementation HESNode(ProtectedMethods)

#pragma -mark 支持子类重载的接口

-(void)commonInitialization
{
    
}

-(void)drawFrameBuffer:(GLuint)frameBuffer inRect:(CGRect)rect
{
    
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    glViewport(rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    
    glClear(GL_COLOR_BUFFER_BIT| GL_DEPTH_BUFFER_BIT);
    
    glUseProgram(_drawModel.program);
    
    for (int index=0; index<_programOperations.count; index++)
    {
        dispatch_block_t operation=[_programOperations objectAtIndex:index];
        operation();
    }
    
    [_programOperations removeAllObjects];//_programOperation 里面的操作只要执行一次就生效了,不需要每次render的时候赋值
    
    //1.设置变换矩阵
    
    GLint location=[_drawModel locationOfUniform:UNIFORM_MATRIX];
    
    GLKMatrix4 matrix=GLKMatrix4Multiply(_projectionMatrix, _modelViewMatrix);
    
    float*mm=(float*)matrix.m;
    
    GLfloat* finalMatrix=malloc(sizeof(GLfloat)*16);
    
    for (int index=0; index<16; index++)
    {
        
        finalMatrix[index]=(GLfloat)mm[index];
        
    }
    
    glUniformMatrix4fv(location, 1, GL_FALSE, (const GLfloat*)finalMatrix);
    
    free(finalMatrix);
    
    //2.设置顶点坐标
    
    GLint location_position=glGetAttribLocation(_drawModel.program, [ATTRIBUTE_POSITION UTF8String]);
    
    glBindBuffer(GL_ARRAY_BUFFER, _drawModel.verticesBuffer);
    
    glEnableVertexAttribArray(location_position);//顶点坐标
    
    glVertexAttribPointer(location_position, 3, GL_FLOAT, GL_FALSE,sizeof(GLfloat)*3,0);
    
    //3.设置纹理坐标
    
    glBindBuffer(GL_ARRAY_BUFFER, _drawModel.textureBuffer);
    
    [self setTextureCoord];
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    //4.设置纹理
    
    [self setupTextureForProgram:_drawModel.program];
    
    //5. draw
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _drawModel.indicesBuffer);
    
    GLsizei count=_drawModel.indicesCount;
    
    count=count/4;
    
    for (int index=0; index<count; index++)
    {
        
        glDrawElements(_drawModel.drawStyle, 4, GL_UNSIGNED_BYTE,(const GLvoid*)(index*4*sizeof(GLubyte)));
    }
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
}

/**
 *  设置纹理坐标
 *  注意:绘制图元的时候,是从左下角开始,按照GL_TRIANGLE_FAN方式,逆时针绘制的
 */
-(void)setTextureCoord
{
    
    NSMutableArray<id<HESNode>> *dependency=(__bridge NSMutableArray<id<HESNode>> *)(_dependency);
    
    for (int index=0; index<dependency.count; index++)
    {
        
        NSString *name=[_textureLoaderDelegate textureCoordAttributeNameAtIndex:index];
        
        GLint location_texturecoord=glGetAttribLocation(_drawModel.program, [name UTF8String]);
        glEnableVertexAttribArray(location_texturecoord);
        glVertexAttribPointer(location_texturecoord, 2, GL_FLOAT, GL_FALSE,sizeof(GLfloat)*2,0);//纹理坐标
        
    }
    
}


-(void)setupTextureForProgram:(GLuint)program
{
    
    NSMutableArray<id<HESNode>> *dependency=(__bridge NSMutableArray<id<HESNode>> *)(_dependency);
    
    for (int index=0; index<dependency.count;index++)
    {
        HNodeOutput *output=[[dependency objectAtIndex:index] getOutput];
        NSString *name=[_textureLoaderDelegate textureUniformNameAtIndex:index];
        GLint location_s_texture=[_drawModel locationOfUniform:name];
        glActiveTexture(GL_TEXTURE0+index);
        [HESNode bindTexture:output.texture];
        glUniform1i ( location_s_texture,index);
    }
    
}

-(void)willSetNodeFrameBufferSize:(CGSize)newFrameBufferSize
{
}

-(BOOL)canPerformTraversals
{
    
    return [self allDependencyDone];
    
}

-(void)didLayout{
    
    
    
}

-(void)activeGLContext:(void (^)(void))block autoRestore:(BOOL) autoRestore
{
    
    if (_glContext==nil)
    {
        _glContext=[HESContext currentGLContext];
        NSAssert(_glContext!=nil, @"maybe you forgot call [HESContext pushContext] ?");
    }
    
    EAGLContext *preContext=[EAGLContext currentContext];
    if (preContext==_glContext)
    {
        block();
        
    }else
    {
        
        [EAGLContext setCurrentContext:_glContext];
       
        block();
        
        if (autoRestore)
        {
            
            [EAGLContext setCurrentContext:preContext];
            
        }
        
    }
}

-(void)destoryEAGLResource
{
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer=0;
    
}

+(void)bindTexture:(GLuint)textureId
{
    
    glBindTexture(GL_TEXTURE_2D, textureId);
    
}


@end











