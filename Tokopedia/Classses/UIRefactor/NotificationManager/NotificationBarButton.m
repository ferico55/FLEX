//
//  NotificationBarButton.m
//  Tokopedia
//
//  Created by Tokopedia PT on 12/17/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import "NotificationBarButton.h"

@implementation NotificationBarButton

- (id)init
{
    self = [super init];
    if (self != nil) {
        // Badge label. contains notification number
        _badgeLabel = [[UILabel alloc]initWithFrame:CGRectMake(-5, -5, 17, 17)];
        [_badgeLabel setFont:[UIFont mediumSystemFontOfSize:10]];
        [_badgeLabel setBackgroundColor:[UIColor redColor]];
        [_badgeLabel setTextColor:[UIColor whiteColor]];
        [_badgeLabel.layer setCornerRadius:10];
        [_badgeLabel setClipsToBounds:YES];
        [_badgeLabel setTag:1];
        [_badgeLabel setHidden:YES];
        [_badgeLabel setTextAlignment:NSTextAlignmentCenter];
        
        // Button for bar button item
        UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"icon_notification_toped"] forState:UIControlStateNormal];
        [button setFrame:CGRectMake(0, 0, 25, 25)];
        [button addSubview:_badgeLabel];
        
        self.customView = button;
    }
    return self;
}

- (void)setNoUnreadNotification:(NSString*)status {
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    if([status isEqualToString:@"0"]) {
        [_badgeLabel setBackgroundColor:[UIColor colorWithRed:10.0/255.0 green:126.0/255.0 blue:7.0/255.0 alpha:1.0]];
    } else {
        [_badgeLabel setBackgroundColor:[UIColor redColor]];
    }

}


@end
