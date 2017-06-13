//
//  ImageTestVc.m
//  HTools
//
//  Created by huangshiping on 2017/6/13.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "ImageTestVc.h"

#import <MobileCoreServices/MobileCoreServices.h>

#import "HESNode.h"

#import "HAlphaFilter.h"

#import "HNodeImageView.h"

#import "HImageInput.h"

#import "HNodeLayer.h"

#import "HESContext.h"


@implementation ImageTestVc
{
    
    UIImage *_image;
    
    HNodeImageView*  _customView;
    HImageInput*     _operationSource;
    HImageInput*     _operationSecondSource;
    
    
    HESNode*         _thirdNode;
    HNodeLayer*      _secondNode;
    
    HNodeLayer*      _starLayer1,*_starLayer2;
    
    CADisplayLink*   _displayLink;
    
    HAlphaFilter *   _alphaNode;
    
    UIButton*        _button;
    
    BOOL             _stoped;
    
    dispatch_queue_t _workQueue;
    
    BOOL             _invalidate;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    CGSize screenSize=[UIScreen mainScreen].bounds.size;
    
    _customView=[[HNodeImageView alloc]initWithFrame:CGRectMake(0, 0,screenSize.width, screenSize.height)];

    [self.view addSubview:_customView];
    
    [self initLayer];
    
    [_customView setContentProviderNode:_thirdNode];
    
    __weak typeof (self) weakSelf=self;
    
    _displayLink=[CADisplayLink displayLinkWithTarget:weakSelf selector:@selector(startRun)];
    
    _displayLink.paused=YES;
    
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    _button=[[UIButton alloc]initWithFrame:CGRectMake(0, screenSize.height-100, 50, 40)];
    
    [_button setTitle:@"挂起" forState:UIControlStateNormal];
    [_button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:weakSelf action:@selector(stopGPUQueue:)];
    
    [_button addGestureRecognizer:tap];
    
    [self.view addSubview:_button];
    
    _workQueue=dispatch_queue_create([@"工作线程" UTF8String], DISPATCH_QUEUE_CONCURRENT);
    
    
}

-(void)showNotifice
{
    
}

-(void)stopGPUQueue:(id)sender
{
    
    if (_stoped)
    {
        dispatch_resume(_workQueue);
        _stoped=NO;
    }else
    {
        dispatch_suspend(_workQueue);
        _stoped=YES;
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    _displayLink.paused=NO;
    
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    
    [super viewDidDisappear:animated];
    
    _displayLink.paused=YES;
    
    [_displayLink invalidate];
    
    _displayLink=nil;
    
    _invalidate=YES;
    
    [_starLayer1 removeFromSuperNodeLayer];
    [_starLayer2 removeFromSuperNodeLayer];
    
}

-(void)initLayer
{
    
    NSString *path=[[NSBundle mainBundle] pathForResource:@"img2" ofType:@"jpg"];
    
    
    UIImage *image=[UIImage imageWithContentsOfFile:path];
    _operationSource=[HImageInput new];
    [_operationSource uploadImage:image];
    
    
    //给小图片添加一个AlphaShader
    UIImage *image2=[UIImage imageNamed:@"sy_0.png"];
    _operationSecondSource =[HImageInput new];
    [_operationSecondSource uploadImage:image2];
    
    _alphaNode=[HAlphaFilter new];
    [_alphaNode addDependency:_operationSecondSource];
    
    
    
    
    
    
    _secondNode=[HNodeLayer new];
    [_secondNode addDependency:_operationSource];
    
    
    
    
    _starLayer1=[HNodeLayer new];
    [_starLayer1 addDependency:_operationSecondSource];
    _starLayer1.frame=CGRectMake(400.0, 300.0, 100 ,100);
    
    [_secondNode addSubNodeLayer:_starLayer1];
    
    _starLayer1.opaticy=1.0f;
    
    _starLayer2=[HNodeLayer new];
    
    
    [_starLayer2 addDependency:_operationSecondSource];
    
    _starLayer2.opaticy=0.0;
    
    _starLayer2.frame=_starLayer1.frame;
    
    [_secondNode addSubNodeLayer:_starLayer2];
    
    _thirdNode=_secondNode;
    
}

-(void)startRun
{
    
    //dispatch_barrier_async will crash
    
    dispatch_barrier_async(_workQueue, ^{
        
        if([HESContext currentGLContext]==nil)
        {
            [HESContext pushContext];
        }
        
        if (_invalidate)
        {
            return ;
        }
        
        static float scale=1.0f,alpha=0.0f;
        
        _starLayer2.transform=GLKMatrix4Scale(GLKMatrix4Identity, scale, scale, 1.0);
        _starLayer2.opaticy=alpha;
        
        scale+=0.05f;
        
        alpha+=0.05f;
        
        if (scale>2.0f)
        {
            
            scale=1.0f;
        }
        
        if (alpha>1.0)
        {
            
            alpha=0.0f;
        }
        
        
        [_operationSource drive];
        
        [_operationSecondSource drive];
    });
    
}

-(void)dealloc
{
    
    [_displayLink invalidate];
    
    [HESContext popContext];
    
    NSLog(@"图片测试页面已经销毁了:%@",self);
    
}
@end
