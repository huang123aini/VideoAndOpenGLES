//
//  HImageView.h
//  MovieCodec_AVFoundation
//
//  Created by huangshiping on 2017/6/21.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HImageView : UIView

@property (readonly, nonatomic) CGSize sizeInPixels;

- (instancetype)initWithFrame:(CGRect)frame videoPath:(NSString *)videoPath previewImage:(UIImage *)previewImage;

- (void)play;

- (void)stop;

@end
