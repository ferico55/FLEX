//
//  MyShopEtalaseEditViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyShopEtalaseEditViewController;

#pragma mark - Product Edit Wholesale Cell Delegate
@protocol MyShopEtalaseEditViewControllerDelegate <NSObject>

@optional
- (void)successEditEtalase:(NSString *)etalaseName;
- (void)MyShopEtalaseEditViewController:(MyShopEtalaseEditViewController*)viewController
                             withUserInfo:(NSDictionary*)userInfo;

@end

@interface MyShopEtalaseEditViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<MyShopEtalaseEditViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<MyShopEtalaseEditViewControllerDelegate> delegate;
#endif

@property (nonatomic,strong)NSDictionary *data;

@end
