//
//  SubmitShipmentConfirmationViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/29/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SubmitShipmentConfirmationDelegate <NSObject>

- (void)didFinishConfirmation;

@end

@interface SubmitShipmentConfirmationViewController : UIViewController

@property (weak, nonatomic) id<SubmitShipmentConfirmationDelegate> delegate;

@end
