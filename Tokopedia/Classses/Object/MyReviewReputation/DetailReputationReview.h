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

#define CShopBadgeLevel @"shop_badge_level"
#define CReviewRateAccuracy @"review_rate_accuracy"
#define CReviewRateAccuracyDesc @"review_rate_accuracy_desc"
#define CProductRatingPoint @"product_rating_point"
#define CReviewIsSkipable @"review_is_skipable"
#define CReviewIsSkiped @"review_is_skipped"
#define CProductStatus @"product_status"
#define CReviewFullName @"review_full_name"
#define CReviewMessage @"review_message"
#define CProductSpeedDesc @"product_speed_desc"
#define CReviewReadStatus @"review_read_status"
#define CProductUri @"product_uri"
#define CReviewUserID @"review_user_id"
#define CProductServiceDesc @"product_service_desc"
#define CProductSpeedPoint @"product_speed_point"
#define CReviewStatus @"review_status"
#define CReviewUpdateTime @"review_update_time"
#define CProductServicePoint @"product_service_point"
#define CProductAccuracyPoint @"product_accuracy_point"
#define CReputationID @"reputation_id"
#define CProductID @"product_id"
#define CProductRatingDesc @"product_rating_desc"
#define CProductImage @"product_image"
#define CProductAccuracyDesc @"product_accuracy_desc"
#define CUserImage @"user_image"
#define CReputationInboxID @"reputation_inbox_id"
#define CReviewCreateTime @"review_create_time"
#define CReviewMessageEdit @"review_message_edit"
#define CReviewID @"review_id"
#define CReviewPostTime @"review_post_time"
#define CReviewIsAllowEdit @"review_is_allow_edit"
#define CProductName @"product_name"
#define CShopDomain @"shop_domain"
#define CReviewUserReputation @"review_user_reputation"
#define CProductOwner @"product_owner"
#define CReviewResponse @"review_response"
#define CReviewUserLabelID @"review_user_label_id"
#define CReviewUserLabel @"review_user_label"
#define CReviewRateProductDesc @"review_rate_product_desc"
#define CReviewRateSpeedDesc @"review_rate_speed_desc"
#define CReviewRateSpeed @"review_rate_speed"
#define CReviewUserName @"review_user_name"
#define CReviewShopID @"review_shop_id"
#define CReviewUserImage @"review_user_image"
#define CReviewRateServiceDesc @"review_rate_service_desc"
#define CReviewRateService @"review_rate_service"
#define CReviewRateProduct @"review_rate_product"
#define CReviewProductOwner @"review_product_owner"


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

//only used in helpful review, diff implementation, diff ws
@property (nonatomic, strong) DetailTotalLikeDislike *review_like_dislike;


+ (RKObjectMapping*)mapping;
+ (RKObjectMapping*)mappingForInbox;
@end
