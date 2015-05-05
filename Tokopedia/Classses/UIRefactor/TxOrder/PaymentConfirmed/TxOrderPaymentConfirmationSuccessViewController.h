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

- (void)shouldPopViewController;

@end

@interface TxOrderPaymentConfirmationSuccessViewController : UIViewController


@property (nonatomic, weak) IBOutlet id<SuccessPaymentConfirmationDelegate> delegate;

@property (nonatomic, strong) NSString *totalPaymentValue;
@property (nonatomic, strong) NSString *methodName;
@property (nonatomic, strong) NSString *confirmationPayment;

@end
