//
//  TalkList.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

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
@property (nonatomic, strong) NSString *talk_create_time;
@property (nonatomic, strong) NSString *talk_message;
@property (nonatomic) NSInteger talk_follow_status;
@property (nonatomic, strong) NSString *talk_total_comment;
@property (nonatomic, strong) NSString *talk_shop_id;

@end
