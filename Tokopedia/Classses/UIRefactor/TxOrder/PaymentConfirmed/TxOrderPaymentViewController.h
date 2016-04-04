//
//  TxOrderPaymentViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TxOrderPaymentViewController : UIViewController

@property BOOL isConfirmed;
@property (nonatomic, strong) NSArray *paymentID;

@end
