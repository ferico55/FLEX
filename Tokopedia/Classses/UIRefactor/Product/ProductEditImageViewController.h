//
//  ProductEditImageViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProductEditImageViewController;

#pragma mark - Product Edit Image Delegate
@protocol ProductEditImageViewControllerDelegate <NSObject>
@required
-(void)deleteProductImageAtIndex:(NSInteger)index;
-(void)setDefaultImageAtIndex:(NSInteger)index;
-(void)setProductImageName:(NSString*)name atIndex:(NSInteger)index;

@optional
-(void)ProductEditImageViewController:(ProductEditImageViewController*)viewController withUserInfo:(NSDictionary*)userInfo;
-(void)updateProductImage:(UIImage*)image AtIndex:(NSInteger)index withUserInfo:(NSDictionary*)userInfo;

@end

@interface ProductEditImageViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<ProductEditImageViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<ProductEditImageViewControllerDelegate> delegate;
#endif

@property (nonatomic,strong) NSDictionary *data;
@property (nonatomic, strong) UIImage *uploadedImage;

@end
