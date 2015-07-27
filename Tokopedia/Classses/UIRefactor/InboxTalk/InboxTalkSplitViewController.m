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

@interface InboxTalkSplitViewController ()

@property (strong, nonatomic) UISplitViewController *splitViewController;

@end

@implementation InboxTalkSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    InboxTalkViewController *vc = [InboxTalkViewController new];
    vc.data=@{@"nav":@"inbox-talk"};
    
    InboxTalkViewController *vc1 = [InboxTalkViewController new];
    vc1.data=@{@"nav":@"inbox-talk-my-product"};
    
    InboxTalkViewController *vc2 = [InboxTalkViewController new];
    vc2.data=@{@"nav":@"inbox-talk-following"};
    
    NSArray *vcs = @[vc,vc1, vc2];
    
    TKPDTabInboxTalkNavigationController *masterVC = [TKPDTabInboxTalkNavigationController new];
    [masterVC setSelectedIndex:2];
    [masterVC setViewControllers:vcs];
    
    masterVC.splitVC = self;
    
    UINavigationController *masterNav = [[UINavigationController alloc]initWithRootViewController:masterVC];
    masterNav.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    masterNav.navigationBar.translucent = NO;
    masterNav.navigationBar.tintColor = [UIColor whiteColor];
    
    
    //Grab a reference to the LeftViewController and get the first monster in the list.
    ProductTalkDetailViewController *detailVC = [ProductTalkDetailViewController new];
    detailVC.masterViewController = masterVC;
    
    UINavigationController *detailNav = [[UINavigationController alloc]initWithRootViewController:detailVC];
    detailNav.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    detailNav.navigationBar.translucent = NO;
    detailNav.navigationBar.tintColor = [UIColor whiteColor];
    
    vc.detailViewController = detailVC;
    vc1.detailViewController = detailVC;
    vc2.detailViewController = detailVC;
    
    self.view.frame = [UIScreen mainScreen].bounds;
    
    self.splitViewController = [[UISplitViewController alloc] init];
    self.splitViewController.delegate = detailVC;
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
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
