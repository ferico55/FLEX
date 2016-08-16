//
//  ProductEditImageViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProductEditImages;
@class DKAsset;

#pragma mark - Product Edit Image Delegate
@interface ProductEditImageViewController : UIViewController

@property (nonatomic, strong) ProductEditImages *imageObject;
- (void)setDefaultImageObject:(void (^)(ProductEditImages *imageObject))defaultImageObject;
- (void)setDeleteImageObject:(void (^)(ProductEditImages *imageObject))deleteImageObject;

@end
