//
//  InboxReviewSplitViewController.m
//  Tokopedia
//
//  Created by Renny Runiawati on 7/1/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxReviewSplitViewController.h"

#import "InboxReviewViewController.h"
#import "TKPDTabInboxReviewNavigationController.h"
#import "DetailReviewViewController.h"
#import "ReviewFormViewController.h"

@interface InboxReviewSplitViewController ()

@property (strong, nonatomic) UISplitViewController *splitViewController;

@end

@implementation InboxReviewSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    InboxReviewViewController *vc = [InboxReviewViewController new];
    vc.data=@{@"nav":@"inbox-review"};
    
    InboxReviewViewController *vc1 = [InboxReviewViewController new];
    vc1.data=@{@"nav":@"inbox-review-my-product"};
    
    InboxReviewViewController *vc2 = [InboxReviewViewController new];
    vc2.data=@{@"nav":@"inbox-review-my-review"};
    
    NSArray *vcs = @[vc,vc1, vc2];
    
    TKPDTabInboxReviewNavigationController *masterVC = [TKPDTabInboxReviewNavigationController new];
    [masterVC setSelectedIndex:2];
    [masterVC setViewControllers:vcs];
    
    masterVC.splitVC = self;
    
    UINavigationController *masterNav = [[UINavigationController alloc]initWithRootViewController:masterVC];
    masterNav.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    masterNav.navigationBar.translucent = NO;
    masterNav.navigationBar.tintColor = [UIColor whiteColor];
    
    
    //Grab a reference to the LeftViewController and get the first monster in the list.
    DetailReviewViewController *detailVC = [DetailReviewViewController new];
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
    [self.splitViewController setValue:[NSNumber numberWithFloat:350.0] forKey:@"_masterColumnWidth"];
    
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
    // Dispose of any resources that can be recreated.
}


@end
