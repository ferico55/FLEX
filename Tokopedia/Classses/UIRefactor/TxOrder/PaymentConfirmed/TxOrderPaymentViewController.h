//
//  TxOrderPaymentViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TxOrderPaymentViewControllerDelegate <NSObject>
- (void)shouldPopViewController;
- (void)successConfirmPayment:(NSArray*)payment;
- (void)refreshRequest;
- (void)failedOrCancelConfirmPayment:(NSArray*)payment;

@end

@interface TxOrderPaymentViewController : UIViewController

@property (nonatomic, weak) IBOutlet id<TxOrderPaymentViewControllerDelegate> delegate;


@property (nonatomic, strong) NSDictionary *data;
@property BOOL isConfirmed;
@property (nonatomic, strong) NSArray *paymentID;

@end
