//
//  MMPhotoEditViewController.m
//  MMBeautyKit_Example
//
//  Created by sunfei on 2019/12/19.
//  Copyright © 2019 sunfei_fish@sina.cn. All rights reserved.
//

#import "MMPhotoEditViewController.h"
#import "MMBeautyRender.h"
@import MetalPetal;

@interface MMPhotoEditViewController ()

@property (nonatomic, strong) MTIImageView *imageView;
@property (nonatomic, strong) MMBeautyRender *render;

@property (nonatomic, strong) dispatch_queue_t workingQueue;

@end

@implementation MMPhotoEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.workingQueue = dispatch_queue_create("com.beautykit.demo.render", NULL);
    
    self.render = [[MMBeautyRender alloc] init];
    self.render.inputType = MMRenderInputTypeStatic;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    MTIImageView *imageView = [[MTIImageView alloc] init];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:imageView];
    self.imageView = imageView;
    
    MTIImage *image = [[MTIImage alloc] initWithCVPixelBuffer:[self pixelBufferForCGImage:self.photo.CGImage] alphaType:MTIAlphaTypeAlphaIsOne];
    imageView.image = image;
    
    [imageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [imageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [imageView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [imageView.heightAnchor constraintEqualToAnchor:imageView.widthAnchor multiplier:16.0 / 9.0].active = YES;
    
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
    dispatch_async(self.workingQueue, ^{
        @autoreleasepool {
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
            
            CVPixelBufferRef pixelBuffer = [self pixelBufferForCGImage:self.photo.CGImage];
            if (pixelBuffer) {
                CVPixelBufferRef retainedPixelBuffer = CVPixelBufferRetain(pixelBuffer);
                CVPixelBufferRef result = [self.render renderPixelBuffer:retainedPixelBuffer error:nil];
                CVPixelBufferRelease(retainedPixelBuffer);
                result = CVPixelBufferRetain(result);
                dispatch_async(dispatch_get_main_queue(), ^{
                    MTIImage *image = [[MTIImage alloc] initWithCVPixelBuffer:result alphaType:MTIAlphaTypeAlphaIsOne];
                    self.imageView.image = image;
                    CVPixelBufferRelease(result);
                });
            }
        }
    });
}

- (CVPixelBufferRef)pixelBufferForCGImage:(CGImageRef)cgImage {
    CVPixelBufferRef pixelBuffer;
    CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(cgImage), CGImageGetHeight(cgImage), kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)@{(id)kCVPixelBufferIOSurfacePropertiesKey: @{}}, &pixelBuffer);
    if (!pixelBuffer) {
        return NULL;
    }
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    if (!colorspace) {
        return NULL;
    }
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    CGContextRef context = CGBitmapContextCreate(CVPixelBufferGetBaseAddress(pixelBuffer), CGImageGetWidth(cgImage), CGImageGetHeight(cgImage), 8, CVPixelBufferGetBytesPerRow(pixelBuffer), colorspace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorspace);
    if (!context) {
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        return NULL;
    }
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(cgImage), CGImageGetHeight(cgImage)), cgImage);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    if (pixelBuffer) {
        return (CVPixelBufferRef)CFAutorelease(pixelBuffer);
    } else {
        return NULL;
    }
}

@end
