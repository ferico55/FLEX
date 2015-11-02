//
//  FilterNewOrderViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterDelegate <NSObject>

- (void)didFinishFilterInvoice:(NSString *)invoice dueDate:(NSString *)dueDate;

@end

@interface FilterNewOrderViewController : UITableViewController

@property (strong, nonatomic) NSString *dueDate;
@property (strong, nonatomic) NSString *filter;
@property (weak, nonatomic) id<FilterDelegate> delegate;

@end
