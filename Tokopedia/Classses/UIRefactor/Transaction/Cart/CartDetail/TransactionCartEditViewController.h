//
//  TransactionCartEditViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/14/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TransactionCartPaymentViewController;

#pragma mark - Transaction Cart Payment Delegate
@protocol TransactionCartEditViewControllerDelegate <NSObject>
@required
- (void)shouldEditCartWithUserInfo:(NSDictionary*)userInfo;
- (void)popFromEditCart;

@end

@interface TransactionCartEditViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<TransactionCartEditViewControllerDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<TransactionCartEditViewControllerDelegate> delegate;
#endif


@property (nonatomic,strong) NSDictionary *data;

@end
