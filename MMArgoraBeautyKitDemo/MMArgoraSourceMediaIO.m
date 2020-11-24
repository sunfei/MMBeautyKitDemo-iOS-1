//
//  MMArgoraSourceMediaIO.m
//  MMArgoraBeautyKitDemo
//
//  Created by sunfei on 2020/11/23.
//  Copyright © 2020 sunfei. All rights reserved.
//

#import "MMArgoraSourceMediaIO.h"
#import "MMCamera.h"
#import "MMBeautyRender.h"

@interface MMArgoraSourceMediaIO () <MMCameraDelegate>

@property (nonatomic, strong) MMCamera *camera;
@property (nonatomic, assign) UIInterfaceOrientation orientation;
@property (nonatomic, strong) id<NSObject> viewOrientationObserver;

@end

@implementation MMArgoraSourceMediaIO

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.viewOrientationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillChangeStatusBarOrientationNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            UIInterfaceOrientation orientation = (UIInterfaceOrientation)note.userInfo[UIApplicationStatusBarOrientationUserInfoKey];
            self.orientation = orientation;
        }];
        
    }
    return self;
}

#pragma mark - AgoraVideoSourceProtocol methods
@synthesize consumer = _consumer;

- (BOOL)shouldInitialize {
    self.camera = [[MMCamera alloc] init];
    self.camera.delegate = self;

    return YES;
}

- (void)shouldStart {
    [self.camera startCapture];
}

- (void)shouldStop {
    [self.camera stopCapture];
}

- (void)shouldDispose {
    self.camera = nil;
}

- (AgoraVideoBufferType)bufferType {
    return AgoraVideoBufferTypePixelBuffer;
}

- (AgoraVideoCaptureType)captureType {
    return AgoraVideoCaptureTypeCamera;
}

- (AgoraVideoContentHint)contentHint {
    return AgoraVideoContentHintNone;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.viewOrientationObserver];
    self.viewOrientationObserver = nil;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate methods
- (void)camera:(MMCamera *)camera didOutputPixelBuffer:(CVPixelBufferRef)pixelBuffer timestamp:(CMTime)timestamp {
    CVPixelBufferRef renderedPixelBuffer = [self.delegate mediaIO:self pixelBuffer:pixelBuffer timestamp:timestamp];
    [self.consumer consumePixelBuffer:renderedPixelBuffer withTimestamp:timestamp rotation:AgoraVideoRotationNone];
}

@end
