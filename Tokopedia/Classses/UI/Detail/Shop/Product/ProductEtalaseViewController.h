//
//  ProductEtalaseViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProductEtalaseViewController;

@protocol ProductEtalaseViewControllerDelegate <NSObject>
@required
-(void)ProductEtalaseViewController:(ProductEtalaseViewController*)viewController withUserInfo:(NSDictionary*)userInfo;

@end

@interface ProductEtalaseViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<ProductEtalaseViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<ProductEtalaseViewControllerDelegate> delegate;
#endif

@property (strong, nonatomic) NSDictionary* data;

@end
