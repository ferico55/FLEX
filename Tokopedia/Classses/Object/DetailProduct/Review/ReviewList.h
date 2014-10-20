//
//  ReviewList.h
//  Tokopedia
//
//  Created by IT Tkpd on 9/25/14.
//  Copyright (c) 2014 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ReviewResponse.h"
#import "ReviewProductOwner.h"

@interface ReviewList : NSObject

@property (nonatomic, strong) ReviewResponse *review_response;
@property (nonatomic, strong) NSString *review_shop_id;
@property (nonatomic, strong) NSString *review_user_image;
@property (nonatomic, strong) NSString *review_create_time;
@property (nonatomic, strong) NSString *review_id;
@property (nonatomic, strong) NSString *product_images;
@property (nonatomic, strong) ReviewProductOwner *review_product_owner;
@property (nonatomic, strong) NSString *review_user_name;
@property (nonatomic, strong) NSString *review_message;
@property (nonatomic, strong) NSString *review_user_id;

// product
@property (nonatomic) NSInteger review_rate_quality;
@property (nonatomic) NSInteger review_rate_speed;
@property (nonatomic) NSInteger review_rate_service;
@property (nonatomic) NSInteger review_rate_accuracy;

//shop
@property (nonatomic, strong) NSString *review_product_name;
@property (nonatomic, strong) NSString *review_product_id;
@property (nonatomic, strong) NSString *review_product_image;

@end
