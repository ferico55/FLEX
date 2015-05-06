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
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self.contentView setBackgroundColor:[UIColor whiteColor]];
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
    [_previewLayer removeFromSuperlayer];
    [_captureSession stopRunning];
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
    
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    [previewLayer setFrame:self.contentView.layer.bounds];
    [self.contentView.layer addSublayer:previewLayer];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    _previewLayer = previewLayer;
    
    _captureSession = captureSession;
    [self bringSubviewToFront:_icon];
}

- (void)startLiveVideo {
    [_captureSession startRunning];
}

- (void)restartCaptureSession {
    [self configureCaptureSession];
}

- (void)stopLiveVideo {
    if (![_captureSession isRunning]) {
        [_captureSession stopRunning];
    }
}

- (void)freezeCapturedContent {
    UIGraphicsBeginImageContext(_previewLayer.bounds.size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    [self.contentView.layer renderInContext:currentContext];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    [_captureSession stopRunning];
    _captureSession = nil;
    [_previewLayer removeFromSuperlayer];
    [self.contentView.layer setContents:(id)image.CGImage];
}

- (void)captureSessionDidFailToStart:(NSNotification *)notification {
    NSLog(@"%@", notification.userInfo);
}


@end
