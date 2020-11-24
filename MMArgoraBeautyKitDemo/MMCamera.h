//
//  MMCamera.h
//  MMArgoraBeautyKitDemo
//
//  Created by sunfei on 2020/11/24.
//  Copyright © 2020 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MMCamera;

@protocol MMCameraDelegate <NSObject>

- (void)camera:(MMCamera *)camera didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer timestamp:(CMTime)timestamp;

@end

@interface MMCamera : NSObject

- (void)switchCamera;
- (void)startCapture;
- (void)stopCapture;

@property (nonatomic, weak) id<MMCameraDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
