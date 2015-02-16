//
//  TxOrderPaymentConfirmationSuccessViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#pragma mark - Transaction Cart Payment Delegate
@protocol SuccessPaymentConfirmationDelegate <NSObject>
@required
- (void)shouldPopViewController;

@end

@interface TxOrderPaymentConfirmationSuccessViewController : UIViewController

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= TKPD_MINIMUMIOSVERSION
@property (nonatomic, weak) IBOutlet id<SuccessPaymentConfirmationDelegate> delegate;
#else
@property (nonatomic, assign) IBOutlet id<SuccessPaymentConfirmationDelegate> delegate;
#endif

@property (nonatomic, strong) NSString *totalPaymentValue;
@property (nonatomic, strong) NSString *methodName;

@end
