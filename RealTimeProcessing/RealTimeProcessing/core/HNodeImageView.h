//
//  HNodeImageView.h
//  HTools
//
//  Created by huangshiping on 2017/6/13.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HESNode.h"

typedef enum
{
    kNodeImageFillModeFillModeStretch, // Stretch to fill the full view, which may distort the image outside of its normal aspect ratio
    kNodeImageFillModePreserveAspectRatio,  // Maintains the aspect ratio of the source image, adding bars of the specified background color
    kNodeImageFillModePreserveAspectRatioAndFill     // Maintains the aspect ratio of the source image, zooming in on its center to fill the view
} HNodeImageFillModeType;


typedef enum
{ kNodeImageNoRotation,
    kNodeImageRotateLeft,
    kNodeImageRotateRight,
    kNodeImageFlipVertical,
    kNodeImageFlipHorizonal,
    kNodeImageRotateRightFlipVertical,
    kNodeImageRotateRightFlipHorizontal,
    kNodeImageRotate180
} NodeImageRotationMode;


/**
 *  类似GPUImageView
 */
@interface HNodeImageView : UIView

@property(nonatomic,assign) HNodeImageFillModeType fillMode;

-(void)setContentProviderNode:(HESNode*_Nullable)contentNode;

@end
