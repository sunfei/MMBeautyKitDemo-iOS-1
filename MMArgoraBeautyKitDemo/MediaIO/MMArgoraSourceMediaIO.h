//
//  MMArgoraSourceMediaIO.h
//  MMArgoraBeautyKitDemo
//
//  Created by sunfei on 2020/11/23.
//  Copyright © 2020 sunfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgoraRtcKit/AgoraRtcEngineKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MMArgoraSourceMediaIO;

@protocol MMArgoraSourceMediaIODelegate <NSObject>

- (CVPixelBufferRef)mediaIO:(MMArgoraSourceMediaIO *)mediaIO pixelBuffer:(CVPixelBufferRef)pixelBuffer timestamp:(CMTime)time;

@end

@interface MMArgoraSourceMediaIO : NSObject <AgoraVideoSourceProtocol>

@property (nonatomic, weak) id<MMArgoraSourceMediaIODelegate> delegate;

@end

NS_ASSUME_NONNULL_END
