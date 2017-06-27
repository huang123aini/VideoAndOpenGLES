//
//  HToolBox.h
//  MovieCodec_AVFoundation
//
//  Created by huangshiping on 2017/6/20.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HExporter.h"
#import "HImageSequencer.h"
#import "HComposer.h"
#import "HFileHandler.h"

@interface HToolBox : NSObject

@property(nonatomic,strong) HExporter *exporter;
@property(nonatomic,retain) HImageSequencer *imageSequencer;
@property(nonatomic,retain) HComposer *composer;
@property(nonatomic,retain) HFileHandler* fileHandler;

+ (HToolBox *)sharedToolbox;

@end
