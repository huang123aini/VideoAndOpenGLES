//
//  HLogger.m
//  HTools
//
//  Created by huangshiping on 2017/6/12.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HLogger.h"

@interface HLogger ()

@property(nonatomic,retain)NSFileHandle *fileHandler;

@end

@implementation HLogger

static HLogger *instance;

+(instancetype)singleTon
{
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        instance = [[self alloc] init];
        
        NSString *documentsDirectory =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSDate *date=[NSDate date];
        
        NSDateFormatter *formatter=[NSDateFormatter new];
        [formatter setDateFormat:@"yyyy_MM_dd"];
        
        NSString *fileName =[NSString stringWithFormat:@"HTools:_%@.log",[formatter stringFromDate:date]];
        
        NSString *logFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
        
        NSFileManager *fileManager=[NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:logFilePath]==NO)
        {
            
            [fileManager createFileAtPath:logFilePath contents:nil attributes:NULL];
            
        }
        
        NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:logFilePath];
        
        instance.fileHandler=outFile;
        
    });
    
    return instance;
    
}

-(void)log:(NSString *)formatStr, ...{
    
    if (!formatStr||!self.enable) return ;
    
    va_list arglist;
    
    va_start(arglist, formatStr);
    
    NSString *outStr = [[NSString alloc] initWithFormat:formatStr arguments:arglist];
    
    va_end(arglist);
    
    static NSDateFormatter *sFormatter;
    
    if (!sFormatter)
    {
        
        NSDateFormatter *formatter=[NSDateFormatter new];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        sFormatter=formatter;
    }
    
    outStr =[NSString stringWithFormat:@"%@:%@\n",[sFormatter stringFromDate:[NSDate date]],outStr];
    
    [self.fileHandler seekToEndOfFile];
    
    [self.fileHandler writeData:[outStr dataUsingEncoding:NSUTF8StringEncoding]];

}


@end
