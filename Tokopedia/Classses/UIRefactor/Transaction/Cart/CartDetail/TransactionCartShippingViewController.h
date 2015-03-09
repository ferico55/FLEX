//
//  TransactionCartShippingViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TransactionCartShippingViewController;

#pragma mark - Transaction Cart Shipment Delegate
@protocol TransactionCartShippingViewControllerDelegate <NSObject>
@required
- (void)TransactionCartShippingViewController:(TransactionCartShippingViewController*)viewController withUserInfo:(NSDictionary*)userInfo;

@end

@interface TransactionCartShippingViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<TransactionCartShippingViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<TransactionCartShippingViewControllerDelegate> delegate;
#endif

@property (nonatomic) NSInteger indexPage;
@property (strong,nonatomic)NSDictionary *data;

@end
