//
//  NotificationViewController.h
//  Tokopedia
//
//  Created by Tokopedia PT on 12/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notification.h"
#import "GAIDictionaryBuilder.h"

@protocol NotificationViewDelegate <NSObject>

@optional
- (void)pushViewController:(id)viewController;
- (void)navigateUsingTPRoutes:(NSString *)urlString;
@end

@interface NotificationViewController : UITableViewController

@property (strong, nonatomic) Notification *notification;
@property (weak, nonatomic) id<NotificationViewDelegate> delegate;

@end
