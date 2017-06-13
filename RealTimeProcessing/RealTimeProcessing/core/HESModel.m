//
//  HESModel.m
//  HTools
//
//  Created by huangshiping on 2017/6/12.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HESModel.h"
#import "HGLUtils.h"


@interface HESModel()

@property(nonatomic,strong)NSMutableDictionary<NSString*,NSNumber*> *uniformDictionary;

@property(nonatomic,strong)NSMutableDictionary<NSString*,NSNumber*> *attributeDictionary;

@property(nonatomic,assign)BOOL needLoad;

@property(nonatomic,assign)struct ArrayWrapper vertices;

@property(nonatomic,assign)struct ArrayWrapper textureCoords;

@property(nonatomic,assign)struct ArrayWrapper indices;

@end

@implementation HESModel

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        
        _uniformDictionary=[NSMutableDictionary dictionary];
        
        _attributeDictionary=[NSMutableDictionary dictionary];
        
        self.needLoad=YES;
        
    }
    return self;
}

-(void)setVShader:(NSString*_Nullable)vShaderFile fShader:(NSString*_Nullable)fShaderFile
{
    self.vShaderFile = vShaderFile;
    self.fShaderFile = fShaderFile;
}

-(void)loadSquareVex:(const GLfloat [12])vertices_position andTextureCoord:(const GLfloat [8])textureCoord
{
    
    const GLubyte indices_position[]=
    {
        
        0,1,2,3,
        
    };
    
    struct ArrayWrapper vertices_wrapper=
    {
        vertices_position, 12*sizeof(GLfloat), 12
    };
    struct ArrayWrapper texturecoord_warpper=
    {
        textureCoord, 8*sizeof(GLfloat), 8
    };
    struct ArrayWrapper indices_warpper=
    {
        indices_position,sizeof(indices_position),sizeof(indices_position)/sizeof(GLubyte)
    };
    
    [self setVertices:vertices_wrapper andTextureVertices:texturecoord_warpper andIndices:indices_warpper andDrawStyle:GL_TRIANGLE_FAN];
    
}

-(void)setVertices:(struct ArrayWrapper)vertices andTextureVertices:(struct ArrayWrapper)textureVertices andIndices:(struct ArrayWrapper)indices andDrawStyle:(GLenum)drawModel
{
    
    self.vertices=vertices;
    
    self.textureCoords=textureVertices;
    
    self.indices=indices;
    
    _drawStyle=drawModel;
    
    self.needLoad=YES;
    
}

-(void)innerloadProgram
{
    self.program=[HGLUtils compileShaders:self.vShaderFile shaderFragment:self.fShaderFile];
    
    [_uniformDictionary removeAllObjects];
    
    [_attributeDictionary removeAllObjects];
    
    glUseProgram(self.program);
    
    //查询统一变量
    
    GLint maxUniformLen;
    GLint numUniforms;
    char *uniformName;
    glGetProgramiv (self.program, GL_ACTIVE_UNIFORMS, &numUniforms );
    glGetProgramiv (self.program, GL_ACTIVE_UNIFORM_MAX_LENGTH,
                    &maxUniformLen);
    
    uniformName = malloc ( sizeof ( char ) * maxUniformLen );
    
    for (int index=0; index<numUniforms; index++)
    {
        
        GLint size;
        GLenum type;
        GLint location;
        
        glGetActiveUniform(self.program, index, maxUniformLen, NULL, &size, &type, uniformName);
        
        location=glGetUniformLocation(self.program, uniformName);
        
        NSString *name=[NSString stringWithUTF8String:uniformName];
        
        if (!name) continue;
        [_uniformDictionary setObject:@(location) forKey:name];
        
    }
    
    free(uniformName);
}


//赋值 vertices,textureCoords,indices
-(void)innerLoadVertix
{
    
    struct ArrayWrapper vertices=self.vertices;
    struct ArrayWrapper textureVertices=self.textureCoords;
    struct ArrayWrapper indices=self.indices;
    
    glDeleteBuffers(1, &_verticesBuffer);
    glDeleteBuffers(1, &_textureBuffer);
    glDeleteBuffers(1, &_indicesBuffer);
    
    GLuint* bufferId=malloc(sizeof(GLuint)*3);
    
    glGenBuffers(3, bufferId);
    
    glBindBuffer(GL_ARRAY_BUFFER, bufferId[0]);
    glBufferData(GL_ARRAY_BUFFER, vertices.size, vertices.pointer, GL_STATIC_DRAW);
    
    glBindBuffer(GL_ARRAY_BUFFER, bufferId[1]);
    glBufferData(GL_ARRAY_BUFFER, textureVertices.size, textureVertices.pointer, GL_STATIC_DRAW);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, bufferId[2]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size, indices.pointer, GL_DYNAMIC_DRAW);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    
    _verticesBuffer=bufferId[0];
    
    _verticesCount=vertices.count;
    
    _textureBuffer=bufferId[1];
    
    _textureVerticesCount=textureVertices.count;
    
    _indicesBuffer=bufferId[2];
    
    _indicesCount=indices.count;
    
    free(bufferId);
    
}



-(void)loadSquareVex:(const GLfloat [12])vertices_position
{
    
    const GLfloat vertices_texture[]=
    {
        
        0.0,0.0, 1.0,0.0, 1.0,1.0, 0.0,1.0,
        
        //旋转90度 1.0,1.0, 0.0,1.0 ,0.0,0.0, 1.0,0.0,
        
    };
    
    [self loadSquareVex:vertices_position andTextureCoord:vertices_texture];
    
}

-(void)loadSquareVex
{
    
    const GLfloat vertices_position[]=
    {
        
        -1.0,-1.0,0.0,
        
        1.0,-1.0,0.0,
        
        1.0,1.0,0.0,
        
        -1.0,1.0,0.0,
        
    };
    
    [self loadSquareVex:vertices_position];
}


-(void)loadCubeVex
{
    
    static const GLfloat vertices_position[]=
    {
        
        0.0,0.0,1.0, 0.0,1.0,1.0, 0.0,1.0,0.0, 0.0,0.0,0.0,//1,2,3,0,
        
        0.0,0.0,0.0, 0.0,1.0,0.0, 1.0,1.0,0.0, 1.0,0.0,0.0,//0,3,5,4
        
        1.0,0.0,0.0, 1.0,1.0,0.0, 1.0,1.0,1.0, 1.0,0.0,1.0,//4,5,7,6
        
        0.0,0.0,1.0, 1.0,0.0,1.0, 1.0,1.0,1.0, 0.0,1.0,1.0,//1,6,7,2
        
        0.0,1.0,1.0, 1.0,1.0,1.0, 1.0,1.0,0.0, 0.0,1.0,0.0,//2,7,5,3,
        
        0.0,0.0,0.0, 1.0,0.0,0.0, 1.0,0.0,1.0, 0.0,0.0,1.0,//0,4,6,1
        
        
    };
    
    static const GLubyte indices_position[]=
    {
        
        0,1,2,3,
        4,5,6,7,
        8,9,10,11,
        12,13,14,15,
        16,17,18,19,
        20,21,22,23
        
    };
    
    static const GLfloat vertices_texture[]=
    {
        
        1.0,0.0, 1.0,1.0, 0.0,1.0, 0.0,0.0,
        1.0,0.0, 1.0,1.0, 0.0,1.0, 0.0,0.0,
        1.0,0.0, 1.0,1.0, 0.0,1.0, 0.0,0.0,
        0.0,0.0, 1.0,0.0, 1.0,1.0, 0.0,1.0,
        0.0,0.0, 1.0,0.0, 1.0,1.0, 0.0,1.0,
        0.0,0.0, 1.0,0.0, 1.0,1.0, 0.0,1.0,
        
    };
    
    struct ArrayWrapper vertices_wrapper={vertices_position,sizeof(vertices_position),sizeof(vertices_position)/sizeof(GLfloat)};
    struct ArrayWrapper texturecoord_warpper={vertices_texture,sizeof(vertices_texture),sizeof(vertices_texture)/sizeof(GLfloat)};
    struct ArrayWrapper indices_warpper={indices_position,sizeof(indices_position),sizeof(indices_position)/sizeof(GLubyte)};
    
    [self setVertices:vertices_wrapper andTextureVertices:texturecoord_warpper andIndices:indices_warpper andDrawStyle:GL_TRIANGLE_FAN];
    
}

-(GLint)locationOfUniform:(NSString *)uniformName
{
    
    NSNumber *location=self.uniformDictionary[uniformName];
    
    NSAssert(location!=nil, @"找不到统一变量名:%@",uniformName);
    if (location==nil)
    {
      NSLog(@"错误,找不到unifrom %@ location",uniformName);
    }
    return location.intValue;
}

-(GLint)locationOfAttribute:(NSString *)attributeName
{
    NSNumber *location=self.attributeDictionary[attributeName];
    NSAssert(location!=nil, @"找不到属性名:%@",attributeName);
    return location.intValue;
}

-(void)loadIfNeed
{
    
    if (self.needLoad)
    {
        
        [self innerLoadVertix];
        [self innerloadProgram];
        self.needLoad=NO;
    }
    
}

-(void)dealloc
{
    
    glDeleteBuffers(1, &_verticesBuffer);
    glDeleteBuffers(1, &_textureBuffer);
    glDeleteBuffers(1, &_indicesBuffer);
    
    [_uniformDictionary removeAllObjects];
    [_attributeDictionary removeAllObjects];
    
}



@end
