////
////  HFBO.m
////  PureOpenGLES
////
////  Created by huangshiping on 2017/6/13.
////  Copyright © 2017年 huangshiping. All rights reserved.
////
//
//#import "HFBO.h"
//
//#import "HFBONone.h"
//
//#import "HFBOMSAA.h"
//
//#pragma mark
//
//@implementation HFBO
//
//- (id)init
//{
//    @throw [NSException exceptionWithName:NSInternalInconsistencyException
//                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
//                                 userInfo:nil];
//}
//
//- (id)initWithWidth:(GLsizei)width height:(GLsizei)height
//{
//    if (self = [super init])
//    {
//        _width = width;
//        _height = height;
//    }
//    return self;
//}
//
//- (void)setWidth:(GLsizei)width
//{
//    if (_width != width)
//    {
//        _width = width;
//        self.changed = YES;
//    }
//}
//
//- (void)setHeight:(GLsizei)height
//{
//    if (_height != height)
//    {
//        _height = height;
//        self.changed = YES;
//    }
//}
//
//- (void)prepareToDraw
//{
//    [NSException raise:NSInternalInconsistencyException
//                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
//}
//
//+ (HFBO *)generateFBO:(FBOType)type width:(GLsizei)width height:(GLsizei)height;
//{
//    switch (type)
//    {
//        case FBO_NONE:
//        default:
//            return [[HFBONone alloc] initWithWidth:width height:height];
//            
//        case FBO_MSAA:
//            return [[HFBOMSAA alloc] initWithWidth:width height:height];
//    }
//}
//
//@end
