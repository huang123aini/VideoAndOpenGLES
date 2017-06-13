//
//  HNodeInput.h
//  HTools
//
//  Created by huangshiping on 2017/6/13.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HESNode.h"

@interface HNodeInput : HESNode

@property(nonatomic,assign) BOOL textureAvailable;//纹理是否可用

-(void)prepareForRender;

/**
 *  drive the node tree be traversals
 */
-(void)drive;

-(void)invalidateNodeContent;

-(void)bindTexture:(GLuint)textureId;


@end
