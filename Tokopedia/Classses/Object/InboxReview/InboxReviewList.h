//
//  InboxReviewList.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/29/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InboxReviewResponse.h"
#import "InboxReviewProductOwner.h"

@interface InboxReviewList : NSObject

@property (nonatomic, strong) NSString *review_product_image;
@property (nonatomic, strong) NSString *review_user_name;
@property (nonatomic, strong) NSString *review_user_label;
@property (nonatomic, strong) NSString *review_user_image;
@property (nonatomic, strong) NSString *review_rate_accuracy;
@property (nonatomic, strong) NSString *review_message;
@property (nonatomic, strong) NSString *review_product_id;
@property (nonatomic, strong) NSString *review_shop_id;
@property (nonatomic, strong) NSString *review_product_name;
@property (nonatomic, strong) NSString *review_create_time;
@property (nonatomic, strong) NSString *review_id;
@property (nonatomic, strong) NSString *review_rate_quality;
@property (nonatomic, strong) NSString *review_rate_speed;
@property (nonatomic, strong) NSString *review_is_owner;
@property (nonatomic, strong) NSString *review_read_status;
@property (nonatomic, strong) NSString *review_user_id;
@property (nonatomic, strong) NSString *review_rate_service;
@property (nonatomic, strong) NSString *review_product_status;
@property (nonatomic, strong) NSString *review_is_allow_edit;
@property (nonatomic, strong) NSString *review_is_skipable;

@property (nonatomic, strong) InboxReviewResponse *review_response;
@property (nonatomic, strong) InboxReviewProductOwner *review_product_owner;





@end
