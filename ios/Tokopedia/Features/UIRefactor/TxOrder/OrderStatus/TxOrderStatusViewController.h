//
//  TxOrderStatusViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/17/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TxOrderStatusViewController : GAITrackedViewController

@property (nonatomic, strong) NSString *action;
@property (nonatomic, strong) NSString *viewControllerTitle;
@property BOOL isCanceledPayment;

@end
