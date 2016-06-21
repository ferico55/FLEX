//
//  NotificationInbox.h
//  Tokopedia
//
//  Created by Tokopedia PT on 12/15/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationInbox : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSString *inbox_friend;
@property (strong, nonatomic) NSString *inbox_wishlist;
@property (strong, nonatomic) NSString *inbox_ticket;
@property (strong, nonatomic) NSString *inbox_review;
@property (strong, nonatomic) NSString *inbox_message;
@property (strong, nonatomic) NSString *inbox_talk;
@property (strong, nonatomic) NSString *inbox_reputation;

@end
