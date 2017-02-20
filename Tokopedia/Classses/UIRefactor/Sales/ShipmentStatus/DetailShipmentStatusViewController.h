//
//  DetailShipmentStatusViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderTransaction.h"
#import "OrderHistory.h"

@protocol DetailShipmentStatusDelegate <NSObject>

- (void)successChangeReceiptWithOrderHistory:(OrderHistory *)history;

@end

@class LabelMenu;

@interface DetailShipmentStatusViewController : UIViewController
{
    IBOutlet LabelMenu *labelReceiptNumber;
}

@property (strong, nonatomic) OrderTransaction *order;
@property (strong, nonatomic) NSString *is_allow_manage_tx;
@property (weak, nonatomic) id<DetailShipmentStatusDelegate> delegate;
@property (copy) void(^onSuccessRetry)(BOOL isSuccess);

@end
