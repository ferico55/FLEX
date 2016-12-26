//
//  ChangeReceiptNumberViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangeReceiptNumberViewController : UIViewController

@property (strong, nonatomic) NSString *orderID;
@property (strong, nonatomic) NSString *receiptNumber;
@property (nonatomic, copy) void(^didSuccessEditReceipt)(NSString *receipt);

@end
