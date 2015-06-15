//
//  ChangeReceiptNumberViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/30/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderTransaction.h"
#import "OrderHistory.h"

@protocol ChangeReceiptNumberDelegate <NSObject>

- (void)changeReceiptNumber:(NSString *)receiptNumber orderHistory:(OrderHistory *)history;

@end

@interface ChangeReceiptNumberViewController : UIViewController

@property (strong, nonatomic) OrderTransaction *order;
@property (weak, nonatomic) id<ChangeReceiptNumberDelegate> delegate;

@end
