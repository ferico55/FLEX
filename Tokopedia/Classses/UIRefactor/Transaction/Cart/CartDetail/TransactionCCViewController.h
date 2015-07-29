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

@protocol TransactionCCViewControllerDelegate <NSObject>

@required
- (void)doRequestCC:(NSDictionary*)param;
- (void)isSucessSprintAsia:(NSDictionary*)param;
@end

@interface TransactionCCViewController : UIViewController

@property (nonatomic, weak) IBOutlet id<TransactionCCViewControllerDelegate> delegate;


@property (nonatomic, strong) TransactionSummaryDetail *cartSummary;
@property (nonatomic, strong) CCData *ccData;

@end
