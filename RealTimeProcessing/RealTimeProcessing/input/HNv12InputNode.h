//
//  HNv12InputNode.h
//  HTools
//
//  Created by huangshiping on 2017/6/13.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HNodeInput.h"

@interface HNv12InputNode : HNodeInput

-(void)uploadNV12Data:(uint8_t*)baseAddress andDataSize:(size_t)dataSize andImageSize:(CGSize)imageSize;

-(void)setFullRange:(BOOL)fullRange;

-(void)setBT709:(BOOL)yes;



@end
