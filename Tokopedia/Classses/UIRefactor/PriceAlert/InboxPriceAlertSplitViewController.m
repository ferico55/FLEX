//
//  InboxPriceAlertSplitViewController.m
//  Tokopedia
//
//  Created by Tonito Acen on 8/24/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxPriceAlertSplitViewController.h"
#import "AlertPriceNotificationViewController.h"
#import "DetailPriceAlertViewController.h"

@interface InboxPriceAlertSplitViewController ()

@property (strong, nonatomic) UISplitViewController *splitViewController;

@end

@implementation InboxPriceAlertSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AlertPriceNotificationViewController *alertPriceNotificationViewController = [AlertPriceNotificationViewController new];
    alertPriceNotificationViewController.hidesBottomBarWhenPushed = YES;
    alertPriceNotificationViewController.splitVC = self;
    
    
    UINavigationController *masterNav = [[UINavigationController alloc]initWithRootViewController:alertPriceNotificationViewController];
    masterNav.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    masterNav.navigationBar.translucent = NO;
    masterNav.navigationBar.tintColor = [UIColor whiteColor];
    
    
    //Grab a reference to the LeftViewController and get the first monster in the list.
    DetailPriceAlertViewController *detailPriceAlertViewController = [DetailPriceAlertViewController new];
    detailPriceAlertViewController.hidesBottomBarWhenPushed = YES;
    detailPriceAlertViewController.masterVC = alertPriceNotificationViewController;
    
    
    UINavigationController *detailNav = [[UINavigationController alloc]initWithRootViewController:detailPriceAlertViewController];
    detailNav.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    detailNav.navigationBar.translucent = NO;
    detailNav.navigationBar.tintColor = [UIColor whiteColor];
    
    alertPriceNotificationViewController.detailViewController = detailPriceAlertViewController;
    self.view.frame = [UIScreen mainScreen].bounds;
    
    self.splitViewController = [[UISplitViewController alloc] init];
    self.splitViewController.delegate = detailPriceAlertViewController;
    self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNav, detailNav, nil];
    
    if ([self.splitViewController respondsToSelector:@selector(setPreferredDisplayMode:)]) {
        [self.splitViewController setPreferredDisplayMode:UISplitViewControllerDisplayModeAllVisible];
    }
    
    [self.view addSubview:self.splitViewController.view];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
