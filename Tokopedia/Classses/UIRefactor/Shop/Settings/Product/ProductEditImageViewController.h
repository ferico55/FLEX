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
-(void)ProductEditImageViewController:(ProductEditImageViewController*)viewController withUserInfo:(NSDictionary*)userInfo;
-(void)deleteProductImageAtIndex:(NSInteger)index;
-(void)updateProductImage:(UIImage*)image AtIndex:(NSInteger)index withUserInfo:(NSDictionary*)userInfo;
-(void)setDefaultImagePath:(NSString*)imagePath atIndex:(NSInteger)index;
-(void)setProductName:(NSString*)name atIndex:(NSInteger)index;
@end

@interface ProductEditImageViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<ProductEditImageViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<ProductEditImageViewControllerDelegate> delegate;
#endif

@property (nonatomic,strong) NSDictionary *data;

@end
