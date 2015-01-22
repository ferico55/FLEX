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
    // Badge label. contains notification number
    _badgeLabel = [[UILabel alloc]initWithFrame:CGRectMake(-5, -3, 20, 20)];
    [_badgeLabel setFont:[UIFont fontWithName:@"GothamMedium" size:12]];
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
    [button setFrame:CGRectMake(0, 0, 34, 34)];
    [button addSubview:_badgeLabel];
    
    self.customView = button;

    return self;
}

@end
