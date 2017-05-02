//
//  InboxMessageList.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#define CUserReputation @"user_reputation"
@class ReputationDetail;

@interface InboxMessageList : NSObject
typedef NS_ENUM(NSInteger, UserLabelMessage) {
    Administrator = 1,
    Pengguna = 2,
    Penjual = 3,
    Pembeli = 4,
    System = 5
};

@property (nonatomic, strong) NSString *message_id;
@property (nonatomic, strong) NSString *user_full_name;
@property (nonatomic, strong) NSString *message_create_time;
@property (nonatomic, strong) NSString *message_read_status;
@property (nonatomic, strong) NSString *message_title;
@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *message_reply;
@property (nonatomic, strong) NSString *message_inbox_id;
@property (nonatomic, strong) NSString *user_image;
@property (nonatomic, strong) NSString *json_data_info;
@property (nonatomic, strong) NSString *user_label;
@property NSInteger user_label_id;

@property (nonatomic, strong) ReputationDetail *user_reputation;

+ (RKObjectMapping*)mapping;
@end
