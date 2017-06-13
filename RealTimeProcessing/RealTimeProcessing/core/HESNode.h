//
//  HESNode.h
//  HTools
//
//  Created by huangshiping on 2017/6/12.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>


#import "HESModel.h"
#import "HNodeOutput.h"



static NSString *_Nonnull  const UNIFORM_MATRIX=@"u_mvpMatrix";
static NSString *_Nonnull  const UNIFORM_INPUTTEXTURE=@"inputImageTexture";
static NSString *_Nonnull  const ATTRIBUTE_POSITION=@"position";
static NSString *_Nonnull  const ATTRIBUTE_TEXTURE_COORDINATE=@"inputTextureCoordinate";


@protocol HESNode<NSObject>

@required

// 该操作所依赖的操作
-(void)addDependency:(id<HESNode>_Nonnull)operation;

-(void)removeDependency:(id<HESNode>_Nonnull)operation;

/**
 * @param nextOperation 下一项操作
 */
-(void)addNextOperation:(id<HESNode>_Nonnull)nextOperation;

-(void)removeNextOperation:(id<HESNode>_Nonnull)nextOperation;

/**
 *  该操作的输出
 */
-(HNodeOutput*_Nullable)getOutput;
/**
 *  @param doneOperation 已经完成的dependency
 *  注意,node必须在这里检查所有的依赖时候已经准备好了,
 *  如果准备好了,则应该开始进行渲染,然后通知下一个节点
 */

-(void)performTraversalsIfCanWhenDependencyDone:(id<HESNode>_Nonnull)doneOperation;

/**
 * remove all dependency
 */
-(void)removeFromAllDependency;

@end



@protocol HESTextureLoaderDelegate <NSObject>

@required
-(NSString*_Nonnull)textureUniformNameAtIndex:(NSInteger)index;
-(NSString*_Nonnull)textureCoordAttributeNameAtIndex:(NSInteger)index;

@end


typedef void(^OperationCompletionBlock)(HNodeOutput*_Nonnull);

/**
 node content just can rotate zero,M_PI_2,M_PI,1.5*M_PI,2*M_PI
 */
typedef enum
{
    
    RotateOption_DEFAULT=0,
    RotateOption_HALF_M_PI,
    RotateOption_ONE_M_PI,
    RotateOption_ONE_HALF_M_PI,
    RotateOption_TWO_M_PI
    
}RotateOption;




@interface HESNode : NSObject<HESNode,HESTextureLoaderDelegate>
{
    
@protected
    
    GLuint     _frameBuffer;
    GLuint     _renderTexture_out;
    
    GLKMatrix4 _modelViewMatrix;
    HESModel*  _drawModel;
    
    CFMutableArrayRef _dependency;//contain the id<YDGLOperationNode>,use CFMutableArrayRef to break recyle retain of dependency and nextoperation
    
    NSMutableArray<id<HESNode>> *_nextOperations;
    
    __weak id<HESTextureLoaderDelegate> _Nonnull _textureLoaderDelegate;
    
    EAGLContext* _glContext;
    
    HNodeOutput* _outputData;
    
    dispatch_semaphore_t _lockForNodeStatus;
    
    dispatch_semaphore_t _lockForTraversals;//TODO:后续看看能不能和lockForNode合并成一个锁
    
}

@property(nonatomic,nullable,copy)OperationCompletionBlock completionBlock;

@property(nonatomic,assign)CGSize size;

//默认初始化方法
-(instancetype _Nullable )init;

-(instancetype _Nullable)initWithVertexShader:(NSString*_Nonnull)vertexShaderString andFragmentShader:(NSString*_Nonnull)fragmentShaderString;

-(instancetype _Nullable)initWithFragmentShader:(NSString*_Nonnull)fragmentShaderString;



//操作shader-Program
- (void)setFloat:(GLfloat)newFloat forUniformName:(NSString *_Nonnull)uniformName;
- (void)setInt:(GLint)newInt forUniformName:(NSString *_Nonnull)uniformName;
- (void)setBool:(GLboolean)newBool forUniformName:(NSString *_Nonnull)uniformName;


-(void)rotateAtZ:(RotateOption)option;

-(void)rotateAtY:(RotateOption)angle;

@end


@interface HESNode (ProtectedMethods)

+(void)bindTexture:(GLuint)textureId;

-(void)setupTextureForProgram:(GLuint)program;

-(void)activeGLContext:(void (^_Nonnull)(void))block autoRestore:(BOOL) autoRestore;

/**
 *  是否可以开始遍历节点了,默认实现是所有的dependency完成之后的情况下才返回YES
 */
-(BOOL)canPerformTraversals;
/**
 *  该节点的渲染过程  渲染缓冲区 区域
 */
-(void)drawFrameBuffer:(GLuint)frameBuffer inRect:(CGRect)rect;
/**
 *  self framebuffer had layout,subclass can do something after layout self
 */
-(void)didLayout;

/**
 *  custom init in this method
 */
-(void)commonInitialization;
/**

 *  delete frambuffer,texture in this method,
 *  should not call activeContext
 *  if you override,must be call [super destoryEAGLResource]

 */
-(void)destoryEAGLResource;

/**
 *  will set frambuffer size
 */
-(void)willSetNodeFrameBufferSize:(CGSize)newFrameBufferSize;

@end


