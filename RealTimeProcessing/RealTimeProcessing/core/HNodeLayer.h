//
//  HNodeLayer.h
//  HTools
//
//  Created by huangshiping on 2017/6/13.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HESNode.h"

@interface HNodeLayer : HESNode

@property(nonatomic,assign)float opaticy;
@property(nonatomic,assign)CGRect frame;
@property(nonatomic,assign)GLKMatrix4 transform;//frame center as (0,0,0)

@property(nonatomic,assign,nullable,readonly)HNodeLayer* superNodeLayer;

@property(nonatomic,assign)BOOL hidden;//default is NO

@property(nonatomic,assign)CGPoint center;//like UIVew center property,not available before set frame property

@property(nonatomic,copy,readonly,nonnull) NSArray<__kindof HNodeLayer*>* subNodeLayer;//


-(void)addSubNodeLayer:(HNodeLayer*_Nonnull)subLayer;
-(void)removeSubNodeLayer:(HNodeLayer*_Nonnull)subLayer;
-(void)removeFromSuperNodeLayer;
-(void)layoutSubNodeLayerOfNodeLayer:(HNodeLayer*_Nonnull)parentLayer;

@end
