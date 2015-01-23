//
//  MyShopEtalaseFilterViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 10/13/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyShopEtalaseFilterViewController;

@protocol MyShopEtalaseFilterViewControllerDelegate <NSObject>
@required
-(void)MyShopEtalaseFilterViewController:(MyShopEtalaseFilterViewController*)viewController withUserInfo:(NSDictionary*)userInfo;

@end

@interface MyShopEtalaseFilterViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<MyShopEtalaseFilterViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<MyShopEtalaseFilterViewControllerDelegate> delegate;
#endif

@property (strong, nonatomic) NSDictionary* data;

@end
