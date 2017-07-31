//
//  InboxTalkSplitViewController.m
//  Tokopedia
//
//  Created by Renny Runiawati on 7/1/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxTalkSplitViewController.h"

#import "TKPDTabInboxTalkNavigationController.h"
#import "InboxTalkViewController.h"
#import "ProductTalkDetailViewController.h"
#import "Tokopedia-Swift.h"

@interface InboxTalkSplitViewController () <UISplitViewControllerDelegate>

@property (strong, nonatomic) UISplitViewController *splitViewController;

@end

@implementation InboxTalkSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    TKPDTabViewController *controller = [TKPDTabViewController new];
    controller.hidesBottomBarWhenPushed = YES;
    controller.splitVC = self;
    controller.inboxType = InboxTypeTalk;
    
    InboxTalkViewController *allTalk = [InboxTalkViewController new];
    allTalk.inboxTalkType = InboxTalkTypeAll;
    allTalk.delegate = controller;
    
    InboxTalkViewController *myProductTalk = [InboxTalkViewController new];
    myProductTalk.inboxTalkType = InboxTalkTypeMyProduct;
    myProductTalk.delegate = controller;
    
    InboxTalkViewController *followingTalk = [InboxTalkViewController new];
    followingTalk.inboxTalkType = InboxTalkTypeFollowing;
    followingTalk.delegate = controller;
    
    controller.viewControllers = @[allTalk, myProductTalk, followingTalk];
    controller.tabTitles = @[@"Semua", @"Produk Saya", @"Ikuti"];
    controller.menuTitles = @[@"Semua Diskusi", @"Belum Dibaca"];
    
    UINavigationController *masterNav = [[UINavigationController alloc]initWithRootViewController:controller];
    masterNav.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    masterNav.navigationBar.translucent = NO;
    masterNav.navigationBar.tintColor = [UIColor whiteColor];
    
    
    //Grab a reference to the LeftViewController and get the first monster in the list.
    ProductTalkDetailViewController *detailVC = [[ProductTalkDetailViewController alloc] initByMarkingOpenedTalkAsRead:YES];

    UINavigationController *detailNav = [[UINavigationController alloc]initWithRootViewController:detailVC];
    detailNav.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    detailNav.navigationBar.translucent = NO;
    detailNav.navigationBar.tintColor = [UIColor whiteColor];

    allTalk.detailViewController = detailVC;
    followingTalk.detailViewController = detailVC;
    myProductTalk.detailViewController = detailVC;

    self.view.frame = [UIScreen mainScreen].bounds;
    
    self.splitViewController = [[UISplitViewController alloc] init];
    self.splitViewController.delegate = self;
    self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNav, detailNav, nil];
    
    if ([self.splitViewController respondsToSelector:@selector(setPreferredDisplayMode:)]) {
        [self.splitViewController setPreferredDisplayMode:UISplitViewControllerDisplayModeAllVisible];
    }
    
    [self.view addSubview:self.splitViewController.view];

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
    [self.navigationController setWhite];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}

@end
