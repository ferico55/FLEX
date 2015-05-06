//
//  CancelShipmentViewController.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/1/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CancelShipmentConfirmationDelegate <NSObject>

- (void)cancelShipmentWithExplanation:(NSString *)explanation;

@end

@interface CancelShipmentViewController : UIViewController

@property (weak, nonatomic) id<CancelShipmentConfirmationDelegate> delegate;

@end
