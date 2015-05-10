//
//  NavigationBarBlurController.m
//  Tokopedia
//
//  Created by Harshad Dange on 08/05/2015.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "NavigationBarBlurController.h"
#import "UIImageEffects.h"

@implementation NavigationBarBlurController {
    CGPoint _contentOffset;
    UIImage *_initialImage;
}

// MARK: Initialisation

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _threshold = 0.5f;
        _maxOffset = 240.0f;
        _minimumOffset = 1.0f;
    }
    
    return self;
}

- (void)setContentOffset:(CGPoint)contentOffset {
    if (contentOffset.y < _maxOffset) {
        if (contentOffset.y < _minimumOffset) {
            [self.navigationBar setBackgroundImage:_initialImage forBarMetrics:UIBarMetricsDefault];
        } else {
            if (abs(_contentOffset.y - contentOffset.y) > self.threshold) {
                _contentOffset = contentOffset;
                __weak typeof(self) wself = self;
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    UIImage *blurredImage = [wself blurredImageForContentOffset:contentOffset];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (blurredImage != nil) {
                            [wself.navigationBar setBackgroundImage:blurredImage forBarMetrics:UIBarMetricsDefault];
                        }
                    });
                });
            }
        }
    }
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    _initialImage = [self croppedImageWithOffset:0];
    [self.navigationBar setBackgroundImage:_initialImage forBarMetrics:UIBarMetricsDefault];
}

// MARK: Private methods

- (UIImage *)blurredImageForContentOffset:(CGPoint)contentOffset {
    return [self imageWithBlurRadius:MAX((_contentOffset.y / _maxOffset) * 20, 5)];
}

- (UIImage *)croppedImageWithOffset:(CGFloat)contentOffset {
    UIGraphicsBeginImageContext(CGSizeMake(320, 64));
    [_backgroundImage drawInRect:CGRectMake(0, contentOffset, _backgroundImage.size.width, _backgroundImage.size.height)];
    UIImage *imageToBlur = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageToBlur;
}

- (UIImage *)imageWithBlurRadius:(CGFloat)blurRadius {
    UIImage *blurredImage = nil;
    if (self.backgroundImage != nil) {
        UIImage *imageToBlur;
        imageToBlur = [self croppedImageWithOffset:-MIN(_contentOffset.y, _backgroundImage.size.height - 64)];
        blurredImage = [UIImageEffects imageByApplyingBlurToImage:imageToBlur withRadius:blurRadius tintColor:nil saturationDeltaFactor:1.0 maskImage:nil];
    }
    return blurredImage;
}

@end
