//
//  FilterSalesTransactionListViewController.h
//  Tokopedia
//
//  Created by Feizal Badri Asmoro on 2/5/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterSalesTransactionListDelegate <NSObject>

- (void)filterOrderInvoice:(NSString *)invoice transactionStatus:(NSString *)transactionStatus startDate:(NSString *)startDate endDate:(NSString *)endDate;

@end

@interface FilterSalesTransactionListViewController : UITableViewController

@property (weak, nonatomic) id<FilterSalesTransactionListDelegate> delegate;

@property BOOL isOrderTransaction;

@property (strong, nonatomic) NSString *invoiceMark;
@property (strong, nonatomic) NSString *startDateMark;
@property (strong, nonatomic) NSString *endDateMark;
@property (strong, nonatomic) NSString *transactionStatusMark;

@end
