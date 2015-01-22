//
//  ProductEditWholesaleViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 12/11/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ProductEditWholesaleViewController;

#pragma mark - Product Edit Wholesale Delegate
@protocol ProductEditWholesaleViewControllerDelegate <NSObject>
@optional
-(void)ProductEditWholesaleViewController:(ProductEditWholesaleViewController*)viewController withWholesaleList:(NSArray*)list;

@end

@interface ProductEditWholesaleViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<ProductEditWholesaleViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<ProductEditWholesaleViewControllerDelegate> delegate;
#endif

@property (nonatomic,strong) NSDictionary *data;

@end
