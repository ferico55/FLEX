//
//  NotificationManager.m
//  Tokopedia
//
//  Created by Tokopedia on 1/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import "NotificationManager.h"
#import "InboxMessageViewController.h"
#import "TKPDTabInboxMessageNavigationController.h"
#import "NotificationState.h"

@interface NotificationManager () <NotificationDelegate>

@end

@implementation NotificationManager

- (id)init {
    self = [super init];
    
    
    if(self) {
        _userManager = [UserAuthentificationManager new];
        _notificationRequest = [NotificationRequest new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearCacheNotificationPanel) name:@"clearCacheNotificationBar" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetNotification) name:@"resetNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUnreadNotification:) name:@"setUnreadNotification" object:nil];
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
    [button addTarget:_attachedViewController action:@selector(tapNotificationBar) forControlEvents:UIControlEventTouchUpInside];
}

- (void)initNotificationWindow {
    _notificationWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _notificationWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    _notificationWindow.clipsToBounds = YES;
    
    _notificationArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_triangle_grey"]];
    _notificationArrowImageView.contentMode = UIViewContentModeScaleAspectFill;
    _notificationArrowImageView.clipsToBounds = YES;
    _notificationArrowImageView.frame = CGRectMake(280, 60, 10, 5);
    _notificationArrowImageView.alpha = 0;
    [_notificationWindow addSubview:_notificationArrowImageView];
}

- (void)clearCacheNotificationPanel{
    [_notificationRequest deleteCache];
}

- (void)selectViewControllerToOpen:(NSString *)notificationCode{
    switch ([notificationCode integerValue]) {
        case STATE_NEW_MESSAGE: {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:@"goToInboxMessage" object:nil userInfo:@{}];
            break;
        }
            
        case STATE_NEW_TALK: {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:@"goToInboxTalk" object:nil userInfo:@{}];
            break;
        }
            
        case STATE_NEW_REVIEW: {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:@"goToInboxReview" object:nil userInfo:@{}];
            break;
        }
            
        case STATE_EDIT_REVIEW: {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:@"goToInboxReview" object:nil userInfo:@{}];
            break;
        }
        case STATE_REPLY_REVIEW: {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:@"goToInboxReview" object:nil userInfo:@{}];
            break;
        }
            
        case STATE_NEW_ORDER: {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:@"goToNewOrder" object:nil userInfo:@{}];
            break;
        }
            
        default:
            break;
    }
}

- (void)setViewController:(UIViewController*)vc {
    _attachedViewController = vc;
    
    NSString* userId = [NSString stringWithFormat:@"%@", [_userManager getUserId]];
    if(![userId isEqualToString:IS_NOT_LOGIN]) {
        [self initNotificationBarButton];
        [self initNotificationRequest];
        [self initNotificationWindow];
    }
    
}

- (void)tapNotificationBar {
    [_notificationWindow makeKeyAndVisible];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:_attachedViewController action:@selector(tapWindowBar)];
    
    UIView *tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _attachedViewController.view.frame.size.width, 64)];
    [tapView addGestureRecognizer:tapRecognizer];
    [_notificationWindow addSubview:tapView];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    _notificationController = [storyboard instantiateViewControllerWithIdentifier:@"NotificationViewController"];
    _notificationController.notification = _notification;
    
    [_notificationController.tableView beginUpdates];
    CGRect notificationTableFrame = _notificationController.tableView.frame;
    notificationTableFrame.origin.y = 64;
    notificationTableFrame.size.height = 300;
    _notificationController.tableView.frame = notificationTableFrame;
    [_notificationController.tableView endUpdates];
    
    _notificationController.tableView.contentInset = UIEdgeInsetsMake(0, 0, 355, 0);
    
    CGRect windowFrame = _notificationWindow.frame;
    windowFrame.size.height = 0;
    _notificationWindow.frame = windowFrame;
    
    windowFrame.size.height = _attachedViewController.view.frame.size.height-64;
    
    [_notificationWindow addSubview:_notificationController.view];
    
    _notificationArrowImageView.alpha = 1;
    
    [UIView animateWithDuration:0.7 animations:^{
        _notificationWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    }];
    
    [UIView animateWithDuration:0.55 animations:^{
        _notificationWindow.frame = CGRectMake(0, 0, _attachedViewController.view.frame.size.width, _attachedViewController.view.frame.size.height+112);
    }];
    
    [self setUnreadNotification:nil];
    [self resetNotification];
    [self init];
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
    CGRect windowFrame = _notificationWindow.frame;
    windowFrame.size.height = 0;
    
    [UIView animateWithDuration:0.5 animations:^{
        _notificationWindow.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        _notificationArrowImageView.alpha = 0;
    }];
    
    [UIView animateWithDuration:0.5 animations:^{
        _notificationWindow.frame = windowFrame;
    } completion:^(BOOL finished) {
        _notificationWindow.hidden = YES;
    }];
}

- (void)didReceiveNotification:(Notification *)notification
{
    _notification = notification;
    [self.delegate didReceiveNotification:notification];    
    if ([_notification.result.total_notif integerValue] == 0) {
        _notificationButton.badgeLabel.hidden = YES;
    } else {
        _notificationButton.enabled = YES;
        _notificationButton.badgeLabel.hidden = NO;
        _notificationButton.badgeLabel.text = [_notification.result.total_notif  stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSInteger totalNotif = [_notification.result.total_notif integerValue];
        CGRect badgeLabelFrame = _notificationButton.badgeLabel.frame;
        if (totalNotif >= 10 && totalNotif < 100) {
            badgeLabelFrame.origin.x = -11;
            badgeLabelFrame.size.width = 30;
        } else if (totalNotif >= 100 && totalNotif < 1000) {
            badgeLabelFrame.origin.x = -12;
            badgeLabelFrame.size.width = 34;
        } else if (totalNotif >= 1000 && totalNotif < 10000) {
            badgeLabelFrame.origin.x = -16;
            badgeLabelFrame.size.width = 42;
            
        } else if (totalNotif >= 10000 && totalNotif < 100000) {
            badgeLabelFrame.origin.x = -22;
            badgeLabelFrame.size.width = 50;
        }
        _notificationButton.badgeLabel.frame = badgeLabelFrame;
    }
}

#pragma mark - Memory Management
-(void)dealloc{
    NSLog(@"%@ : %@",[self class], NSStringFromSelector(_cmd));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
