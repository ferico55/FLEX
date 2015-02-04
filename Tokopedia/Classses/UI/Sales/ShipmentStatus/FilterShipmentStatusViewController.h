//
//  FilterShipmentStatusViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterShipmentStatusDelegate <NSObject>

- (void)didFinishFilterInvoice:(NSString *)invoice transactionStatus:(NSString *)transactionStatus startDate:(NSString *)startDate endDate:(NSString *)endDate;

@end

@interface FilterShipmentStatusViewController : UIViewController

@property (weak, nonatomic) id<FilterShipmentStatusDelegate> delegate;

@end