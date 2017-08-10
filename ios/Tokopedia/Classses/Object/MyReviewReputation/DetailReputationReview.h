//
//  DetailReputationReview.h
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailReviewReputationViewModel.h"
#import "DetailReputationReview.h"
#import "ReputationDetail.h"
#import "ReviewResponse.h"
#import "ProductOwner.h"
#import "DetailTotalLikeDislike.h"

@class ShopBadgeLevel;


@interface DetailReputationReview : NSObject

@property (nonatomic, strong) NSString *product_accuracy_desc;
@property (nonatomic, strong) NSString *product_accuracy_point;
@property (nonatomic, strong) NSString *product_id;
@property (nonatomic, strong) NSString *product_image;
@property (nonatomic, strong) NSString *product_name;
@property (nonatomic, strong) NSString *product_rating_desc;
@property (nonatomic, strong) NSString *product_rating_point;
@property (nonatomic, strong) NSString *product_service_desc;
@property (nonatomic, strong) NSString *product_service_point;
@property (nonatomic, strong) NSString *product_speed_desc;
@property (nonatomic, strong) NSString *product_speed_point;
@property (nonatomic, strong) NSString *product_status;
@property (nonatomic, strong) NSString *product_uri;
@property (nonatomic, strong) NSString *reputation_id;
@property (nonatomic, strong) NSString *reputation_inbox_id;
@property (nonatomic, strong) NSString *review_create_time;
@property (nonatomic, strong) NSString *review_full_name;
@property (nonatomic, strong) NSString *review_id;
@property (nonatomic, strong) NSString *review_is_allow_edit;
@property (nonatomic, strong) NSString *review_is_read;
@property (nonatomic, strong) NSString *review_is_skipable;
@property (nonatomic, strong) NSString *review_is_skipped;
@property (nonatomic, strong) NSString *review_message;
@property (nonatomic, strong) NSString *review_message_edit;
@property (nonatomic, strong) NSString *review_post_time;
@property (nonatomic, strong) NSString *review_rate_accuracy;
@property (nonatomic, strong) NSString *review_rate_accuracy_desc;
@property (nonatomic, strong) NSString *review_rate_product;
@property (nonatomic, strong) NSString *review_rate_product_desc;
@property (nonatomic, strong) NSString *review_rate_service;
@property (nonatomic, strong) NSString *review_rate_service_desc;
@property (nonatomic, strong) NSString *review_rate_speed;
@property (nonatomic, strong) NSString *review_rate_speed_desc;
@property (nonatomic, strong) NSString *review_read_status;
@property (nonatomic, strong) NSString *review_status;
@property (nonatomic, strong) NSString *review_update_time;
@property (nonatomic, strong) NSString *review_user_id;
@property (nonatomic, strong) NSString *review_user_image;
@property (nonatomic, strong) NSString *review_user_label;
@property (nonatomic, strong) NSString *review_user_label_id;
@property (nonatomic, strong) NSString *review_user_name;
@property (nonatomic, strong) NSString *shop_domain;
@property (nonatomic, strong) NSString *shop_id;
@property (nonatomic, strong) NSString *shop_name;
@property (nonatomic, strong) NSString *user_image;
@property (nonatomic, strong) NSString *user_url;

@property (nonatomic, strong) ShopBadgeLevel *shop_badge_level;
@property (nonatomic, strong) ReputationDetail *review_user_reputation;
@property (nonatomic, strong) ProductOwner *product_owner;
@property (nonatomic, strong) ProductOwner *review_product_owner;
@property (nonatomic, strong) ReviewResponse *review_response;
@property (nonatomic, strong) DetailReviewReputationViewModel *viewModel;

@property (nonatomic) NSString* review_product_status;
@property (nonatomic) NSString* review_is_owner;
@property (nonatomic, strong) NSString *review_product_name;
@property (nonatomic, strong) NSString *review_product_id;
@property (nonatomic, strong) NSString *review_product_image;
@property (nonatomic, strong) NSString *review_rate_quality;
@property (nonatomic, strong) NSString *review_shop_name;

@property (nonatomic, strong) NSString *review_shop_id;
@property (nonatomic, strong) NSString *review_reputation_id;

@property (nonatomic, strong) NSArray *review_image_attachment;
@property (nonatomic, strong) NSString *review_create_time_fmt;
@property BOOL review_is_helpful;

//only used in helpful review, diff implementation, diff ws
@property (nonatomic, strong) DetailTotalLikeDislike *review_like_dislike;


+ (RKObjectMapping*)mapping;
+ (RKObjectMapping*)mappingForInbox;
+ (RKObjectMapping*)mappingForHelpfulReview;

@end
