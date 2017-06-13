//
//  HCVPixelBufferInput.h
//  HTools
//
//  Created by huangshiping on 2017/6/13.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HNodeInput.h"

@interface HCVPixelBufferInput : HNodeInput

-(void)uploadCVPixelBuffer:(CVPixelBufferRef _Nonnull)pixelBufferRef;


@end
