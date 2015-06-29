//
//  InboxRootViewController.m
//  Tokopedia
//
//  Created by Renny Runiawati on 6/26/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxRootViewController.h"

#import "TKPDTabInboxMessageNavigationController.H"
#import "InboxMessageViewController.h"
#import "InboxMessageDetailViewController.h"

@interface InboxRootViewController ()<UISplitViewControllerDelegate>

@end

@implementation InboxRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Grab a reference to the RightViewController and set it as the SVC's delegate.
    InboxMessageViewController *vc = [InboxMessageViewController new];
    vc.data=@{@"nav":@"inbox-message"};
    
    InboxMessageViewController *vc1 = [InboxMessageViewController new];
    vc1.data=@{@"nav":@"inbox-message-sent"};
    
    InboxMessageViewController *vc2 = [InboxMessageViewController new];
    vc2.data=@{@"nav":@"inbox-message-archive"};
    
    InboxMessageViewController *vc3 = [InboxMessageViewController new];
    vc3.data=@{@"nav":@"inbox-message-trash"};
    NSArray *vcs = @[vc,vc1, vc2, vc3];
    
    TKPDTabInboxMessageNavigationController *inboxController = [TKPDTabInboxMessageNavigationController new];
    [inboxController setSelectedIndex:2];
    [inboxController setViewControllers:vcs];
    
    inboxController.splitVC = self;
    
    UINavigationController *rightNav = [[UINavigationController alloc]initWithRootViewController:inboxController];
    rightNav.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    rightNav.navigationBar.translucent = NO;
    rightNav.navigationBar.tintColor = [UIColor whiteColor];


    //Grab a reference to the LeftViewController and get the first monster in the list.
    InboxMessageDetailViewController *leftViewController = [InboxMessageDetailViewController new];
    leftViewController.masterViewController = inboxController;

    UINavigationController *leftNav = [[UINavigationController alloc]initWithRootViewController:leftViewController];
    leftNav.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    leftNav.navigationBar.translucent = NO;
    leftNav.navigationBar.tintColor = [UIColor whiteColor];
        vc.detailViewController = leftViewController;
    vc1.detailViewController = leftViewController;
    vc2.detailViewController = leftViewController;
    
    self.view.frame = [UIScreen mainScreen].bounds;
    
    self.splitViewController = [[UISplitViewController alloc] init];
//    self.splitViewController.delegate = leftViewController;
    self.splitViewController.viewControllers = [NSArray arrayWithObjects:rightNav, leftNav, nil];
    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;

    [self.view addSubview:self.splitViewController.view];
}

-(IBAction)tapBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
