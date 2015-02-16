//
//  TrackOrderViewController.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/4/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderTransaction.h"

@interface TrackOrderViewController : UIViewController

@property (strong, nonatomic) OrderTransaction *order;

@end