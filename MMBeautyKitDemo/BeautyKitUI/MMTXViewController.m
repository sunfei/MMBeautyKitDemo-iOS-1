//
//  MMTXViewController.m
//  MMBeautyKitDemo
//
//  Created by sunfei on 2020/9/2.
//  Copyright © 2020 sunfei. All rights reserved.
//

#import "MMTXViewController.h"
#import <CoreVideo/CoreVideo.h>
#import <TXLivePush.h>
#import <TXLiveBase.h>

@interface MMTXViewController () <TXLivePushListener, TXVideoCustomProcessDelegate> {
    BOOL                _appIsInActive;
    BOOL                _appIsBackground;
    
    UIView *_localView;
    
    CVOpenGLESTextureRef _texture;
    GLuint _ret;
    GLuint _fbo;
}

@property (nonatomic, strong) UIButton *btnPush;
@property (nonatomic, strong) UIButton *btnCamera;
@property (nonatomic, strong) UIButton *btnBeauty;

@property (nonatomic, strong) TXLivePush *pusher;

@property (nonatomic) CVPixelBufferPoolRef pixelBufferPool;
@property (nonatomic) CVOpenGLESTextureCacheRef coreVideoTextureCache;

@property (nonatomic,strong) CIContext *ciContext;

@end

@implementation MMTXViewController

- (void)dealloc {
    [self stopPush];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString * const licenceURL = @"http://license.vod2.myqcloud.com/license/v1/081ecb13f801e7decb2174df1640b1d7/TXLiveSDK.licence";
        NSString * const licenceKey = @"dbcb695c25a61db355114a4e76e900d3";
        
        //TXLiveBase 位于 "TXLiveBase.h" 头文件中
        [TXLiveBase setLicenceURL:licenceURL key:licenceKey];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    _pusher = [self createPusher];
    
    [self setupViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)setupViews {
    self.title = @"腾讯RTMP推流";
    
    self.btnPush = [self createButton:@"推流" action:@selector(clickPush:) center:CGPointMake(10 + 20 / 2, 100) size:80];
    [self.btnPush setBackgroundColor:UIColor.greenColor];
    [self.view addSubview:self.btnPush];
    
    _localView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:_localView atIndex:0];
    _localView.center = self.view.center;
}

- (UIButton *)createButton:(NSString*)icon action:(SEL)action center:(CGPoint)center size:(int)size {
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.bounds = CGRectMake(0, 0, size, size);
    btn.center = center;
    [btn setTitle:icon forState:UIControlStateNormal];
    btn.tag = 0; // 用这个来记录按钮的状态，默认0
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    return btn;
}

- (TXLivePush *)createPusher {
    TXLivePushConfig *config = [[TXLivePushConfig alloc] init];
    config.pauseFps = 10;
    config.pauseTime = 300;
    config.pauseImg = [UIImage imageNamed:@"pause_publish"];
    config.touchFocus = NO;
    config.enableZoom = NO;
    config.enablePureAudioPush = NO;
    config.enableAudioPreview = NO;
    NSInteger audioQuality = 2;
    switch (audioQuality) {
        case 2:
            // 音乐音质，采样率48000
            config.audioChannels = 2;
            config.audioSampleRate = AUDIO_SAMPLE_RATE_48000;
            break;
        case 1:
            // 标准音质，采样率48000
            config.audioChannels = 1;
            config.audioSampleRate = AUDIO_SAMPLE_RATE_48000;
            break;
        case 0:
            // 语音音质，采样率16000
            config.audioChannels = 1;
            config.audioSampleRate = AUDIO_SAMPLE_RATE_16000;
            break;
        default:
            break;
    }
    config.frontCamera = _btnCamera.tag == 0 ? YES : NO;
    // 推流器初始化
    TXLivePush *pusher = [[TXLivePush alloc] initWithConfig:config];
    [pusher toggleTorch:NO];
    [pusher setMirror:NO];
    [pusher setMute:NO];
    [pusher setVideoQuality:VIDEO_QUALITY_SUPER_DEFINITION adjustBitrate:NO adjustResolution:NO];
    [pusher setVideoProcessDelegate:self];
    
#ifdef ENABLE_CUSTOM_MODE_AUDIO_CAPTURE
    config.enableAEC = NO;
    config.customModeType = CUSTOM_MODE_AUDIO_CAPTURE;
    config.audioSampleRate = CUSTOM_AUDIO_CAPTURE_SAMPLERATE;
    config.audioChannels = CUSTOM_AUDIO_CAPTURE_CHANNEL;
#endif
    
    config.enableHWAcceleration = YES;
    
    config.homeOrientation = HOME_ORIENTATION_DOWN;
    [pusher setRenderRotation:0];

    [pusher setLogViewMargin:UIEdgeInsetsMake(120, 10, 60, 10)];
    [pusher showVideoDebugLog:NO];
    [pusher setEnableClockOverlay:NO];
    
    [pusher setConfig:config];
    
    return pusher;
}

- (void)clickPush:(UIButton *)btn {
    if ([self.pusher isPublishing]) {
        [self stopPush];
        [btn setBackgroundColor:UIColor.greenColor];
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    } else {
        if ([self startPush]) {
            [btn setBackgroundColor:UIColor.redColor];
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        }
    }
}

- (void)clickCamera:(UIButton *)btn {
    [self.pusher switchCamera];
    [btn setBackgroundColor:self.pusher.frontCamera ? UIColor.redColor : UIColor.greenColor];
}

- (void)clickBeauty:(UIButton *)btn {
    
}

- (BOOL)startPush {
    NSString *rtmpURL = @"rtmp://172.16.139.16:1935/myapp/sunfei";
    
    AVAuthorizationStatus statusVideo = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (statusVideo == AVAuthorizationStatusDenied) {
        return NO;
    }
    
    // 检查麦克风权限
    AVAuthorizationStatus statusAudio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (statusAudio == AVAuthorizationStatusDenied) {
        return NO;
    }
    
    [self.pusher setDelegate:self];
    
    [self.pusher startPreview:_localView];
    
    int ret = [_pusher startPush:rtmpURL];
    if (ret != 0) {
        NSLog(@"推流器启动失败");
        return NO;
    }
    
    return YES;
}

- (void)stopPush {
    if (self.pusher) {
        [self.pusher setDelegate:nil];
        [self.pusher stopPreview];
        [self.pusher stopPush];
    }
}

#pragma mark - TXLivePushListener

- (void)onPushEvent:(int)evtID withParam:(NSDictionary *)param {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (evtID == PUSH_ERR_NET_DISCONNECT || evtID == PUSH_ERR_INVALID_ADDRESS) {
            // 断开连接时，模拟点击一次关闭推流
            [self clickPush:self->_btnPush];
            
        } else if (evtID == PUSH_ERR_OPEN_CAMERA_FAIL) {
            [self clickPush:self->_btnPush];
            NSLog(@"获取摄像头权限失败，请前往隐私-相机设置里面打开应用权限");
            
        } else if (evtID == PUSH_EVT_OPEN_CAMERA_SUCC) {
            [self.pusher toggleTorch:NO];
            
        } else if (evtID == PUSH_ERR_OPEN_MIC_FAIL) {
            [self clickPush:self->_btnPush];
            NSLog(@"获取麦克风权限失败，请前往隐私-麦克风设置里面打开应用权限");
            
        } else if (evtID == PUSH_EVT_CONNECT_SUCC) {
            [self.pusher setMute:NO];
            [self.pusher showVideoDebugLog:NO];
            [self.pusher setMirror:NO];
        } else if (evtID == PUSH_WARNING_NET_BUSY) {
            NSLog(@"您当前的网络环境不佳，请尽快更换网络保证正常直播");
        }
        
        // log
        NSLog(@"params = %@", param);
    });
}

- (void)onNetStatus:(NSDictionary *)param {
    NSLog(@"param = %@", param);
}

#pragma mark - pixelbuffer

- (void)createPixelBufferPoolWithPixelBufferSizeIfNeeded:(CGSize)size {
    if (self.pixelBufferPool) {
        NSDictionary *pixelBufferPoolAttributes = (__bridge NSDictionary *)(CVPixelBufferPoolGetPixelBufferAttributes(self.pixelBufferPool));
        if ([pixelBufferPoolAttributes[(id)kCVPixelBufferWidthKey] integerValue] == (NSInteger)size.width &&
            [pixelBufferPoolAttributes[(id)kCVPixelBufferHeightKey] integerValue] == (NSInteger)size.height) {
            return;
        }
    }
    
    if (self.pixelBufferPool) {
        CVPixelBufferPoolRelease(self.pixelBufferPool);
        self.pixelBufferPool = NULL;
    }
    
    CVPixelBufferPoolRef outputPool = NULL;
    NSDictionary *sourcePixelBufferOptions = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
                                               (id)kCVPixelBufferWidthKey : @(size.width),
                                               (id)kCVPixelBufferHeightKey : @(size.height),
                                               (id)kCVPixelFormatOpenGLESCompatibility : @(YES),
                                               (id)kCVPixelBufferIOSurfacePropertiesKey : @{ /*empty dictionary*/ }};
    NSDictionary *pixelBufferPoolOptions = @{ (id)kCVPixelBufferPoolMinimumBufferCountKey: @(30)};
    
    CVPixelBufferPoolCreate(kCFAllocatorDefault, (__bridge CFDictionaryRef)pixelBufferPoolOptions, (__bridge CFDictionaryRef)sourcePixelBufferOptions, &outputPool);
    self.pixelBufferPool = outputPool;
}

#pragma mark - TXVideoCustomProcessDelegate methods

- (CVOpenGLESTextureCacheRef)coreVideoTextureCache {
    if (_coreVideoTextureCache == NULL) {
#if defined(__IPHONE_6_0)
        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, [EAGLContext currentContext], NULL, &_coreVideoTextureCache);
#else
        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, (__bridge void *)[EAGLContext currentContext], NULL, &_coreVideoTextureCache);
#endif
        
        if (err) {
            NSAssert(NO, @"Error at CVOpenGLESTextureCacheCreate %d", err);
        }
        
    }
    
    return _coreVideoTextureCache;
}

- (GLuint)onPreProcessTexture:(GLuint)texture width:(CGFloat)width height:(CGFloat)height {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (!self.ciContext) {
        self.ciContext = [CIContext contextWithEAGLContext:[EAGLContext currentContext] options:@{(id)kCIContextWorkingColorSpace : (__bridge id)colorSpace}];
    }
    CIImage *image = [CIImage imageWithTexture:texture size:CGSizeMake(width, height) flipped:NO colorSpace:colorSpace];
    CGColorSpaceRelease(colorSpace);
    
//    [self createPixelBufferPoolWithPixelBufferSizeIfNeeded:CGSizeMake(width, height)];
//
//    CVPixelBufferRef pixelBuffer = NULL;
//    CVReturn err = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault, self.pixelBufferPool, (__bridge CFDictionaryRef)(@{(id)kCVPixelBufferPoolAllocationThresholdKey : @30}), &pixelBuffer);
//    if (err || pixelBuffer == NULL) {
//        pixelBuffer = NULL;
//        if (err || pixelBuffer == NULL) {
//            pixelBuffer = NULL;
//            if ( err == kCVReturnWouldExceedAllocationThreshold ) {
//                CVOpenGLESTextureCacheFlush(self.coreVideoTextureCache, 0);
//            } else {
//                NSLog(@"%@: Error at CVPixelBufferPoolCreatePixelBuffer %@", self, @(err));
//            }
//            return 0;
//        }
//    }
//
//    if (_texture) {
//        CFRelease(_texture);
//    }
//    CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.coreVideoTextureCache, pixelBuffer,
//                                                 NULL, // texture attributes
//                                                 GL_TEXTURE_2D,
//                                                 GL_RGBA, // opengl format
//                                                 (GLint)width,
//                                                 (GLint)height,
//                                                 GL_BGRA, // native iOS format
//                                                 GL_UNSIGNED_BYTE,
//                                                 0,
//                                                 &_texture);
//    glBindTexture(CVOpenGLESTextureGetTarget(_texture), CVOpenGLESTextureGetName(_texture));
    
    glDeleteTextures(1, &_ret);
    glGenTextures(1, &_ret);
    glBindTexture(GL_TEXTURE_2D, _ret);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    if (!_fbo) {
        glGenFramebuffers(1, &_fbo);
    }
    glBindFramebuffer(GL_FRAMEBUFFER, _fbo);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _ret, 0);
    glViewport(0, 0, width, height);

    glClearColor(1.0, 1.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self.ciContext drawImage:image inRect:CGRectMake(0, 0, width, height) fromRect:image.extent];

    glFlush();
//    CVPixelBufferRelease(pixelBuffer);
    
    return _ret;
}

- (void)onTextureDestoryed {
    glDeleteFramebuffers(1, &_fbo);
    glDeleteTextures(1, &_ret);
//    CVOpenGLESTextureCacheFlush(self.coreVideoTextureCache, 0);
}

#pragma mark - notification methods

- (void)onAppWillResignActive:(NSNotification *)notification {
    _appIsInActive = YES;
    [_pusher pausePush];
}

- (void)onAppDidBecomeActive:(NSNotification *)notification {
    _appIsInActive = NO;
    if (!_appIsBackground && !_appIsInActive) {
        [_pusher resumePush];
    }
}

- (void)onAppDidEnterBackGround:(NSNotification *)notification {
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
    }];
    _appIsBackground = YES;
    [_pusher pausePush];
}

- (void)onAppWillEnterForeground:(NSNotification *)notification {
    _appIsBackground = NO;
    if (!_appIsBackground && !_appIsInActive) {
        [_pusher resumePush];
    }
}

@end
