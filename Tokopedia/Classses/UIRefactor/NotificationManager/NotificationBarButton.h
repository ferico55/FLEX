//
//  NotificationBarButton.h
//  Tokopedia
//
//  Created by Tokopedia PT on 12/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationBarButton : UIBarButtonItem

@property (strong, nonatomic) UILabel *badgeLabel;

- (void)setNoUnreadNotification:(NSString*)status;

@end
