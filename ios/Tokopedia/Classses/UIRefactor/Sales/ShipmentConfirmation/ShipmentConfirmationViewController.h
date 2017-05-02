//
//  ShipmentConfirmationViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/19/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShipmentConfirmationDelegate <NSObject>

- (void)viewController:(UIViewController *)viewController numberOfProcessedOrder:(NSInteger)totalOrder;

@end

@interface ShipmentConfirmationViewController : UIViewController

@property (weak, nonatomic) id<ShipmentConfirmationDelegate> delegate;

@end
