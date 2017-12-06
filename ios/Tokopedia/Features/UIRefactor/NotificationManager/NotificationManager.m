//
//  NotificationManager.m
//  Tokopedia
//
//  Created by Tokopedia on 1/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "NotificationManager.h"
#import "NotificationState.h"
#import "UIImage+ImageEffects.h"

#import "HomeTabViewController.h"

@interface NotificationManager () <NotificationDelegate, NotificationViewDelegate>

@end

@implementation NotificationManager

@synthesize totalCart;

- (id)init {
    self = [super init];
    if(self) {
        _userManager = [UserAuthentificationManager new];
        _notificationRequest = [NotificationRequest new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCacheNotificationPanel) name:@"clearCacheNotificationBar" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetNotification) name:@"resetNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUnreadNotification:) name:@"setUnreadNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarDidChangeFrame:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    }
    return self;
}

- (void)initNotificationRequest {
    _notificationRequest.delegate = self;
    [_notificationRequest loadNotification];
}

- (void)initNotificationBarButton {
    _notificationButton = [[NotificationBarButton alloc] init];
    UIButton *button = (UIButton *)_notificationButton.customView;
    
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    CGRect frame = _attachedViewController.view.frame;
//    frame.size.height = screenRect.size.height;
//    _attachedViewController.view.frame = frame;
        
    [button addTarget:_attachedViewController action:@selector(tapNotificationBar) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initNotificationWindow {
    _notificationWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _notificationWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    _notificationWindow.clipsToBounds = YES;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;

    _notificationArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_triangle_grey"]];
    _notificationArrowImageView.contentMode = UIViewContentModeScaleAspectFill;
    _notificationArrowImageView.clipsToBounds = YES;
    _notificationArrowImageView.frame = CGRectMake(screenWidth-40, 60, 10, 5);
    _notificationArrowImageView.alpha = 0;
    [_notificationWindow addSubview:_notificationArrowImageView];
}

- (void)clearCacheNotificationPanel{
    [_notificationRequest deleteCache];
}

- (void)setViewController:(UIViewController*)vc {
    _attachedViewController = vc;    
    if([_userManager isLogin]) {
        [self initNotificationBarButton];
        [self initNotificationRequest];
        [self initNotificationWindow];
    }
}

- (void)tapNotificationBar {
    [AnalyticsManager trackEventName:@"clickTopedIcon" category:GA_EVENT_CATEGORY_NOTIFICATION action:GA_EVENT_ACTION_CLICK label:@"Bell Notification"];
    [_notificationWindow makeKeyAndVisible];
    
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    CGRect frame = _attachedViewController.view.frame;
//    frame.size.height = screenRect.size.height;
//    _attachedViewController.view.frame = frame;
    
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:_attachedViewController action:@selector(tapWindowBar)];
    
    
    UIView *tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _attachedViewController.view.frame.size.width, 64)];
    [tapView addGestureRecognizer:tapRecognizer];
    [_notificationWindow addSubview:tapView];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    _notificationController = [storyboard instantiateViewControllerWithIdentifier:@"NotificationViewController"];
    _notificationController.notification = _notification;
    _notificationController.delegate = self;
    
    [_notificationController.tableView beginUpdates];
    CGRect notificationTableFrame = _notificationController.tableView.frame;
    notificationTableFrame.origin.y = 64;
    notificationTableFrame.size.height = [UIScreen mainScreen].bounds.size.height;
    
    UIGraphicsBeginImageContext([UIScreen mainScreen].bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIView *view = _attachedViewController.view;
    [view.layer renderInContext:context];
    UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *blur = [screenShot  applyBlurWithRadius:20 tintColor:[UIColor colorWithWhite:1 alpha:0.5] saturationDeltaFactor:1.5 maskImage:nil];
    
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height)];
    bgImageView.image = blur;
    
    _notificationController.tableView.backgroundView = bgImageView;
    _notificationController.tableView.backgroundView.contentMode = UIViewContentModeTop;
    
    _notificationController.tableView.frame = notificationTableFrame;
    [_notificationController.tableView endUpdates];
    
    _notificationController.tableView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0);
    
    [_notificationWindow addSubview:_notificationController.view];
    
    _notificationArrowImageView.alpha = 1;
    
    //    [UIView animateWithDuration:0.4 animations:^{
    //        _notificationWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    //    }];
    //
    //    [UIView animateWithDuration:0.25 animations:^{
    //        _notificationWindow.frame = CGRectMake(0, 0, _attachedViewController.view.frame.size.width, 568);
    //    }];
    
    CGAffineTransform tr = CGAffineTransformScale(_notificationWindow.transform, 0.1, 0.1);
    _notificationWindow.transform = tr;
    _notificationWindow.hidden = NO;
    
    [UIView animateWithDuration:0.4 delay:0
         usingSpringWithDamping:0.5 initialSpringVelocity:0.0f
                        options:0 animations:^{
                            _notificationWindow.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                        } completion:nil];
    
    [self setUnreadNotification:nil];
    [self resetNotification];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [_notificationWindow setTransform:[self transformForOrientation:orientation]];
        _notificationWindow.frame = [self screenBounds];
    } else {
        [_notificationWindow setTransform:[self transformForOrientation:orientation]];
    }
}


- (void)resetNotification {
    [_notificationRequest resetNotification];
}

- (void)setUnreadNotification:(NSNotification*)notification
{
    if(notification) {
        NSDictionary *userinfo = notification.userInfo;
        [_notificationButton setNoUnreadNotification:[userinfo objectForKey:@"increment_notif"]];
    } else {
        [_notificationButton setNoUnreadNotification:@"0"];
    }
    
}

- (void)tapWindowBar {
    //    CGRect windowFrame = _notificationWindow.frame;
    //    windowFrame.size.height = 0;
    
    //    [UIView animateWithDuration:0.3 animations:^{
    //        _notificationWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    //        _notificationArrowImageView.alpha = 0;
    //    }];
    //
    //    [UIView animateWithDuration:0.3 animations:^{
    //        _notificationWindow.frame = windowFrame;
    //    } completion:^(BOOL finished) {
    //        _notificationWindow.hidden = YES;
    //    }];
    
    [UIView animateWithDuration:0.4 delay:0
         usingSpringWithDamping:0.5 initialSpringVelocity:0.0f
                        options:0 animations:^{
                            _notificationWindow.transform = CGAffineTransformScale(_notificationWindow.transform, 0, 0);
                        } completion:^ (BOOL finish){
                            if(finish) {
                                _notificationWindow.hidden = YES;
                                _notificationWindow.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                            }
                        }];
}

- (void)didReceiveNotification:(Notification *)notification
{
    _notification = notification;
    if ([self.delegate respondsToSelector:@selector(didReceiveNotification:)]) {
        [self.delegate didReceiveNotification:notification];
    }
    //    if ([_notification.result.total_notif integerValue] == 0) {
    //        _notificationButton.badgeLabel.hidden = YES;
    //    } else {
    _notificationButton.enabled = YES;
    _notificationButton.badgeLabel.hidden = NO;
    

    _notificationButton.badgeLabel.text = [_notification.result.total_notif  stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger totalNotif = [_notification.result.total_notif integerValue];
    CGRect badgeLabelFrame = _notificationButton.badgeLabel.frame;
    if (totalNotif >= 10 && totalNotif < 100) {
        badgeLabelFrame.origin.x = 22;
        badgeLabelFrame.size.width = 30;
    } else if (totalNotif >= 100 && totalNotif < 1000) {
        badgeLabelFrame.origin.x = 22;
        badgeLabelFrame.size.width = 34;
    } else if (totalNotif >= 1000 && totalNotif < 10000) {
        badgeLabelFrame.origin.x = 22;
        badgeLabelFrame.size.width = 42;
        
    } else if (totalNotif >= 10000 && totalNotif < 100000) {
        badgeLabelFrame.origin.x = 22;
        badgeLabelFrame.size.width = 50;
    }
    _notificationButton.badgeLabel.frame = badgeLabelFrame;
    
    if ([_notification.result.total_notif integerValue] == 0) {
        _notificationButton.badgeLabel.hidden = YES;
    }
    //    }
    
    if ([_notification.result.total_cart integerValue]>0)
    {
        [[_attachedViewController.tabBarController.viewControllers objectAtIndex:3] tabBarItem].badgeValue = [_notification.result.total_cart stringValue];
        NSLog(@"total cart:%@", [_notification.result.total_cart stringValue]);
    }
    else
    {
        [[_attachedViewController.tabBarController.viewControllers objectAtIndex:3] tabBarItem].badgeValue = nil;
        NSLog(@"total cart:%@", [_notification.result.total_cart stringValue]);

    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[_notification.result.total_cart stringValue] forKey:@"total_cart"];
    [prefs synchronize];
}


#pragma mark - Notification view delegate

- (void)pushViewController:(id)viewController
{
    
    if ([self.delegate respondsToSelector:@selector(notificationManager:pushViewController:)]) {
        [self.delegate notificationManager:self pushViewController:viewController];
    }
}

- (void)navigateUsingTPRoutes:(NSString *)urlString {
    if ([self.delegate respondsToSelector:@selector(navigateUsingTPRoutesWithString:onNotificationManager:)]) {
        [self.delegate navigateUsingTPRoutesWithString:urlString onNotificationManager:self];
    }
}


#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)orientation {
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
            return CGAffineTransformMakeRotation(-90 * M_PI / 180);
        case UIInterfaceOrientationLandscapeRight:
            return CGAffineTransformMakeRotation(90 * M_PI / 180);
        case UIInterfaceOrientationPortraitUpsideDown:
            return CGAffineTransformMakeRotation(180 * M_PI / 180);
        default:
            return CGAffineTransformMakeRotation(0 * M_PI / 180);
    }
}

- (void)statusBarDidChangeFrame:(NSNotification *)notification {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [_notificationWindow setTransform:[self transformForOrientation:orientation]];
        _notificationWindow.frame = [self screenBounds];
    } else {
        [_notificationWindow setTransform:[self transformForOrientation:orientation]];
    }
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    _notificationArrowImageView.frame = CGRectMake(screenWidth-40, 60, 10, 5);
}

- (CGRect)screenBounds {
    CGRect bounds = [UIScreen mainScreen].bounds;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(fixedCoordinateSpace)]) {
        id<UICoordinateSpace> currentCoordSpace = [[UIScreen mainScreen] coordinateSpace];
        id<UICoordinateSpace> portraitCoordSpace = [[UIScreen mainScreen] fixedCoordinateSpace];
        bounds = [portraitCoordSpace convertRect:[[UIScreen mainScreen] bounds] fromCoordinateSpace:currentCoordSpace];
    }
    return bounds;
}

@end
