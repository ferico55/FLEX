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

@class InstallmentBank;
@class InstallmentTerm;

@protocol TransactionCCViewControllerDelegate <NSObject>

@required
- (void)doRequestCC:(NSDictionary*)param;
- (void)isSucessSprintAsia:(NSDictionary*)param;
- (void)addData:(NSDictionary*)dataInput;

@end

@interface TransactionCCViewController : UIViewController

@property (nonatomic, weak) IBOutlet id<TransactionCCViewControllerDelegate> delegate;


@property (nonatomic, strong) TransactionSummaryDetail *cartSummary;
@property (nonatomic, strong) CCData *ccData;
@property (nonatomic, strong) InstallmentBank *selectedBank;
@property (nonatomic, strong) InstallmentTerm *selectedTerm;
@property NSDictionary *data;

@end
