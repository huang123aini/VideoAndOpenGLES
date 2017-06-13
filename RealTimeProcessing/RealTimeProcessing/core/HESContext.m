//
//  HESContext.m
//  HTools
//
//  Created by huangshiping on 2017/6/12.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HESContext.h"

#import "HESNode.h"

@implementation HESContext

static NSMutableOrderedSet<EAGLContext*>* contexts;

static dispatch_semaphore_t s_lock;

static EAGLContext *appEAGLContext;

static CVOpenGLESTextureCacheRef globalTextureCache;

+(void)initialize
{
    
    
    if (self==[HESContext class])
    {
        
        contexts=[NSMutableOrderedSet orderedSet];
        
        s_lock=dispatch_semaphore_create(1);
        
        appEAGLContext=[[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
    }
    
}

+(void)pushContext
{
    
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    
    EAGLContext *instance;
    
    instance=[[EAGLContext alloc]initWithAPI:api sharegroup:appEAGLContext.sharegroup];
    
    dispatch_semaphore_wait(s_lock,DISPATCH_TIME_FOREVER);
    
    [contexts addObject:instance];
    
    [EAGLContext setCurrentContext:instance];
    
    dispatch_semaphore_signal(s_lock);
    
    
}

+(void)popContext
{
    
    dispatch_semaphore_wait(s_lock, DISPATCH_TIME_FOREVER);
    
    [contexts removeObject:[contexts lastObject]];
    
    EAGLContext *instance=[contexts lastObject];
    
    [EAGLContext setCurrentContext:instance];
    
    dispatch_semaphore_signal(s_lock);
    
}

+(EAGLContext *)currentGLContext
{
    
    EAGLContext *instance;
    
    dispatch_semaphore_wait(s_lock,DISPATCH_TIME_FOREVER);
    
    instance=[contexts lastObject];
    
    dispatch_semaphore_signal(s_lock);
    
    return instance;
    
}

+(CVOpenGLESTextureCacheRef)globalTextureCache
{
    
    dispatch_semaphore_wait(s_lock,DISPATCH_TIME_FOREVER);
    
    if (globalTextureCache==NULL)
    {
        
        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL,appEAGLContext, NULL, &globalTextureCache);
        
        NSAssert(err==kCVReturnSuccess, @"create global textureCache fial %i",err);
        
    }
    dispatch_semaphore_signal(s_lock);
    
    return globalTextureCache;
}
@end
