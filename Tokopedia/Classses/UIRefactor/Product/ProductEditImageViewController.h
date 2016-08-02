//
//  ProductEditImageViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/9/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProductEditImageViewController;
@class DKAsset;

#pragma mark - Product Edit Image Delegate
@protocol ProductEditImageViewControllerDelegate <NSObject>
@required
-(void)deleteProductImageAtIndex:(NSInteger)index isDefaultImage:(BOOL)isDefaultImage;
-(void)setDefaultImageAtIndex:(NSInteger)index;
-(void)setDefaultImage:(DKAsset*)defaultImage;
-(void)deleteImage:(DKAsset*)image;
-(void)setProductImageName:(NSString*)name atIndex:(NSInteger)index;

@optional
-(void)ProductEditImageViewController:(ProductEditImageViewController*)viewController withUserInfo:(NSDictionary*)userInfo;
-(void)updateProductImage:(UIImage*)image AtIndex:(NSInteger)index withUserInfo:(NSDictionary*)userInfo;

@end

@interface ProductEditImageViewController : UIViewController


@property (nonatomic, weak) IBOutlet id<ProductEditImageViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintVerticalScrollview;

@property (nonatomic,strong) NSDictionary *data;
@property (nonatomic, strong) UIImage *uploadedImage;
@property (nonatomic, strong) DKAsset *selectedImage;
@property (nonatomic) BOOL isDefaultFromWS;
@property (nonatomic) NSInteger type;
@property (weak, nonatomic) IBOutlet UIView *setDefaultView;

@end
