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

- (void)didReceiveNotification:(Notification *)notification;

@end

@interface NotificationRequest : NSObject

@property (weak) id<NotificationDelegate> delegate;

- (void)loadNotification;

@end
