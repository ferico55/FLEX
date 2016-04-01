//
//  TalkList.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TalkModelView;
#define CTalkUserReputation @"talk_user_reputation"
@class ReputationDetail;
@interface TalkList : NSObject

// shop
@property (nonatomic, strong) NSString *talk_product_name;
@property (nonatomic, strong) NSString *talk_product_image;
@property (nonatomic, strong) NSString *talk_product_id;
@property (nonatomic, strong) NSString *talk_own;
@property (nonatomic) NSInteger talk_user_id;

//product
@property (nonatomic, strong) NSString *talk_user_image;
@property (nonatomic, strong) NSString *talk_user_name;

// shop + product
@property (nonatomic, strong) NSString *talk_id;
@property (nonatomic, strong) NSString *talk_read_status;
@property (nonatomic, strong) NSString *talk_product_status;
@property (nonatomic, strong) NSString *talk_create_time;
@property (nonatomic, strong) NSString *talk_message;
@property (nonatomic) NSInteger talk_follow_status;
@property (nonatomic, strong) NSString *talk_total_comment;
@property (nonatomic, strong) NSString *talk_shop_id;
@property (nonatomic) BOOL disable_comment;
@property (nonatomic, strong) ReputationDetail *talk_user_reputation;


//user label
@property (nonatomic, strong) NSString *talk_user_label;
@property (nonatomic, strong) NSString *talk_user_label_id;

@property (nonatomic, strong) TalkModelView *viewModel;

+ (RKObjectMapping *)mapping;
@end
