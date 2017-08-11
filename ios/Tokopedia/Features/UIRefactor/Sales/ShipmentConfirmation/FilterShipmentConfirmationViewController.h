//
//  FilterShipmentConfirmationViewController.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShipmentCourier.h"

@protocol FilterShipmentConfirmationDelegate <NSObject>

- (void)filterShipmentInvoice:(NSString *)invoice dueDate:(NSString *)dueDate courier:(ShipmentCourier *)courier;

@end

@interface FilterShipmentConfirmationViewController : UITableViewController

@property (weak, nonatomic) id<FilterShipmentConfirmationDelegate> delegate;
@property (strong, nonatomic) NSArray *couriers;

@end
