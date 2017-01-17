//
//  InboxResolSplitViewController.m
//  Tokopedia
//
//  Created by Renny Runiawati on 7/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxResolSplitViewController.h"

#import "InboxResolutionCenterTabViewController.h"
#import "ResolutionCenterDetailViewController.h"

@interface InboxResolSplitViewController ()

@property (strong, nonatomic) UISplitViewController *splitViewController;

@end

@implementation InboxResolSplitViewController{
    int _tapIndex;
}

-(instancetype)initWithSelectedIndex:(int)index{
    self = [super init];
    if(self){
        _tapIndex = index;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    InboxResolutionCenterTabViewController *masterVC = [[InboxResolutionCenterTabViewController alloc] initWithSelectedIndex:_tapIndex];
    masterVC.splitVC = self;
    
    UINavigationController *masterNav = [[UINavigationController alloc]initWithRootViewController:masterVC];
    masterNav.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    masterNav.navigationBar.translucent = NO;
    masterNav.navigationBar.tintColor = [UIColor whiteColor];
    
    
    //Grab a reference to the LeftViewController and get the first monster in the list.
    ResolutionCenterDetailViewController *detailVC = [ResolutionCenterDetailViewController new];
    detailVC.masterViewController = masterVC;
    
    UINavigationController *detailNav = [[UINavigationController alloc]initWithRootViewController:detailVC];
    detailNav.navigationBar.backgroundColor = [UIColor colorWithCGColor:[UIColor colorWithRed:18.0/255.0 green:199.0/255.0 blue:0.0/255.0 alpha:1].CGColor];
    detailNav.navigationBar.translucent = NO;
    detailNav.navigationBar.tintColor = [UIColor whiteColor];
    
    masterVC.detailViewController = detailVC;
    
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
    // Dispose of any resources that can be recreated.
}

@end
