//
//  TKPDLiveCameraTableViewCell.m
//  Tokopedia
//
//  Created by Harshad Dange on 06/05/2015.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "TKPDLiveCameraTableViewCell.h"
@import AVFoundation;

@implementation TKPDLiveCameraTableViewCell {
    AVCaptureSession *_captureSession;
    AVCaptureVideoPreviewLayer *_previewLayer;
    UIImageView *_icon;
    dispatch_queue_t _captureSessionQueue;
    AVCaptureDeviceInput *_cameraInput;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        _captureSessionQueue = dispatch_queue_create("com.tokopedia.captureSessionQueue", DISPATCH_QUEUE_SERIAL);
        [self configureCaptureSession];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"icon_camera_album.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [imageView setTintColor:[UIColor whiteColor]];
        [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:imageView];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        _icon = imageView;
    }
    
    return self;
}

- (void)configureCaptureSession {
    __weak typeof(self) wself = self;
    [_previewLayer removeFromSuperlayer];
    dispatch_async(_captureSessionQueue, ^{
        if (wself != nil) {
            typeof(self) sself = wself;
            [sself->_captureSession stopRunning];
            NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
            if ([devices count] == 0) {
                return;
            }
            AVCaptureDevice *backCamera = nil;
            for (AVCaptureDevice *device in devices) {
                if (device.position == AVCaptureDevicePositionBack) {
                    backCamera = device;
                    break;
                }
            }
            if (backCamera == nil) {
                backCamera = [devices firstObject];
            }
            NSError *error = nil;
            AVCaptureDeviceInput *cameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:backCamera error:nil];
            sself->_cameraInput = cameraInput;
            if (error != nil) {
                return;
            }
            AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
            if ([captureSession canAddInput:cameraInput]) {
                [captureSession addInput:cameraInput];
            } else {
                return;
            }
            
            [captureSession setSessionPreset:AVCaptureSessionPreset352x288];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
                [previewLayer setFrame:wself.contentView.layer.bounds];
                [wself.contentView.layer insertSublayer:previewLayer atIndex:0];
                [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
                
                sself->_previewLayer = previewLayer;
                
                sself->_captureSession = captureSession;
                
                [wself startLiveVideo];
            });
        }
    });
}

- (void)startLiveVideo {
    __weak typeof(self) wself = self;
    dispatch_async(_captureSessionQueue, ^{
        if (wself != nil) {
            typeof(self) sself = wself;
            if (![sself->_captureSession isRunning]) {
                [sself->_captureSession startRunning];
            }
        }
    });
}

- (void)restartCaptureSession {
    __weak typeof(self) wself = self;
    dispatch_async(_captureSessionQueue, ^{
        if (wself != nil) {
            typeof(self) sself = wself;
            if ([sself->_captureSession canAddInput:sself->_cameraInput]) {
                [sself->_captureSession addInput:sself->_cameraInput];
                [sself->_captureSession startRunning];
            }
        }
    });
}

- (void)stopLiveVideo {
    if (![_captureSession isRunning]) {
        __weak typeof(self) wself = self;
        dispatch_async(_captureSessionQueue, ^{
            if (wself != nil) {
                typeof(self) sself = wself;
                [sself->_captureSession stopRunning];
            }
        });
    }
}

- (void)freezeCapturedContent {
    __weak typeof(self) wself = self;
    dispatch_async(_captureSessionQueue, ^{
        if (wself != nil) {
            typeof(self) sself = wself;
            [sself->_captureSession stopRunning];
            [sself->_captureSession removeInput:sself->_cameraInput];
        }
    });
}


@end
