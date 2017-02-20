//
//  NotificationManager.h
//  Tokopedia
//
//  Created by Tokopedia on 1/9/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotificationBarButton.h"
#import "Notification.h"
#import "NotificationViewController.h"
#import "UserAuthentificationManager.h"
#import "NotificationRequest.h"
#import "RedirectHandler.h"

@protocol NotificationManagerDelegate <NSObject>

@optional
- (void)didReceiveNotification:(Notification *)notification;
- (void)notificationManager:(id)notificationManager pushViewController:(id)viewController;

@end

@interface NotificationManager : NSObject  {
    UserAuthentificationManager *_userManager;
    RedirectHandler *_redirectHandler;
}

@property (strong, nonatomic) Notification *notification;
@property (nonatomic, strong) UIWindow *notificationWindow;
@property (strong, nonatomic) UILabel *badgeLabel;
@property (strong, nonatomic) UIViewController *attachedViewController;
@property (strong, nonatomic) UIImageView *notificationArrowImageView;
@property (strong, nonatomic) NotificationBarButton *notificationButton;
@property (strong, nonatomic) NotificationViewController *notificationController;
@property (strong, nonatomic) NotificationRequest *notificationRequest;
@property (weak, nonatomic) id<NotificationManagerDelegate> delegate;

- (void)clearCacheNotificationPanel;
- (void)tapNotificationBar;
- (void)tapWindowBar;
- (void)setViewController:(UIViewController*)vc;
- (void)initNotificationRequest;

@end
