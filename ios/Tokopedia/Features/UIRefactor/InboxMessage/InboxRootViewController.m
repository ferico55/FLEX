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
#import "Tokopedia-Swift.h"

@interface InboxRootViewController ()<UISplitViewControllerDelegate>

@property (strong, nonatomic) UISplitViewController *splitViewController;

@end

@implementation InboxRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

    UINavigationController *leftNav = [[UINavigationController alloc]initWithRootViewController:leftViewController];
    leftNav.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    leftNav.navigationBar.translucent = NO;
    leftNav.navigationBar.tintColor = [UIColor whiteColor];
    
    self.view.frame = [UIScreen mainScreen].bounds;
    
    self.splitViewController = [[UISplitViewController alloc] init];
    self.splitViewController.delegate = self;
    self.splitViewController.viewControllers = @[rightNav, leftNav];
    
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
    
    [self.navigationController setWhite];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

}


- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}

@end
