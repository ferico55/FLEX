//
//  InboxResolSplitViewController.m
//  Tokopedia
//
//  Created by Renny Runiawati on 7/2/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "InboxResolSplitViewController.h"

#import "InboxResolutionCenterTabViewController.h"
#import "Tokopedia-Swift.h"

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
    UINavigationController *masterNav = [[UINavigationController alloc]initWithRootViewController:masterVC];
    masterVC.splitVC = self;
    
    ResolutionWebViewController *detailVC = [ResolutionWebViewController new];
    UINavigationController *detailNav = [[UINavigationController alloc]initWithRootViewController:detailVC];
    
    masterVC.detailViewController = detailVC;
    
    self.view.frame = [UIScreen mainScreen].bounds;
    
    self.splitViewController = [[UISplitViewController alloc] init];
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

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setWhite];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
