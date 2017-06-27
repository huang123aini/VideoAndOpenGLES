//
//  HVideoRecorder.h
//  MovieCodec_AVFoundation
//
//  Created by huangshiping on 2017/6/21.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



/***
 *
 */



@class HVideoRecorder;

@protocol HRecorderDelegate <NSObject>

@required
-(void)recorderDidBeginRecording:(HVideoRecorder*_Nullable)recorder;
-(void)recorderDidEndRecording:(HVideoRecorder*_Nullable)recorder;
-(void)recorder:(HVideoRecorder*_Nullable)recorder didFinishRecordingToOutputFilePath:(nullable NSString*)outputFilePath error:(nullable NSError*)error;
@end

@class AVCaptureVideoPreviewLayer;
@interface HVideoRecorder : NSObject
@property(nonatomic,weak)id<HRecorderDelegate>delegate;
-(instancetype _Nullable )initWithOutputFilePath:(NSString*_Nullable)outputFilePath outputSize:(CGSize)outputSize;

-(void)startRunning;
-(void)stopRunning;


-(void)startRecording;
-(void)stopRecording;

-(void)swapFrontAndBackCameras;
-(AVCaptureVideoPreviewLayer*_Nullable)previewLayer;

@end


























