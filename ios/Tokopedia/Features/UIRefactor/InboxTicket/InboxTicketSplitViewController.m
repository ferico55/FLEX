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
#import "NavigateViewController.h"
#import "Tokopedia-Swift.h"

@interface InboxTicketSplitViewController () <UISplitViewControllerDelegate>

@property (strong, nonatomic) UISplitViewController *splitViewController;

@end

@implementation InboxTicketSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    TKPDTabViewController *controller = [TKPDTabViewController new];
    controller.hidesBottomBarWhenPushed = YES;
    controller.inboxType = InboxTypeTicket;
    
    InboxTicketViewController *allInbox = [InboxTicketViewController new];
    allInbox.inboxCustomerServiceType = InboxCustomerServiceTypeAll;
    allInbox.delegate = controller;
    allInbox.onTapContactUsButton = ^{
        [NavigateViewController navigateToContactUsFromViewController:self];
    };
    
    InboxTicketViewController *unreadInbox = [InboxTicketViewController new];
    unreadInbox.inboxCustomerServiceType = InboxCustomerServiceTypeInProcess;
    unreadInbox.delegate = controller;
    unreadInbox.onTapContactUsButton = ^{
        [NavigateViewController navigateToContactUsFromViewController:self];
    };
    
    InboxTicketViewController *closedInbox = [InboxTicketViewController new];
    closedInbox.inboxCustomerServiceType = InboxCustomerServiceTypeClosed;
    closedInbox.delegate = controller;
    closedInbox.onTapContactUsButton = ^{
        [NavigateViewController navigateToContactUsFromViewController:self];
    };
    
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
    self.splitViewController.delegate = self;
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
    
    [self.navigationController setWhite];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}

@end
