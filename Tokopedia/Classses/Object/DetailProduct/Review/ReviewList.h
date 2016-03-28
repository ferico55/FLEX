//
//  ReviewList.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/25/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReputationDetail.h"
#import "ReviewResponse.h"
#import "ReviewProductOwner.h"

#import "ProductReputationViewModel.h"

#define CReviewUserReputation @"review_user_reputation"
#define CReviewReputationID @"review_reputation_id"

@interface ReviewList : NSObject

@property (nonatomic, strong) ReviewResponse *review_response;
@property (nonatomic, strong) NSString *review_shop_id;
@property (nonatomic, strong) NSString *review_shop_name;
@property (nonatomic, strong) NSString *review_user_image;
@property (nonatomic, strong) NSString *review_create_time;
@property (nonatomic, strong) NSString *review_id;
@property (nonatomic, strong) NSString *product_images;
@property (nonatomic, strong) ReviewProductOwner *review_product_owner;
@property (nonatomic, strong) NSString *review_reputation_id;
@property (nonatomic, strong) NSString *review_user_name;
@property (nonatomic, strong) NSString *review_message;
@property (nonatomic, strong) NSString *review_user_id;
@property (nonatomic, strong) ReputationDetail *review_user_reputation;

// product
@property (nonatomic) NSString* review_rate_quality;
@property (nonatomic) NSString* review_rate_speed;
@property (nonatomic) NSString* review_rate_service;
@property (nonatomic) NSString* review_rate_accuracy;
@property (nonatomic) NSString* review_rate_product;

@property (nonatomic) NSString* review_product_status;
@property (nonatomic) NSString* review_is_allow_edit;
@property (nonatomic) NSString* review_is_owner;


@property (nonatomic, strong) NSString *review_product_name;
@property (nonatomic, strong) NSString *review_product_id;
@property (nonatomic, strong) NSString *review_product_image;


//User Label
@property (nonatomic, strong) NSString *review_user_label;
@property (nonatomic, strong) NSString *review_user_label_id;

@property (nonatomic, strong) ProductReputationViewModel *viewModel;

@property (nonatomic, strong) NSString *is_helpful;


@end
