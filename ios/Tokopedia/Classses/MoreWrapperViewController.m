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

@implementation MoreWrapperViewController {
    MoreViewController *_moreViewController;
    NotificationManager *_notifManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kTKPDIMAGE_TITLEHOMEIMAGE]];
    [self.navigationItem setTitleView:logo];

    [self.view setBackgroundColor:[UIColor colorWithRed:(231/255.0) green:(231/255.0) blue:(231/255.0) alpha:1]];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    UINavigationController *moreNavController = [storyboard instantiateViewControllerWithIdentifier:@"MoreNavigationViewController"];
    moreNavController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    _moreViewController = moreNavController.viewControllers[0];
    _moreViewController.wrapperViewController = self;
    
    [self.view addSubview:_moreViewController.tableView];
    
    if(IS_IPAD) {
        [_moreViewController.tableView HVD_fillInSuperViewWithInsets:UIEdgeInsetsMake(20, 70, 0, 70)];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initNotificationManager];
    if (_moreViewController) {
        [_moreViewController updateSaldoTokopedia];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_moreViewController) {
        [_moreViewController showTooltipView];
    }
}

- (void)tapNotificationBar {
    [_notifManager tapNotificationBar];
}

- (void)tapWindowBar {
    [_notifManager tapWindowBar];
}

- (void)initNotificationManager {
    _notifManager = [NotificationManager new];
    [_notifManager setViewController:self];
    _notifManager.delegate = self;
    self.navigationItem.rightBarButtonItem = _notifManager.notificationButton;
}

- (void)notificationManager:(id)notificationManager pushViewController:(id)viewController
{
    [notificationManager tapWindowBar];
    [self performSelector:@selector(pushViewController:) withObject:viewController afterDelay:0.3];
}

- (void)pushViewController:(id)viewController {
    UIViewController *vc = viewController;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
