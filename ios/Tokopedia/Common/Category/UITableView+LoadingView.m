//
//  UITableView+LoadingView.m
//  Tokopedia
//
//  Created by Tokopedia on 4/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "UITableView+LoadingView.h"

@implementation UITableView (LoadingView)

- (void)startIndicatorView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorView.center = view.center;
    [indicatorView startAnimating];
    [view addSubview:indicatorView];
    self.tableFooterView = view;
}

- (void)stopIndicatorView {
    self.tableFooterView = nil;
}

@end
