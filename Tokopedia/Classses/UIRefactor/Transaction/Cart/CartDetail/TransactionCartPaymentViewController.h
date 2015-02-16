//
//  TransactionCartPaymentViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TransactionCartPaymentViewController;

#pragma mark - Transaction Cart Payment Delegate
@protocol TransactionCartPaymentViewControllerDelegate <NSObject>
@required
- (void)TransactionCartPaymentViewController:(TransactionCartPaymentViewController*)viewController withUserInfo:(NSDictionary*)userInfo;

@end

@interface TransactionCartPaymentViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<TransactionCartPaymentViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<TransactionCartPaymentViewControllerDelegate> delegate;
#endif

@property (nonatomic, strong)NSDictionary *data;

@end
