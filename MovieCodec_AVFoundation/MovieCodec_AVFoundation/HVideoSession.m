//
//  HVideoSession.m
//  MovieCodec_AVFoundation
//
//  Created by huangshiping on 2017/6/21.
//  Copyright © 2017年 huangshiping. All rights reserved.
//

#import "HVideoSession.h"

typedef NS_ENUM(NSInteger, HSessionStatus)
{
    HSessionStatusIdle = 0,
    HSessionStatusPreparingToRecord,
    HSessionStatusRecording,
    HSessionStatusFinishingRecordingPart1, // waiting for inflight buffers to be appended
    HSessionStatusFinishingRecordingPart2, // calling finish writing on the asset writer
    HSessionStatusFinished,
    HSessionStatusFailed
};

@interface HVideoSession()
@property(nonatomic,assign)HSessionStatus status;
@property(nonatomic)dispatch_queue_t writingQueue;
@property(nonatomic)dispatch_queue_t delegateCallbackQueue;

@property(nonatomic)NSString* tempFilePath;
@property(nonatomic)AVAssetWriter* assetWriter;
@property(nonatomic)BOOL haveStartedSession;

@property(nonatomic)CMFormatDescriptionRef videoTrackSourceFormatDescription;
@property(nonatomic)CMFormatDescriptionRef audioTrackSourceFormatDescription;

@property(nonatomic)NSDictionary* videoTrackSettings;
@property(nonatomic)NSDictionary* audioTrackSettings;

@property(nonatomic)AVAssetWriterInput* videoInput;
@property(nonatomic)AVAssetWriterInput* audioInput;

@property(nonatomic)CGAffineTransform videoTrackTransform;


@end

@implementation HVideoSession

-(instancetype)initWithTempFilePath:(NSString *)tempFilePath
{
    if (!tempFilePath)
    {
        return nil;
    }
    
    if (self = [super init])
    {
        _delegateCallbackQueue = dispatch_queue_create("HVideoSession.DelegateCallBack", DISPATCH_QUEUE_SERIAL);
        _writingQueue = dispatch_queue_create("HVideoSession.Writer", DISPATCH_QUEUE_SERIAL);
        _videoTrackTransform = CGAffineTransformMakeRotation(M_PI_2); //竖直方向
        _tempFilePath = tempFilePath;
    }
    return self;
}

-(void)dealloc
{
    [_assetWriter cancelWriting];
}
-(void)addVideoTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formatDescription settings:(NSDictionary *)videoSettings
{
    @synchronized (self)
    {
        self.videoTrackSourceFormatDescription = (CMFormatDescriptionRef)CFRetain(formatDescription);
        self.videoTrackSettings = [videoSettings copy];
    }
}
-(void)addAudioTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formatDescription settings:(NSDictionary *)audioSettings
{
    @synchronized (self)
    {
        self.audioTrackSourceFormatDescription = (CMFormatDescriptionRef)CFRetain(formatDescription);
        self.audioTrackSettings = [audioSettings copy];
    }
}

-(void)appendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    [self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeVideo];
}

- (void)appendAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    [self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeAudio];
}

-(void)prepareToRecord
{
    @synchronized (self)
    {
      if (self.status != HSessionStatusIdle)
      {
        NSLog(@"已经开始准备不需要再准备");
      }
        [self transitionToStatus:HSessionStatusPreparingToRecord error:nil];
    }
    NSError* error = nil;
    //确保当前文件不存在
    [[NSFileManager defaultManager] removeItemAtPath:self.tempFilePath error:&error];
    self.assetWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:self.tempFilePath] fileType:AVFileTypeMPEG4 error:&error];
    
    //创建添加输入
    if (!error && _videoTrackSourceFormatDescription)
    {
        [self setupAssetWriterVideoInputWithSourceFormatDescription:self.videoTrackSourceFormatDescription transform:self.videoTrackTransform settings:self.videoTrackSettings error:&error];
    }
    if (!error &&_audioTrackSourceFormatDescription)
    {
        [self setupAssetWriterAudioInputWithSourceFormatDescription:self.audioTrackSourceFormatDescription settings:self.audioTrackSettings error:&error];
    }
    
    //开始
    if (!error)
    {
        BOOL success = [self.assetWriter startWriting];
        if (!success)
        {
            error = self.assetWriter.error;
        }
    }
    
    @synchronized (self)
    {
        if (error)
        {
            [self transitionToStatus:HSessionStatusFailed error:error];
        }else
        {
            [self transitionToStatus:HSessionStatusRecording error:nil];
        }
    }
    
}

-(void)finishRecording
{
    @synchronized (self)
    {
        BOOL shouldFinishRecording = NO;
        switch (self.status)
        {
            case HSessionStatusIdle:
            case HSessionStatusPreparingToRecord:
            case HSessionStatusFinishingRecordingPart1:
            case HSessionStatusFinishingRecordingPart2:
            case HSessionStatusFinished:
                NSLog(@"还没有开始记录");
                return;
                break;
            case HSessionStatusFailed:
                NSLog( @"记录失败" );
                break;
            case HSessionStatusRecording:
                shouldFinishRecording = YES;
            break;
        }
        
        if (shouldFinishRecording)
        {
            [self transitionToStatus:HSessionStatusFinishingRecordingPart1 error:nil];
        }else
        {
            return;
        }
    }
    
    dispatch_async(_writingQueue, ^{
        @autoreleasepool {
            @synchronized (self)
            {
                if (self.status != HSessionStatusFinishingRecordingPart1)
                {
                    return;
                }
                [self transitionToStatus:HSessionStatusFinishingRecordingPart2 error:nil];
            }
            
            [self.assetWriter finishWritingWithCompletionHandler:^{
                @synchronized(self)
                {
                    NSError *error = self.assetWriter.error;
                    if (error)
                    {
                        [self transitionToStatus:HSessionStatusFailed error:error];
                    } else
                    {
                        [self transitionToStatus:HSessionStatusFinished error:nil];
                    }
                }
            }];
        }
    });
}

-(void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer ofMediaType:(NSString*)mediaType
{
    if (sampleBuffer == NULL)
    {
        NSLog(@"sampleBuffer is NULL");
        return;
    }
    @synchronized (self)
    {
        if (self.status < HSessionStatusRecording)
        {
            NSLog(@"还没准备好录制");
            return;
        }
    }
    
    CFRetain(sampleBuffer);
    dispatch_async(self.writingQueue, ^{
        @autoreleasepool
        {
            @synchronized(self)
            {
                if (self.status > HSessionStatusFinishingRecordingPart1)
                {
                    CFRelease(sampleBuffer);
                    return;
                }
            }
            
            if (!self.haveStartedSession && mediaType == AVMediaTypeVideo)
            {
                [self.assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
                self.haveStartedSession = YES;
            }
            
            AVAssetWriterInput *input = (mediaType == AVMediaTypeVideo) ? self.videoInput : self.audioInput;
            
            if (input.readyForMoreMediaData)
            {
                BOOL success = [input appendSampleBuffer:sampleBuffer];
                if (!success)
                {
                    NSError *error = self.assetWriter.error;
                    @synchronized(self)
                    {
                        [self transitionToStatus:HSessionStatusFailed error:error];
                    }
                }
            } else
            {
                NSLog( @"%@ 输入不能添加更多数据了,抛弃buffer", mediaType);
            }
            CFRelease(sampleBuffer);
        }
    } );

}

-(void)transitionToStatus:(HSessionStatus)newStatus error:(NSError*)error
{
    BOOL shouldNotifyDelegate = NO;
    if (newStatus != self.status)
    {
        if ( (newStatus == HSessionStatusFinished) || (newStatus == HSessionStatusFailed))
        {
            shouldNotifyDelegate = YES;
            dispatch_async(self.writingQueue, ^{
                
                self.assetWriter = nil;
                self.videoInput = nil;
                self.audioInput = nil;
                if (newStatus == HSessionStatusFailed)
                {
                    //失败删除
                    [[NSFileManager defaultManager] removeItemAtPath:self.tempFilePath error:NULL];
                }
            });
        }else if(newStatus == HSessionStatusRecording)
        {
            shouldNotifyDelegate = YES;
        }
        self.status = newStatus;
    }
    
    if (shouldNotifyDelegate && self.delegate)
    {
        dispatch_async(self.delegateCallbackQueue, ^{
            @autoreleasepool
            {
                switch (newStatus)
                {
                    case HSessionStatusRecording:
                    {
                        [self.delegate sessionDidFinishPreparing:self];
                        break;
                    }
                    case HSessionStatusFinished:
                    {
                        [self.delegate sessionDidFinishRecording:self];
                        break;
                    }
                    case HSessionStatusFailed:
                    {
                        [self.delegate session:self didFailWithError:error];
                        break;
                    }
                        
                    default:
                        break;
                }
            }
        });
    }
}

-(BOOL)setupAssetWriterVideoInputWithSourceFormatDescription:(CMFormatDescriptionRef)videoFormatDescription transform:(CGAffineTransform)transform settings:(NSDictionary*)videoSettings error:(NSError **)errorOut
{
    if ([self.assetWriter canApplyOutputSettings:videoSettings forMediaType:AVMediaTypeVideo])
    {
        self.videoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoSettings sourceFormatHint:videoFormatDescription];
        self.videoInput.expectsMediaDataInRealTime = YES;
        self.videoInput.transform = transform;
        
        if ([self.assetWriter canAddInput:self.videoInput])
        {
            [self.assetWriter addInput:self.videoInput];
        } else
        {
            if (errorOut)
            {
                *errorOut = [self cannotSetupInputError];
            }
            return NO;
        }
    } else
    {
        if (errorOut)
        {
            *errorOut = [self cannotSetupInputError];
        }
        return NO;
    }
    return YES;
}
- (BOOL)setupAssetWriterAudioInputWithSourceFormatDescription:(CMFormatDescriptionRef)audioFormatDescription settings:(NSDictionary *)audioSettings error:(NSError **)errorOut
{
    if ([self.assetWriter canApplyOutputSettings:audioSettings forMediaType:AVMediaTypeAudio])
    {
        self.audioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:audioSettings sourceFormatHint:audioFormatDescription];
        self.audioInput.expectsMediaDataInRealTime = YES;
        
        if ([self.assetWriter canAddInput:self.audioInput])
        {
            [self.assetWriter addInput:self.audioInput];
        } else
        {
            if (errorOut)
            {
                *errorOut = [self cannotSetupInputError];
            }
            return NO;
        }
    }
    else
    {
        if (errorOut)
        {
            *errorOut = [self cannotSetupInputError];
        }
        return NO;
    }
    
    return YES;
}

-(NSError*)cannotSetupInputError
{
    NSDictionary* errorDict = @{
      NSLocalizedDescriptionKey:@"记录不能开始",
      NSLocalizedFailureReasonErrorKey:@"不能初始化Writer"
    };
    return [NSError errorWithDomain:@"HVideoSession.Writer" code:0 userInfo:errorDict];
}
@end





























