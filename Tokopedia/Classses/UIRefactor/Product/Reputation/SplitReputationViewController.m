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
    [super viewDidLoad];
    if ([splitViewController respondsToSelector:@selector(setPreferredDisplayMode:)]) {
        [splitViewController setPreferredDisplayMode:UISplitViewControllerDisplayModeAllVisible];
    }
    
    TKPDSecureStorage *secureStorage = [TKPDSecureStorage standardKeyChains];
    NSDictionary *auth = [secureStorage keychainDictionary];
    auth = [auth mutableCopy];
    
    SegmentedReviewReputationViewController *segmentedReputationViewController = [SegmentedReviewReputationViewController new];
    segmentedReputationViewController.hidesBottomBarWhenPushed = YES;
    segmentedReputationViewController.splitVC = self;
    segmentedReputationViewController.userHasShop = ([auth objectForKey:@"shop_id"] && [[auth objectForKey:@"shop_id"] integerValue] > 0);

    //Set Navigation Master and Detail
    UINavigationController *masterVC = [[UINavigationController alloc] initWithRootViewController:segmentedReputationViewController];
    masterVC.navigationBar.translucent = NO;
    
    UINavigationController *detailVC = [[UINavigationController alloc] init];
    detailVC.navigationBar.translucent = NO;
    splitViewController.viewControllers = [NSArray arrayWithObjects:masterVC, detailVC, nil];
    splitViewController.delegate = self;
    [self.view addSubview:splitViewController.view];
    
    //Add Constraint
    UIView *splitView = splitViewController.view;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[splitView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(splitView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[splitView]-0-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(splitView)]];
}

- (void)dealloc {
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if(! _isFromNotificationView)
            [_del deallocVC];
    }
    else
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


#pragma mark - Method
- (UINavigationController *)getDetailNavigation {
    return [splitViewController.viewControllers lastObject];
}

- (UINavigationController *)getMasterNavigation {
    return [splitViewController.viewControllers firstObject];
}

- (void)setDetailViewController:(UIViewController *)viewController {
    UINavigationController *detailVC = [[UINavigationController alloc] initWithRootViewController:viewController];
    detailVC.navigationBar.translucent = NO;
    splitViewController.viewControllers = [NSArray arrayWithObjects:[splitViewController.viewControllers firstObject], detailVC, nil];
}

#pragma mark - SplitView Delegate
- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
        return NO;
}

@end
