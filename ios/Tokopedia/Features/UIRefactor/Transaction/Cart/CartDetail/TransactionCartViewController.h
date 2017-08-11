//
//  TransactionCartViewController.h
//  Tokopedia
//
//  Created by IT Tkpd on 1/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TransactionCartViewController;

@interface TransactionCartViewController : GAITrackedViewController

@property (strong,nonatomic,setter=setData:) NSDictionary *data;

@end
