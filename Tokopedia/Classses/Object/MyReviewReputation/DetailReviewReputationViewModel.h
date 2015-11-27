//
//  DetailReviewReputaionViewModel.h
//  Tokopedia
//
//  Created by Tokopedia on 7/7/15.
//  Copyright (c) 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReviewResponse.h"

@interface DetailReviewReputationViewModel : NSObject
@property (nonatomic, weak) NSString    *product_rating_point,
                                        *product_name,
                                        *review_create_time,
                                        *review_is_skipable,
                                        *product_image,
                                        *product_service_point,
                                        *product_accuracy_point,
                                        *review_message,
                                        *readStat,
                                        *read_status,
                                        *review_status,
                                        *review_is_allow_edit,
                                        *review_is_skipped,
                                        *review_update_time,
                                        *review_user_name,
                                        *review_user_image,
                                        *review_rate_accuracy,
                                        *review_rate_quality,
                                        *product_status;

@property (nonatomic, weak) ReviewResponse *review_response;

@end
