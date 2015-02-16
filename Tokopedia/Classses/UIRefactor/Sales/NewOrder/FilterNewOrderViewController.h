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

@property (weak, nonatomic) id<FilterDelegate> delegate;

@end
