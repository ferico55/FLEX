//
//  TransactionCCDetailViewController.h
//  Tokopedia
//
//  Created by Renny Runiawati on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransactionSummaryDetail.h"

@protocol TransactionCCDetailViewControllerDelegate <NSObject>

@required
- (void)doRequestCC:(NSDictionary*)param;
- (void)isSucessSprintAsia:(NSDictionary*)param;
- (void)addData:(NSDictionary*)dataInput;

@end

@interface TransactionCCDetailViewController : UIViewController

@property (nonatomic, weak) IBOutlet id<TransactionCCDetailViewControllerDelegate> delegate;
@property (strong, nonatomic) NSDictionary *data;
@property (nonatomic, strong) TransactionSummaryDetail *cartSummary;

@end
