//
//  AppDelegate.h
//  Tokopedia
//
//  Created by IT Tkpd on 8/19/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tkpd.h"
#import "TAGContainer.h"
#import "TAGContainerOpener.h"
#import "TAGManager.h"

#import <UserNotifications/UserNotifications.h>
#import "GAI.h"

#import "AppNavigationDelegate.h"



@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate,  AppNavigationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) UIViewController *navigationController;
@property (nonatomic, strong) TAGManager *tagManager;
@property (nonatomic, strong) TAGContainer *container;
@property (strong, nonatomic) id<GAITracker> tracker;
@property (strong, nonatomic) UINavigationController *nav;

- (void)setupInitialViewController;
@end
