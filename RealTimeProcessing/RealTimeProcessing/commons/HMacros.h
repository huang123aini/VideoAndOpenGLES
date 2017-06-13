//
//  HMacros.h
//  HTools
//
//  Created by huangshiping on 2017/6/12.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#ifndef HMacros_h
#define HMacros_h

//自定义打印
#ifdef DEBUG // 处于开发节点
#define HLog(...) NSLog(__VA_ARGS__)
#else  // 处于发布节点
#define HLog(...)
#endif


//关于OPENGL ES  Shader
#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

#define H_VERTEX_SHADER [[NSBundle mainBundle] pathForResource:@"modelShader" ofType:@"vsh"]
#define H_FRAGMENT_SHADER [[NSBundle mainBundle] pathForResource:@"modelShader" ofType:@"fsh"]

//NV12 Fragment
#define H_NV12_FRAGMENT_SHADER [[NSBundle mainBundle] pathForResource:@"nv12Shader" ofType:@"fsh"]

//I420 Fragment
#define H_I420_FRAGMENT_SHADER [[NSBundle mainBundle] pathForResource:@"i420Shader" ofType:@"fsh"]

#define H_CVPIXELBUFFER_FRAGMENT_SHADER [[NSBundle mainBundle] pathForResource:@"cvPixelBufferShader" ofType:@"fsh"]


#pragma mark --------effect Filters---------
#define H_ALPHAFILTER_FRAGMENT_SHADER [[NSBundle mainBundle] pathForResource:@"alphaShader" ofType:@"fsh"]

#define H_BLENDSHADER_FRAGMENT_SHADER [[NSBundle mainBundle] pathForResource:@"blendShader" ofType:@"fsh"]

#endif /* HMacros_h */
