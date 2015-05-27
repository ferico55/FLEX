//
//  DepartmentTableViewController.h
//  Tokopedia
//
//  Created by Tokopedia on 5/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DepartmentListDelegate
- (void)didFinishSelectedAtRow:(int)row;
- (void)didCancel;
@end



@interface DepartmentTableViewController : UITableViewController
@property (nonatomic) int tag;
@property (nonatomic, unsafe_unretained) id<DepartmentListDelegate> del;
@property (nonatomic, strong) NSArray *arrList;
@property (nonatomic) int selectedIndex;
@end
