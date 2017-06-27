//
//  HVideoSession.h
//  MovieCodec_AVFoundation
//
//  Created by huangshiping on 2017/6/21.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

@protocol HSessionDelegate;

@interface HVideoSession : NSObject

@property(nonatomic,readonly)BOOL videoInitialized;
@property(nonatomic,readonly)BOOL audioInitialized;

@property(nonatomic,weak)id<HSessionDelegate>delegate;

-(instancetype)initWithTempFilePath:(NSString*)tempFilePath;

-(void)addVideoTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formatDescription settings:(NSDictionary*)videoSettings;/**<添加视轨格式描述*/

-(void)addAudioTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formatDescription settings:(NSDictionary*)audioSettings;/**<添加音轨格式描述*/


-(void)appendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;/**<添加视轨 取样缓存*/
-(void)appendAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;/**<添加音轨 取样缓存*/


-(void)prepareToRecord;
-(void)finishRecording;

@end

@protocol HSessionDelegate <NSObject>

-(void)sessionDidFinishPreparing:(HVideoSession*)session;/**<准备好Session*/
-(void)session:(HVideoSession*)session didFailWithError:(NSError*)error;/**<Session失败*/
-(void)sessionDidFinishRecording:(HVideoSession*)session;/**<录制完成*/

@end
































