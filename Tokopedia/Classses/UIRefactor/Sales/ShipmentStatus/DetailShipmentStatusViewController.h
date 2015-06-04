//
//  DetailShipmentStatusViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderTransaction.h"
@class LabelMenu;

@interface DetailShipmentStatusViewController : UIViewController
{
    IBOutlet LabelMenu *labelReceiptNumber;
}

@property (strong, nonatomic) OrderTransaction *order;
@property (strong, nonatomic) NSString *is_allow_manage_tx;

@end
