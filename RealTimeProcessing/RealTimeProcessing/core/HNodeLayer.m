//
//  HNodeLayer.m
//  HTools
//
//  Created by huangshiping on 2017/6/13.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HNodeLayer.h"
#import "HMacros.h"
#import "HNodeOutput.h"


@interface HNodeLayer()

@property(nonatomic,assign)GLKMatrix4 projection;//
@property(nonatomic,assign)GLKMatrix4 view;//
@property(nonatomic,assign)GLKMatrix4 model; //subNode

@property(nonatomic,retain)NSMutableArray<HNodeLayer*> *subNodes;

@end

@implementation HNodeLayer


#pragma -mark override protected method


-(instancetype)init
{
    
    if (self=[super initWithVertexShader:H_VERTEX_SHADER andFragmentShader:H_BLENDSHADER_FRAGMENT_SHADER])
    {
       
    }
     return  self;
}

-(void)commonInitialization
{
    
    [super commonInitialization];
    
    _subNodes=[NSMutableArray array];
    
    _transform=GLKMatrix4Identity;
    
    [self setOpaticy:1.0f];
    
}

-(void)willSetNodeFrameBufferSize:(CGSize)newInputSize
{
    
    [super willSetNodeFrameBufferSize:newInputSize];
    
    CGSize sizeWillSet=newInputSize;
    
    CGSize sizeInPixel=CGSizeMake(sizeWillSet.width,sizeWillSet.height);
    
    float aspect=sizeInPixel.width/sizeInPixel.height;
    float nearZ=sizeInPixel.height/2;
    
    float farZ=nearZ+100;
    
    GLKMatrix4 projection=GLKMatrix4MakePerspective(M_PI_2, aspect, nearZ, farZ);
    
    self.projection=projection;
    
    GLKMatrix4 view=GLKMatrix4Identity;
    
    view=GLKMatrix4Translate(view, 0.0, 0.0, -nearZ);
    
    view=GLKMatrix4Translate(view, -sizeInPixel.width/2, -sizeInPixel.height/2, 0.0);
    
    self.view=view;
    
    self.model=GLKMatrix4Identity;
}
-(void)drawFrameBuffer:(GLuint)frameBuffer inRect:(CGRect)rect{
    
    //1. draw self content
    
    glUseProgram(_drawModel.program);
    
    float opaticy=_opaticy;
    
    GLint location_opaticy=[_drawModel locationOfUniform:@"opaticy"];
    
    glUniform1f(location_opaticy, opaticy);
    
    [super drawFrameBuffer:frameBuffer inRect:rect];
    
    if (_subNodes.count<1)return;
    
    //2. draw subNodes
    
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    glViewport(rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
    
    glEnable(GL_BLEND);
    
    //https://www.opengl.org/wiki/Blending
    //premultiplied alpha blending
    
    //notice:use follow onfig will make export image something wrong
    //glBlendEquationSeparate(GL_FUNC_ADD, GL_FUNC_ADD);
    //glBlendFuncSeparate(GL_ONE, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ZERO);
    
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    glDisable(GL_DEPTH_TEST);
    
    glUseProgram(_drawModel.program);
    
    dispatch_semaphore_wait(_lockForNodeStatus, DISPATCH_TIME_FOREVER);
    
    NSArray<HNodeLayer*> *subNodeCopy= [self.subNodes copy];
    
    dispatch_semaphore_signal(_lockForNodeStatus);
    
    for (int index=0; index<subNodeCopy.count; index++)
    {
        
        HNodeLayer* subNode=subNodeCopy[index];
        
        [self drawSubNode:subNode widthIndex:index];
        
    }
    
    glDisable(GL_BLEND);
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
}

-(void)drawSubNode:(HNodeLayer*_Nonnull)subNode widthIndex:(int)indexOfSubNode
{
    
    if (subNode.hidden) return;
    
    HNodeOutput *output=[subNode getOutput];
    
    float opaticy=subNode.opaticy;
    
    GLint location_opaticy=[_drawModel locationOfUniform:@"opaticy"];
    
    glUniform1f(location_opaticy, opaticy);
    
    GLKMatrix4 subTransform=subNode.transform;
    
    CGRect frame=subNode.frame;
    
    if (CGRectIsEmpty(frame))
    {
        
        frame=CGRectMake(0, 0, output.size.width, output.size.height);
        
    }
    //1.设置变换矩阵
    
    GLint location=[_drawModel locationOfUniform:UNIFORM_MATRIX];
    
    GLKMatrix4 modelMatrix=self.model;
    
    modelMatrix=GLKMatrix4Translate(modelMatrix, CGRectGetMidX(frame), CGRectGetMidY(frame), 0);//subnode center as (0,0,0)
    
    modelMatrix=GLKMatrix4Multiply(modelMatrix,subTransform);//multipy transform
    
    modelMatrix=GLKMatrix4Translate(modelMatrix, 0.0, 0.0, 0.0-0.01*indexOfSubNode);//set z index
    
    modelMatrix=GLKMatrix4Translate(modelMatrix, -CGRectGetMidX(frame), -CGRectGetMidY(frame), 0);
    
    GLKMatrix4 mvpMatrix=GLKMatrix4Multiply(self.view, modelMatrix);
    mvpMatrix=GLKMatrix4Multiply(self.projection, mvpMatrix);
    
    float*mm=(float*)mvpMatrix.m;
    
    GLfloat* const finalMatrix=malloc(sizeof(GLfloat)*16);
    
    for (int index=0; index<16; index++)
    {
        
        finalMatrix[index]=(GLfloat)mm[index];
        
    }
    
    glUniformMatrix4fv(location, 1, GL_FALSE, (const GLfloat*)finalMatrix);
    
    free(finalMatrix);
    
    //2.设置顶点坐标
    
    GLint location_position=glGetAttribLocation(_drawModel.program, [ATTRIBUTE_POSITION UTF8String]);
    
    CGSize size=frame.size;
    
    GLfloat vex[12]=
    {
        
        frame.origin.x,frame.origin.y,0.0,//left bottom
        frame.origin.x+size.width,frame.origin.y,0.0,//right bottom
        frame.origin.x+size.width,frame.origin.y+size.height,0.0,//right top
        frame.origin.x,frame.origin.y+size.height,0.0,//left top
    };
    
    glEnableVertexAttribArray(location_position);//顶点坐标
    
    glVertexAttribPointer(location_position, 3, GL_FLOAT, GL_FALSE,sizeof(GLfloat)*3,vex);
    
    //3.设置纹理坐标
    
    glBindBuffer(GL_ARRAY_BUFFER, _drawModel.textureBuffer);
    
    GLint location_texturecoord=glGetAttribLocation(_drawModel.program, [ATTRIBUTE_TEXTURE_COORDINATE UTF8String]);
    
    glEnableVertexAttribArray(location_texturecoord);
    
    glVertexAttribPointer(location_texturecoord, 2, GL_FLOAT, GL_FALSE,sizeof(GLfloat)*2,0);//纹理坐标
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    //4.设置纹理
    
    GLint location_s_texture=[_drawModel locationOfUniform:UNIFORM_INPUTTEXTURE];
    
    glActiveTexture(GL_TEXTURE0);
    
    [HESNode bindTexture:output.texture];
    
    glUniform1i ( location_s_texture,0);
    //5. draw
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _drawModel.indicesBuffer);
    
    GLsizei count=_drawModel.indicesCount;
    
    count=count/4;
    
    for (int index=0; index<count; index++)
    {
        
        glDrawElements(_drawModel.drawStyle, 4, GL_UNSIGNED_BYTE,(const GLvoid*)(index*4*sizeof(GLubyte)));
        
    }
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
    
}

-(void)addDependency:(id<HESNode>)operation
{
    
    [super addDependency:operation];
    
    if (CFArrayGetCount(_dependency)>1)
    {
        
        NSAssert(NO, @"because dependency node provide the blend node content,so only support one dependency");
    }
    
}

-(BOOL)canPerformTraversals
{
    
    return [super canPerformTraversals]&&[self innerAllSubNodeDone];
}

-(void)didLayout
{
    
    [self layoutSubNodeLayerOfNodeLayer:self];
    
}

#pragma  -mark subclass can override

-(void)layoutSubNodeLayerOfNodeLayer:(HNodeLayer*_Nonnull)parentLayer
{
    
    
}

#pragma -mark private method

-(BOOL)innerAllSubNodeDone
{
    
    if (self.subNodes.count==0)return YES;
    __block BOOL done=YES;
    
    [self.subNodes enumerateObjectsUsingBlock:^(HNodeLayer*  _Nonnull subLayer, NSUInteger idx, BOOL * _Nonnull stop)
    {
        
        if (subLayer.hidden==NO)
        {
            
            HNodeOutput *output=[subLayer getOutput];
            
            if (output==nil)
            {
                
                done=NO;
                *stop=YES;
            }
        }
    }];
    
    return done;
}

-(void)setSuperNodeLayer:(HNodeLayer * _Nullable)superNodeLayer
{
    
    _superNodeLayer=superNodeLayer;
    
}

-(void)innerSetFrame:(CGRect)frame
{
    
    _frame=frame;
    
    _center=CGPointMake(CGRectGetMidX(_frame), CGRectGetMidY(_frame));
    
}


#pragma -mark public api

-(NSArray<__kindof HNodeLayer *> *)subNodeLayer
{
    
    return [_subNodes copy];
    
}

-(void)setOpaticy:(float)opaticy
{
    
    _opaticy=opaticy;
    
    [self setFloat:_opaticy forUniformName:@"opaticy"];
    
}

-(void)addSubNodeLayer:(HNodeLayer *)subNode
{
    
    NSAssert(subNode.superNodeLayer==nil, @"YDGLOperationNodeLayer had parentLayer");
    
    dispatch_semaphore_wait(_lockForNodeStatus, DISPATCH_TIME_FOREVER);
    
    [_subNodes addObject:subNode];
    
    subNode.superNodeLayer=self;
    
    dispatch_semaphore_signal(_lockForNodeStatus);
    
    
}

-(void)removeSubNodeLayer:(HNodeLayer *)subNode
{
    
    dispatch_semaphore_wait(_lockForNodeStatus, DISPATCH_TIME_FOREVER);
    
    if ([_subNodes containsObject:subNode])
    {
        
        [_subNodes removeObject:subNode];
        
        subNode.superNodeLayer=nil;
    }
    
    dispatch_semaphore_signal(_lockForNodeStatus);
    
}

-(void)removeFromSuperNodeLayer
{
    
    if (_superNodeLayer)
    {
        [_superNodeLayer removeSubNodeLayer:self];
        
    }
    
}

-(void)setFrame:(CGRect)frame
{
    
    [self innerSetFrame:frame];
    
    self.size=frame.size;
    
}
/**
 *  set size may be change frame property
 */
-(void)setSize:(CGSize)size
{
    
    [super setSize:size];
    
    if (CGRectIsEmpty(self.frame)==NO&&CGSizeEqualToSize(size, self.frame.size)==NO)
    {
        [self innerSetFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height)];
        
    }
    
}

-(void)setCenter:(CGPoint)center
{
    
    CGRect currentFrame=_frame;
    
    if(CGRectIsEmpty(currentFrame)) return ;//must set frame property
    
    float offsetX=center.x-self.center.x;
    
    float offsetY=center.y-self.center.y;
    
    currentFrame=CGRectOffset(currentFrame, offsetX, offsetY);
    
    _frame=currentFrame;
    
    _center=center;
    
}

-(void)dealloc
{
    for (HNodeLayer* subLayer in _subNodes)
    {
        subLayer.superNodeLayer=nil;
    }
    
    [_subNodes removeAllObjects];
}

@end

