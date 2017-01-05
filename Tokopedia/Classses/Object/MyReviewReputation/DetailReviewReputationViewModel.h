//
//  DetailReviewReputaionViewModel.h
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReviewResponse.h"
#import "ReviewImageAttachment.h"

@interface DetailReviewReputationViewModel : NSObject

@property (nonatomic, weak) NSString *product_rating_point;
@property (nonatomic, weak) NSString *product_service_point;
@property (nonatomic, weak) NSString *review_create_time;
@property (nonatomic, weak) NSString *product_name;
@property (nonatomic, weak) NSString *review_is_skipable;
@property (nonatomic, weak) NSString *product_image;
@property (nonatomic, weak) NSString *product_accuracy_point;
@property (nonatomic, weak) NSString *review_message;
@property (nonatomic, weak) NSString *readStat;
@property (nonatomic, weak) NSString *read_status;
@property (nonatomic, weak) NSString *review_status;
@property (nonatomic, weak) NSString *review_is_allow_edit;
@property (nonatomic, weak) NSString *review_is_skipped;
@property (nonatomic, weak) NSString *review_update_time;
@property (nonatomic, weak) NSString *review_user_name;
@property (nonatomic, weak) NSString *review_user_image;
@property (nonatomic, weak) NSString *review_rate_accuracy;
@property (nonatomic, weak) NSString *review_rate_quality;
@property (nonatomic, weak) NSString *product_status;
@property (nonatomic, weak) NSString *product_id;
@property BOOL review_is_helpful;

@property (nonatomic, weak) ReviewResponse *review_response;
@property (nonatomic, weak) NSArray *review_image_attachment;

@end
