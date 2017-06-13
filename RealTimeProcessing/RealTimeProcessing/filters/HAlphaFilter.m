//
//  HAlphaFilter.m
//  HTools
//
//  Created by huangshiping on 2017/6/13.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HAlphaFilter.h"

#import "HMacros.h"

@implementation HAlphaFilter

- (instancetype)init
{
    if (self = [super initWithFragmentShader:H_ALPHAFILTER_FRAGMENT_SHADER])
    {
        
    }
    return self;
}
@end
