//
//  SplitReputationViewController.m
//  Tokopedia
//
//  Created by Tokopedia on 8/10/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "SplitReputationViewController.h"
#import "SegmentedReviewReputationViewController.h"

@implementation SplitReputationViewController
@synthesize splitViewController;
- (void)viewDidLoad {
    if ([splitViewController respondsToSelector:@selector(setPreferredDisplayMode:)]) {
        [splitViewController setPreferredDisplayMode:UISplitViewControllerDisplayModeAllVisible];
    }
    
    SegmentedReviewReputationViewController *segmentedReputationViewController = [SegmentedReviewReputationViewController new];
    segmentedReputationViewController.hidesBottomBarWhenPushed = YES;
    segmentedReputationViewController.splitVC = self;

    //Set Navigation Master and Detail
    UINavigationController *masterVC = [[UINavigationController alloc] initWithRootViewController:segmentedReputationViewController];
    masterVC.navigationBar.translucent = NO;
    
    UINavigationController *detailVC = [[UINavigationController alloc] init];
    detailVC.navigationBar.translucent = NO;
    splitViewController.viewControllers = [NSArray arrayWithObjects:masterVC, detailVC, nil];
    [self.view addSubview:splitViewController.view];
    
    //Add Constraint
    UIView *splitView = splitViewController.view;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[splitView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(splitView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[splitView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(splitView)]];
}

- (void)dealloc {
    [_del deallocVC];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
@end
