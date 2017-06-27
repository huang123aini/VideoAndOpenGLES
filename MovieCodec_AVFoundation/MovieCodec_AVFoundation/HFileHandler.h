//
//  HFileHandler.h
//  MovieCodec_AVFoundation
//
//  Created by huangshiping on 2017/6/20.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>


@interface HFileHandler : NSObject


-(NSString*)pathToDocumentsDirectory;


-(AVURLAsset*)getAssetURLFromFileName:(NSString*)fileName;

-(AVURLAsset*)getAssetURLFromBundleWithFileName:(NSString*)fileName;

@end

