//
//  DueDateViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 1/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DueDateDelegate <NSObject>

- (void)didSelectDueDate:(NSString *)dueDate;

@end

@interface DueDateViewController : UITableViewController

@property (weak, nonatomic) id<DueDateDelegate> delegate;
@property (weak, nonatomic) NSString *dueDate;

@end
