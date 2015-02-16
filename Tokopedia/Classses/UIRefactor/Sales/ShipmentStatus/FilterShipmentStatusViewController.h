//
//  FilterShipmentStatusViewController.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterShipmentStatusDelegate <NSObject>

- (void)filterShipmentStatusInvoice:(NSString *)invoice;

@end

@interface FilterShipmentStatusViewController : UITableViewController

@property (weak, nonatomic) id<FilterShipmentStatusDelegate> delegate;

@end
