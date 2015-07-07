//
//  TransactionCCViewController.h
//  Tokopedia
//
//  Created by Renny Runiawati on 7/6/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransactionSummaryDetail.h"
#import "CCData.h"

@interface TransactionCCViewController : UIViewController

@property (nonatomic, strong) TransactionSummaryDetail *cartSummary;
@property (nonatomic, strong) CCData *ccData;

@end
