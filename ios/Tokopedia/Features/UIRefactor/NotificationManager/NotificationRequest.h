//
//  NotificationRequest.h
//  Tokopedia
//
//  Created by Tokopedia PT on 12/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Notification.h"

@protocol NotificationDelegate <NSObject>

@optional
- (void)didReceiveNotification:(Notification *)notification;

@end

@interface NotificationRequest : NSObject

@property (weak, nonatomic) id<NotificationDelegate> delegate;

- (void)loadNotification;
- (void)deleteCache;
- (void)resetNotification;

@end
