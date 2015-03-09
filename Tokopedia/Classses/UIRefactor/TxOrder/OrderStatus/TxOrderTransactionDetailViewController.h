//
//  TxOrderTransactionDetailViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 2/18/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TxOrderStatusList.h"

@interface TxOrderTransactionDetailViewController : UIViewController

@property (nonatomic , strong) TxOrderStatusList *order;

@end
