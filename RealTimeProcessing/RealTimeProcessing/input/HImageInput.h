//
//  HImageInput.h
//  HTools
//
//  Created by huangshiping on 2017/6/13.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HNodeInput.h"

@interface HImageInput : HNodeInput

-(void)uploadImage:(UIImage *_Nonnull)image;

-(void)uploadAnimationableImages:(NSArray<UIImage*>* _Nonnull)images;

@end
