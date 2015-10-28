//
//  InboxTicketSplitViewController.m
//  Tokopedia
//
//  Created by Samuel Edwin on 10/27/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxTicketSplitViewController.h"
#import "InboxTicketViewController.h"
#import "InboxTicketDetailViewController.h"

@interface InboxTicketSplitViewController ()

@property (strong, nonatomic) UISplitViewController *splitViewController;

@end

@implementation InboxTicketSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    TKPDTabViewController *controller = [TKPDTabViewController new];
    controller.hidesBottomBarWhenPushed = YES;
    
    InboxTicketViewController *allInbox = [InboxTicketViewController new];
    allInbox.inboxCustomerServiceType = InboxCustomerServiceTypeAll;
    allInbox.delegate = controller;
    
    InboxTicketViewController *unreadInbox = [InboxTicketViewController new];
    unreadInbox.inboxCustomerServiceType = InboxCustomerServiceTypeInProcess;
    unreadInbox.delegate = controller;
    
    InboxTicketViewController *closedInbox = [InboxTicketViewController new];
    closedInbox.inboxCustomerServiceType = InboxCustomerServiceTypeClosed;
    closedInbox.delegate = controller;
    
    controller.viewControllers = @[allInbox, unreadInbox, closedInbox];
    controller.tabTitles = @[@"Semua", @"Dalam Proses", @"Ditutup"];
    controller.menuTitles = @[@"Semua Layanan Pengguna", @"Belum Dibaca"];
    
    UINavigationController *masterNav = [[UINavigationController alloc]initWithRootViewController:controller];
    masterNav.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    masterNav.navigationBar.translucent = NO;
    masterNav.navigationBar.tintColor = [UIColor whiteColor];
    
    InboxTicketDetailViewController* detailVC = [InboxTicketDetailViewController new];
    allInbox.detailViewController = unreadInbox.detailViewController = closedInbox.detailViewController = detailVC;

    UINavigationController *detailNav = [[UINavigationController alloc]initWithRootViewController:detailVC];
    detailNav.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    detailNav.navigationBar.translucent = NO;
    detailNav.navigationBar.tintColor = [UIColor whiteColor];
    
    self.view.frame = [UIScreen mainScreen].bounds;
    
    self.splitViewController = [[UISplitViewController alloc] init];
    self.splitViewController.delegate = detailVC;
    self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNav, detailNav, nil];
    controller.splitVC = self;
    
    if ([self.splitViewController respondsToSelector:@selector(setPreferredDisplayMode:)]) {
        [self.splitViewController setPreferredDisplayMode:UISplitViewControllerDisplayModeAllVisible];
    }
    
    [self.view addSubview:self.splitViewController.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

@end
