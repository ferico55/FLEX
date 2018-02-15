//
//  MoreWrapperViewController.m
//  Tokopedia
//
//  Created by Tonito Acen on 2/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "MoreWrapperViewController.h"
#import "MoreViewController.h"
#import "UIView+HVDLayout.h"
#import "Tokopedia-Swift.h"

@implementation MoreWrapperViewController {
    MoreViewController *_moreViewController;
    NotificationBarButton *_barButton;
    UserAuthentificationManager *_userManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
    [self.navigationItem setTitleView:logo];

    [self.view setBackgroundColor:[UIColor colorWithRed:(231/255.0) green:(231/255.0) blue:(231/255.0) alpha:1]];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MoreView" bundle: nil];
    UINavigationController *moreNavController = [storyboard instantiateViewControllerWithIdentifier:@"MoreNavigationViewController"];
    moreNavController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    _moreViewController = moreNavController.viewControllers[0];
    _moreViewController.wrapperViewController = self;
    
    [self addChildViewController:_moreViewController];
    [self.view addSubview:_moreViewController.tableView];
    
    if(IS_IPAD) {
        [_moreViewController.tableView HVD_fillInSuperViewWithInsets:UIEdgeInsetsMake(20, 70, 0, 70)];
    }
    
    _barButton = [[NotificationBarButton alloc] initWithParentViewController:self];
    
    _userManager = [UserAuthentificationManager new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self initNotificationManager];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_moreViewController) {
        [_moreViewController showTooltipView];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_moreViewController) {
            [_moreViewController updateSaldoTokopedia];
        }
    });
}

- (void)initNotificationManager {
    if ([_userManager isLogin]) {
        self.navigationItem.rightBarButtonItem = _barButton;
        [_barButton reloadNotifications];
    }
    else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

@end
