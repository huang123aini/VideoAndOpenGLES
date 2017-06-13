//
//  HLogger.h
//  HTools
//
//  Created by huangshiping on 2017/6/12.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLogger : NSObject

@property(nonatomic,assign)BOOL enable;

+(instancetype)singleTon;

-(void)log:(NSString *)formatStr,...NS_FORMAT_FUNCTION(1,2);

@end
