//
//  ResponseCommentResult.h
//  Tokopedia
//
//  Created by Tokopedia on 7/15/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductOwner.h"
#import "ReviewResponse.h"
#import "ShopReputation.h"

#define CIsOwner @"is_owner"
#define CProductOwner @"product_owner"
#define CReviewResponse @"review_response"
#define CReputationReviewCounter @"reputation_review_counter"
#define CIsSuccess @"is_success"
#define CShowBookmark @"show_bookmark"
#define CReviewID @"review_id"

#define CShopID @"shop_id"
#define CShopName @"shop_name"
#define CShopImgUri @"shop_img_uri"
#define CShopReputation @"shop_reputation"

@interface ResponseCommentResult : NSObject
@property (nonatomic, strong) NSString *is_owner;
@property (nonatomic, strong) ProductOwner *product_owner;
@property (nonatomic, strong) ReviewResponse *review_response;
@property (nonatomic, strong) ShopReputation *shop_reputation;
@property (nonatomic, strong) NSString *reputation_review_counter;
@property (nonatomic, strong) NSString *is_success;
@property (nonatomic, strong) NSString *show_bookmark;
@property (nonatomic, strong) NSString *review_id;


@property (nonatomic, strong) NSString *shop_id;
@property (nonatomic, strong) NSString *shop_name;
@property (nonatomic, strong) NSString *shop_img_uri;

+ (RKObjectMapping*)mapping;
@end
