//
//  TransactionCartWebViewViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransactionSummaryDetail.h"

@protocol TransactionCartWebViewViewControllerDelegate <NSObject>

@required
- (void)shouldDoRequestEMoney:(BOOL)isWSNew;
- (void)shouldDoRequestBCAClickPay;
- (void)refreshCartAfterCancelPayment;

@end

@interface TransactionCartWebViewViewController : UIViewController


@property (nonatomic, weak) IBOutlet id<TransactionCartWebViewViewControllerDelegate> delegate;


@property TransactionSummaryBCAParam *BCAParam;
@property NSNumber *gateway;
@property NSString *token;
@property NSString *URLStringMandiri;
@property NSString *emoney_code;
@property TransactionSummaryDetail *cartDetail;

@end

