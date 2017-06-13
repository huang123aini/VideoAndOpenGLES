//
//  HI420Input.h
//  HTools
//
//  Created by huangshiping on 2017/6/13.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HNodeInput.h"

@interface HI420Input : HNodeInput

/**
*  @param baseAddress 数据指针
*  @param dataSize    数据大小
*  @param imageSize   图像大小
*/
-(void)uploadI420Data:(uint8_t*)baseAddress andDataSize:(size_t)dataSize andImageSize:(CGSize)imageSize;

@end
