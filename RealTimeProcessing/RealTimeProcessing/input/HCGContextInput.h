//
//  HCGContextInput.h
//  HTools
//
//  Created by huangshiping on 2017/6/13.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HNodeInput.h"

@interface HCGContextInput : HNodeInput
-(instancetype _Nonnull)initWithSize:(CGSize)size;

//(left botton is (0,0))
-(void)commitCGContextTransaction:(void(^_Nullable)(CGContextRef _Nonnull))drawBlock;

@end
