//
//  NotificationFormNotif.h
//  Tokopedia
//
//  Created by IT Tkpd on 11/4/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationFormNotif : NSObject <TKPObjectMapping>

@property (strong, nonatomic) NSString *flag_talk_product;
@property (strong, nonatomic) NSString *flag_admin_message;
@property (strong, nonatomic) NSString *flag_message;
@property (strong, nonatomic) NSString *flag_review;
@property (strong, nonatomic) NSString *flag_newsletter;

@end
