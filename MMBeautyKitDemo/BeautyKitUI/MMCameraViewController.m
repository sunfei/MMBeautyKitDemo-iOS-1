//
//  MMCameraViewController.m
//  MMBeautyKit_Example
//
//  Created by sunfei on 2019/12/17.
//  Copyright © 2019 sunfei_fish@sina.cn. All rights reserved.
//

#import "MMCameraViewController.h"
#import "MMCamera.h"
#import "MMDeviceMotionObserver.h"
#import "MMBeautyRender.h"
@import MetalPetal;
@import AVFoundation;

@interface MMCameraViewController () <AVCaptureVideoDataOutputSampleBufferDelegate, MMDeviceMotionHandling>

@property (nonatomic, strong) MMCamera *camera;
@property (nonatomic, strong) MTIImageView *previewView;

@property (nonatomic, strong) MMBeautyRender *render;

@end

@implementation MMCameraViewController

- (void)dealloc {
    [MMDeviceMotionObserver removeDeviceMotionHandler:self];
    [MMDeviceMotionObserver stopMotionObserve];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupViews];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.camera = [[MMCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 position:AVCaptureDevicePositionFront];
    dispatch_queue_t queue = dispatch_queue_create("com.mmbeautykit.demo", nil);
    [self.camera enableVideoDataOutputWithSampleBufferDelegate:self queue:queue];
    
    [MMDeviceMotionObserver startMotionObserve];
    [MMDeviceMotionObserver addDeviceMotionHandler:self];
    
    self.render = [[MMBeautyRender alloc] init];
    self.render.inputType = MMRenderInputTypeStream;
}

- (void)setupViews {
    self.previewView = [[MTIImageView alloc] initWithFrame:[UIScreen.mainScreen bounds]];
    [self.view addSubview:self.previewView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setTitle:@"flip" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(flipButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    [button.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-8].active = YES;
    [button.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:80].active = YES;
    
    UIView *ruddyView = [self createSliderWithTitle:@"红润" tag:100];
    ruddyView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *whitenView = [self createSliderWithTitle:@"美白" tag:101];
    whitenView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *smoothView = [self createSliderWithTitle:@"磨皮" tag:102];
    smoothView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *bigEyeView = [self createSliderWithTitle:@"大眼" tag:103];
    bigEyeView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *thinFaceView = [self createSliderWithTitle:@"瘦脸" tag:104];
    thinFaceView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIStackView *bgView = [[UIStackView alloc] initWithArrangedSubviews:@[ruddyView, whitenView, smoothView, bigEyeView, thinFaceView]];
    bgView.translatesAutoresizingMaskIntoConstraints = NO;
    bgView.axis = UILayoutConstraintAxisVertical;
    bgView.alignment = UIStackViewAlignmentCenter;
    bgView.distribution = UIStackViewDistributionFill;
    if (@available(iOS 11.0, *)) {
        bgView.spacing = UIStackViewSpacingUseSystem;
    } else {
        bgView.spacing = 8;
    }
    [self.view addSubview:bgView];
    
    [ruddyView.widthAnchor constraintEqualToAnchor:bgView.widthAnchor].active = YES;
    [whitenView.widthAnchor constraintEqualToAnchor:bgView.widthAnchor].active = YES;
    [smoothView.widthAnchor constraintEqualToAnchor:bgView.widthAnchor].active = YES;
    [bigEyeView.widthAnchor constraintEqualToAnchor:bgView.widthAnchor].active = YES;
    [thinFaceView.widthAnchor constraintEqualToAnchor:bgView.widthAnchor].active = YES;
    
    [bgView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-50].active = YES;
    [bgView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20].active = YES;
    [bgView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20].active = YES;
}

- (UIView *)createSliderWithTitle:(NSString *)title tag:(NSInteger)tag {
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = title;
    
    UISlider *slider = [[UISlider alloc] init];
    slider.translatesAutoresizingMaskIntoConstraints = NO;
    slider.continuous = YES;
    slider.minimumValue = 0;
    slider.maximumValue = 1;
    slider.tag = tag;
    [slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[label, slider]];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.distribution = UIStackViewDistributionFill;
    if (@available(iOS 11.0, *)) {
        stackView.spacing = UIStackViewSpacingUseSystem;
    } else {
        stackView.spacing = 8;
    }
    
    [label.widthAnchor constraintEqualToConstant:80].active = YES;
    
    return stackView;
}

- (void)valueChanged:(UISlider *)slider {
    switch (slider.tag) {
        case 100:
            // 红润
            [self.render setBeautyFactor:slider.value forKey:kBeautyFilterKeyRubby];
            break;
            
        case 101:
            // 美白
            [self.render setBeautyFactor:slider.value forKey:kBeautyFilterKeyWhitening];
            break;
            
        case 102:
            // 磨皮
            [self.render setBeautyFactor:slider.value forKey:kBeautyFilterKeySmooth];
            break;
            
        case 103:
            // 大眼
            [self.render setBeautyFactor:slider.value forKey:kBeautyFilterKeyBigEye];
            break;
            
        case 104:
            // 瘦脸
            [self.render setBeautyFactor:slider.value forKey:kBeautyFilterKeyThinFace];
            break;
            
        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.camera startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.camera stopRunning];
}

- (void)captureOutput:(AVCaptureOutput *)output
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (pixelBuffer) {
        
        NSError *error = nil;
        CVPixelBufferRef renderedPixelBuffer = [self.render renderPixelBuffer:pixelBuffer error:&error];
        if (!renderedPixelBuffer || error) {
            NSLog(@"error: %@", error);
        } else {
            MTIImage *image = [[MTIImage alloc] initWithCVPixelBuffer:renderedPixelBuffer alphaType:MTIAlphaTypeAlphaIsOne];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.previewView.image = image;
            });
        }
    }
}

- (void)flipButtonTapped:(UIButton *)button {
    [self.camera rotateCamera];
    self.render.devicePosition = self.camera.currentPosition;
}

#pragma mark - MMDeviceMotionHandling methods

- (void)handleDeviceMotionOrientation:(UIDeviceOrientation)orientation {
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            self.render.cameraRotate = MMRenderModuleCameraRotate90;
            break;
        case UIDeviceOrientationLandscapeLeft:
            self.render.cameraRotate = MMRenderModuleCameraRotate0;
            break;
        case UIDeviceOrientationLandscapeRight:
            self.render.cameraRotate = MMRenderModuleCameraRotate180;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            self.render.cameraRotate = MMRenderModuleCameraRotate270;
            break;
            
        default:
            break;
    }
}

@end
