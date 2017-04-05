//
//  UITableView+RefreshControl.m
//  Tokopedia
//
//  Created by Tokopedia on 3/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "UITableView+RefreshControl.h"

@implementation UITableView (RefreshControl)

- (void)animateRefreshControl:(UIRefreshControl *)refreshControl {
    [refreshControl beginRefreshing];
    
    CGPoint contentOffset = self.contentOffset;
    contentOffset.y = (self.contentOffset.y != 0)?:-refreshControl.frame.size.height-45;
    [self setContentOffset:contentOffset animated:YES];
}

@end
