//
//  FilterShipmentConfirmationViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterShipmentConfirmationDelegate <NSObject>

- (void)didFilterShipmentConfirmationInvoice:(NSString *)invoice deadline:(NSString *)deadline;

@end

@interface FilterShipmentConfirmationViewController : UIViewController

@property (weak, nonatomic) id<FilterShipmentConfirmationDelegate> delegate;

@end
