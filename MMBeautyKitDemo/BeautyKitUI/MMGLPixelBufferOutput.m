//
//  MMGLPixelBufferOutput.m
//  MMBeautyKitDemo
//
//  Created by sunfei on 2020/9/2.
//  Copyright © 2020 sunfei. All rights reserved.
//

#import "MMGLPixelBufferOutput.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <GLKit/GLKit.h>

@interface MMGLPixelBufferOutput ()

@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic) CVPixelBufferPoolRef *pixelBufferPool;
@property (nonatomic) GLuint fbo;
//@property (nonatomic) 

@end

@implementation MMGLPixelBufferOutput

- (instancetype)initWithContext:(EAGLContext *)context {
    self = [super init];
    if (self) {
        if (!context) {
            _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
            if (!_context) {
                _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
            }
        } else {
            _context = context;
        }
        
        
    }
    return self;
}

@end
